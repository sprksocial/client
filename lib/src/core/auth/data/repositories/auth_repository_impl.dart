import 'dart:async';
import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart' show restoreOAuthSession;
import 'package:atproto_core/atproto_oauth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:spark/src/core/auth/data/models/account.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/core/utils/did_utils.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/oauth_resolver.dart';

/// OAuth client metadata URL
const String _clientMetadataUrl = 'https://sprk.so/oauth-client-metadata.json';

/// Cached OAuth client metadata to avoid repeated network calls
OAuthClientMetadata? _cachedClientMetadata;

/// Implementation of the authentication repository for AT Protocol using OAuth
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() {
    _initialize();
  }

  OAuthSession? _oauthSession;
  ATProto? _atProto;
  String? _did;
  String? _handle;
  String? _pdsEndpoint;
  String? _oauthServer;

  /// Pending OAuth context during authorization flow
  OAuthContext? _pendingContext;
  OAuthClient? _oauthClient;

  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'AuthRepository',
  );

  final Completer<void> _initCompleter = Completer<void>();

  @override
  Future<void> get initializationComplete => _initCompleter.future;

  /// Gets cached OAuth client metadata, fetching once if needed
  Future<OAuthClientMetadata> _getCachedClientMetadata() async {
    if (_cachedClientMetadata != null) {
      return _cachedClientMetadata!;
    }
    _cachedClientMetadata = await getClientMetadata(_clientMetadataUrl);
    return _cachedClientMetadata!;
  }

  @override
  bool get isAuthenticated =>
      _oauthSession != null && _atProto != null && _did != null;

  @override
  String? get did => _did;

  @override
  String? get handle => _handle;

  @override
  String? get pdsEndpoint => _pdsEndpoint;

  @override
  ATProto? get atproto => _atProto;

  Future<void> _initialize() async {
    try {
      await _loadSavedSession();
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      _logger.e('AuthRepository initialization failed', error: e);
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  /// Fetches a DID document, handling both did:plc and did:web methods.
  Future<Map<String, dynamic>> _fetchDidDocument(String did) async {
    final url = DidUtils.buildDidDocumentUrl(did);
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch DID document: ${response.statusCode}');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  String? _extractPdsEndpoint(Map<String, dynamic> doc) {
    final services = doc['service'] as List<dynamic>?;
    if (services == null || services.isEmpty) {
      return null;
    }

    final pdsService = services.firstWhere(
      (s) => s['id'] == '#atproto_pds',
      orElse: () => null,
    );

    if (pdsService == null) {
      return null;
    }

    return pdsService['serviceEndpoint'] as String?;
  }

  Future<void> _loadSavedSession() async {
    try {
      // Load account as single JSON object - much faster than multiple reads
      final accountJson = await StorageManager.instance.secure.getString(
        StorageKeys.account,
      );

      if (accountJson == null) {
        return;
      }

      final account = Account.fromJsonString(accountJson);

      _oauthSession = restoreOAuthSession(
        accessToken: account.accessToken,
        refreshToken: account.refreshToken,
        clientId: account.clientId ?? _clientMetadataUrl,
        dPoPNonce: account.dpopNonce,
        publicKey: account.publicKey,
        privateKey: account.privateKey,
      );

      // Parse expiresAt, default to epoch if not found (will trigger refresh)
      DateTime expiresAt;
      try {
        expiresAt = account.expiresAt != null
            ? DateTime.parse(account.expiresAt!)
            : DateTime.fromMillisecondsSinceEpoch(0);
      } catch (e) {
        _logger.w(
          'Failed to parse expiresAt "${account.expiresAt}", defaulting to epoch',
        );
        expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
      }

      _did = account.did;
      _handle = account.handle;
      _pdsEndpoint = account.pdsEndpoint;
      _oauthServer = account.server;

      // Check if token needs refresh (5 minutes before expiration per README)
      final tokenNeedsRefresh = expiresAt.isBefore(
        DateTime.now().add(const Duration(minutes: 5)),
      );

      // Only fetch OAuth client metadata if we need to refresh the token
      // This avoids a blocking network call on app start when token is valid
      if (tokenNeedsRefresh && _oauthServer != null) {
        final metadata = await _getCachedClientMetadata();
        _oauthClient = OAuthClient(metadata, service: _oauthServer!);
        final refreshed = await refreshToken();
        if (!refreshed) {
          await _clearSavedSession();
          _oauthSession = null;
          _atProto = null;
          _did = null;
          _handle = null;
          _pdsEndpoint = null;
          _oauthServer = null;
          _oauthClient = null;
          return;
        }
      }

      // Extract just the host from the PDS endpoint
      final pdsHost = _pdsEndpoint != null
          ? Uri.parse(_pdsEndpoint!).host
          : null;

      _atProto = ATProto.fromOAuthSession(_oauthSession!, service: pdsHost);
    } catch (e) {
      _logger.e('Error loading saved account', error: e);
    }
  }

  Future<void> _saveSession() async {
    if (_oauthSession == null) return;

    try {
      final account = Account(
        accessToken: _oauthSession!.accessToken,
        refreshToken: _oauthSession!.refreshToken,
        publicKey: _oauthSession!.$publicKey,
        privateKey: _oauthSession!.$privateKey,
        clientId: _oauthSession!.$clientId ?? _clientMetadataUrl,
        dpopNonce: _oauthSession!.$dPoPNonce,
        expiresAt: _oauthSession!.expiresAt.toIso8601String(),
        did: _did,
        handle: _handle,
        pdsEndpoint: _pdsEndpoint,
        server: _oauthServer,
      );

      await StorageManager.instance.secure.setString(
        StorageKeys.account,
        account.toJsonString(),
      );
    } catch (e) {
      _logger.e('Failed to save account', error: e);
    }
  }

  Future<void> _clearSavedSession() async {
    try {
      await StorageManager.instance.secure.remove(StorageKeys.account);
      await StorageManager.instance.secure.remove(
        StorageKeys.pendingAuthContext,
      );
      // Also clear old session format if exists
      await StorageManager.instance.secure.remove(StorageKeys.userSession);
    } catch (e) {
      _logger.e('Failed to clear account', error: e);
    }
  }

  @override
  Future<String> initiateOAuth(String handle) async {
    try {
      // Resolve handle to DID
      final at = ATProto.anonymous(service: 'public.api.bsky.app');
      final didRes = await at.identity.resolveHandle(handle: handle);
      final resolvedDid = didRes.data.did;

      final didDoc = await _fetchDidDocument(resolvedDid);
      final pdsEndpoint = _extractPdsEndpoint(didDoc);

      if (pdsEndpoint == null) {
        _logger.e('PDS endpoint not found in DID document');
        throw Exception('PDS endpoint not found in DID document');
      }

      // Store user info for later
      _did = resolvedDid;
      _handle = handle;
      _pdsEndpoint = pdsEndpoint;

      // Get client metadata (cached)
      final metadata = await _getCachedClientMetadata();
      // Resolve OAuth server from PDS endpoint
      _oauthServer = await resolveOAuthServer(pdsEndpoint);
      _oauthClient = OAuthClient(metadata, service: _oauthServer!);

      // Start OAuth authorization
      final (authUrl, ctx) = await _oauthClient!.authorize(handle);
      _pendingContext = ctx;

      // Extract state parameter from authorization URL for restoration
      final authUri = Uri.parse(authUrl.toString());
      final stateParam = authUri.queryParameters['state'];

      // Store pending context in case app is killed during OAuth flow
      await StorageManager.instance.secure.setString(
        StorageKeys.pendingAuthContext,
        json.encode({
          'handle': handle,
          'did': resolvedDid,
          'pdsEndpoint': pdsEndpoint,
          'server': _oauthServer,
          'state': stateParam,
        }),
      );

      return authUrl.toString();
    } catch (e) {
      _logger.e('Failed to initiate OAuth', error: e);
      rethrow;
    }
  }

  @override
  Future<String> initiateOAuthWithService(String service) async {
    try {
      // Store service for later
      _pdsEndpoint = 'https://$service';
      _oauthServer = service;

      // Get client metadata (cached)
      final metadata = await _getCachedClientMetadata();
      _oauthClient = OAuthClient(metadata, service: _oauthServer!);

      // Start OAuth authorization without login hint
      final (authUrl, ctx) = await _oauthClient!.authorize();
      _pendingContext = ctx;

      // Extract state parameter from authorization URL for restoration
      final authUri = Uri.parse(authUrl.toString());
      final stateParam = authUri.queryParameters['state'];

      // Store pending context in case app was killed during OAuth flow
      await StorageManager.instance.secure.setString(
        StorageKeys.pendingAuthContext,
        json.encode({
          'pdsEndpoint': _pdsEndpoint,
          'server': _oauthServer,
          'state': stateParam,
        }),
      );

      return authUrl.toString();
    } catch (e) {
      _logger.e('Failed to initiate OAuth with service', error: e);
      rethrow;
    }
  }

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) async {
    try {
      if (_oauthClient == null || _pendingContext == null) {
        // Try to restore context if app was killed
        final savedContext = await StorageManager.instance.secure.getString(
          StorageKeys.pendingAuthContext,
        );
        if (savedContext != null) {
          final contextData = json.decode(savedContext) as Map<String, dynamic>;
          _handle = contextData['handle'] as String?;
          _did = contextData['did'] as String?;
          _pdsEndpoint = contextData['pdsEndpoint'] as String?;
          _oauthServer = contextData['server'] as String?;
          final savedState = contextData['state'] as String?;

          // Verify state parameter matches if present
          if (savedState != null) {
            final callbackUri = Uri.parse(callbackUrl);
            final callbackState = callbackUri.queryParameters['state'];
            if (callbackState != savedState) {
              _logger.e(
                'OAuth state mismatch. '
                'Expected: $savedState, got: $callbackState',
              );
              // Clear invalid context
              await StorageManager.instance.secure.remove(
                StorageKeys.pendingAuthContext,
              );
              return LoginResult.failed(
                'OAuth state verification failed. Please try again.',
              );
            }
          }

          // Recreate OAuth client with the correct OAuth server
          if (_oauthServer != null) {
            final metadata = await _getCachedClientMetadata();
            _oauthClient = OAuthClient(metadata, service: _oauthServer!);
          }
        }
        if (_pendingContext == null) {
          _logger.e(
            'No pending OAuth context found. '
            'App may have been killed during OAuth flow.',
          );
          // Clear any partial context data
          await StorageManager.instance.secure.remove(
            StorageKeys.pendingAuthContext,
          );
          return LoginResult.failed(
            'OAuth session was interrupted. '
            'Please start the sign-up process again.',
          );
        }

        if (_oauthClient == null) {
          _logger.e('OAuth client could not be restored');
          return LoginResult.failed('OAuth client initialization failed');
        }
      }

      // Complete OAuth flow
      _oauthSession = await _oauthClient!.callback(
        callbackUrl,
        _pendingContext!,
      );

      // Create ATProto client from OAuth session
      if (_pdsEndpoint != null) {
        final pdsHost = Uri.parse(_pdsEndpoint!).host;
        _atProto = ATProto.fromOAuthSession(_oauthSession!, service: pdsHost);
      } else {
        _logger.e('PDS endpoint is null, cannot create ATProto client');
        return LoginResult.failed('PDS endpoint not found');
      }

      // Fetch session info to get DID and handle if not already set
      // This is needed for registration flow where handle/DID aren't known upfront
      if (_did == null || _handle == null) {
        try {
          final sessionResponse = await _atProto!.server.getSession();
          _did = sessionResponse.data.did;
          _handle = sessionResponse.data.handle;
        } catch (e) {
          _logger.e('Failed to fetch session info', error: e);
          return LoginResult.failed('Failed to get session info: $e');
        }
      }

      // Save session
      await _saveSession();

      // Clear pending context
      await StorageManager.instance.secure.remove(
        StorageKeys.pendingAuthContext,
      );
      _pendingContext = null;

      return LoginResult.success();
    } catch (e, stackTrace) {
      _logger.e('OAuth callback failed', error: e, stackTrace: stackTrace);
      return LoginResult.failed(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _clearSavedSession();
      _oauthSession = null;
      _atProto = null;
      _did = null;
      _handle = null;
      _pdsEndpoint = null;
      _oauthServer = null;
      _oauthClient = null;
      _pendingContext = null;
    } catch (e) {
      _logger.e('Logout failed', error: e);
    }
  }

  @override
  Future<bool> validateSession() async {
    // Wait for initialization to complete first
    await initializationComplete;

    if (_atProto == null ||
        _oauthSession == null ||
        _did == null ||
        _did!.isEmpty) {
      return false;
    }

    try {
      final sessionResponse = await _atProto!.server.getSession();

      if (sessionResponse.data.did != _did) {
        _logger.w(
          'Session DID mismatch. '
          'Expected $_did but got ${sessionResponse.data.did}',
        );
        await logout();
        return false;
      }

      final latestHandle = sessionResponse.data.handle;
      if (latestHandle.isNotEmpty && latestHandle != _handle) {
        _handle = latestHandle;
        await _saveSession();
      }

      return true;
    } catch (e) {
      // Try to refresh the token before giving up
      final refreshed = await refreshToken();
      if (refreshed) {
        try {
          final sessionResponse = await _atProto!.server.getSession();

          if (sessionResponse.data.did != _did) {
            _logger.w(
              'Session DID mismatch after refresh. '
              'Expected $_did but got ${sessionResponse.data.did}',
            );
            await logout();
            return false;
          }

          final latestHandle = sessionResponse.data.handle;
          if (latestHandle.isNotEmpty && latestHandle != _handle) {
            _handle = latestHandle;
            await _saveSession();
          }

          return true;
        } catch (refreshError) {
          _logger.e(
            'Session validation failed after token refresh',
            error: refreshError,
          );
        }
      }

      await logout();
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      if (_oauthSession == null || _oauthClient == null) {
        // Try to recreate OAuth client if we have a session but no client
        if (_oauthSession != null && _oauthServer != null) {
          final metadata = await _getCachedClientMetadata();
          _oauthClient = OAuthClient(metadata, service: _oauthServer!);
        } else {
          return false;
        }
      }

      final refreshedSession = await _oauthClient!.refresh(_oauthSession!);
      _oauthSession = refreshedSession;

      final pdsHost = _pdsEndpoint != null
          ? Uri.parse(_pdsEndpoint!).host
          : null;
      _atProto = ATProto.fromOAuthSession(_oauthSession!, service: pdsHost);

      await _saveSession();
      return true;
    } catch (e) {
      _logger.e('OAuth token refresh failed', error: e);
      // Don't logout here - let the caller decide what to do
      return false;
    }
  }
}
