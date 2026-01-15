import 'dart:async';
import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart' show restoreOAuthSession;
import 'package:atproto_core/atproto_oauth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/core/utils/did_utils.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/oauth_resolver.dart';

/// OAuth client metadata URL
const String _clientMetadataUrl = 'https://sprk.so/oauth-client-metadata.json';

/// Implementation of the authentication repository for AT Protocol using OAuth
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() {
    _logger.i('Initializing AuthRepository');
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

  @override
  bool get isAuthenticated =>
      _oauthSession != null && _atProto != null && _did != null;

  @override
  String? get did => _did;

  @override
  String? get handle => _handle;

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
    _logger.d('Fetching DID document from: $url');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      _logger.e('Failed to fetch DID document: ${response.statusCode}');
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
      _logger.d('Loading saved OAuth session');

      final accessToken = await StorageManager.instance.secure.getString(
        StorageKeys.oauthAccessToken,
      );
      final savedRefreshToken = await StorageManager.instance.secure.getString(
        StorageKeys.oauthRefreshToken,
      );
      final publicKey = await StorageManager.instance.secure.getString(
        StorageKeys.oauthPublicKey,
      );
      final privateKey = await StorageManager.instance.secure.getString(
        StorageKeys.oauthPrivateKey,
      );
      final savedDpopNonce = await StorageManager.instance.secure.getString(
        StorageKeys.oauthDpopNonce,
      );
      final savedExpiresAt = await StorageManager.instance.secure.getString(
        StorageKeys.oauthExpiresAt,
      );
      final savedDid = await StorageManager.instance.secure.getString(
        StorageKeys.oauthDid,
      );
      final savedHandle = await StorageManager.instance.secure.getString(
        StorageKeys.oauthHandle,
      );
      final savedPdsEndpoint = await StorageManager.instance.secure.getString(
        StorageKeys.oauthPdsEndpoint,
      );
      final savedOAuthServer = await StorageManager.instance.secure.getString(
        StorageKeys.oauthServer,
      );

      if (accessToken == null ||
          savedRefreshToken == null ||
          publicKey == null ||
          privateKey == null) {
        _logger.d('No saved OAuth session found');
        return;
      }

      _oauthSession = restoreOAuthSession(
        accessToken: accessToken,
        refreshToken: savedRefreshToken,
        dPoPNonce: savedDpopNonce,
        publicKey: publicKey,
        privateKey: privateKey,
      );

      // Parse expiresAt, default to epoch if not found (will trigger refresh)
      final expiresAt = savedExpiresAt != null
          ? DateTime.parse(savedExpiresAt)
          : DateTime.fromMillisecondsSinceEpoch(0);

      _did = savedDid;
      _handle = savedHandle;
      _pdsEndpoint = savedPdsEndpoint;
      _oauthServer = savedOAuthServer;

      // Recreate OAuth client for token refresh (needed before refresh attempt)
      if (_oauthServer != null) {
        final metadata = await getClientMetadata(_clientMetadataUrl);
        _oauthClient = OAuthClient(metadata, service: _oauthServer!);
        _logger.d('OAuthClient recreated for session refresh');
      }

      // Check if token needs refresh (5 minutes before expiration per README)
      if (expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
        _logger.d('Access token expired or expiring soon, refreshing');
        final refreshed = await refreshToken();
        if (!refreshed) {
          _logger.w('Token refresh failed during restore, clearing session');
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
        _logger.i('Token refreshed successfully during restore');
      }

      // Extract just the host from the PDS endpoint
      final pdsHost = _pdsEndpoint != null
          ? Uri.parse(_pdsEndpoint!).host
          : null;

      _atProto = ATProto.fromOAuthSession(
        _oauthSession!,
        service: pdsHost,
      );

      _logger.i('OAuth session loaded successfully for user: $_handle');
    } catch (e) {
      _logger.e('Error loading saved OAuth session', error: e);
    }
  }

  Future<void> _saveSession() async {
    if (_oauthSession == null) return;

    try {
      _logger.d('Saving OAuth session for user: $_handle');
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthAccessToken,
        _oauthSession!.accessToken,
      );
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthRefreshToken,
        _oauthSession!.refreshToken,
      );
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthPublicKey,
        _oauthSession!.$publicKey,
      );
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthPrivateKey,
        _oauthSession!.$privateKey,
      );
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthDpopNonce,
        _oauthSession!.$dPoPNonce,
      );
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthExpiresAt,
        _oauthSession!.expiresAt.toIso8601String(),
      );
      if (_did != null) {
        await StorageManager.instance.secure.setString(
          StorageKeys.oauthDid,
          _did!,
        );
      }
      if (_handle != null) {
        await StorageManager.instance.secure.setString(
          StorageKeys.oauthHandle,
          _handle!,
        );
      }
      if (_pdsEndpoint != null) {
        await StorageManager.instance.secure.setString(
          StorageKeys.oauthPdsEndpoint,
          _pdsEndpoint!,
        );
      }
      if (_oauthServer != null) {
        await StorageManager.instance.secure.setString(
          StorageKeys.oauthServer,
          _oauthServer!,
        );
      }
      _logger.d('OAuth session saved successfully');
    } catch (e) {
      _logger.e('Failed to save OAuth session', error: e);
    }
  }

  Future<void> _clearSavedSession() async {
    try {
      _logger.d('Clearing saved OAuth session');
      await StorageManager.instance.secure.remove(StorageKeys.oauthAccessToken);
      await StorageManager.instance.secure.remove(
        StorageKeys.oauthRefreshToken,
      );
      await StorageManager.instance.secure.remove(StorageKeys.oauthPublicKey);
      await StorageManager.instance.secure.remove(StorageKeys.oauthPrivateKey);
      await StorageManager.instance.secure.remove(StorageKeys.oauthDpopNonce);
      await StorageManager.instance.secure.remove(StorageKeys.oauthExpiresAt);
      await StorageManager.instance.secure.remove(StorageKeys.oauthDid);
      await StorageManager.instance.secure.remove(StorageKeys.oauthHandle);
      await StorageManager.instance.secure.remove(StorageKeys.oauthPdsEndpoint);
      await StorageManager.instance.secure.remove(StorageKeys.oauthServer);
      await StorageManager.instance.secure.remove(
        StorageKeys.oauthPendingContext,
      );
      // Also clear old session format if exists
      await StorageManager.instance.secure.remove(StorageKeys.userSession);
      _logger.d('OAuth session cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear OAuth session', error: e);
    }
  }

  @override
  Future<String> initiateOAuth(String handle) async {
    try {
      _logger.i('Initiating OAuth for handle: $handle');

      // Resolve handle to DID
      final at = ATProto.anonymous(service: 'public.api.bsky.app');
      _logger.d('Resolving handle: $handle');
      final didRes = await at.identity.resolveHandle(handle: handle);
      final resolvedDid = didRes.data.did;
      _logger.d('Resolved DID: $resolvedDid');

      final didDoc = await _fetchDidDocument(resolvedDid);
      final pdsEndpoint = _extractPdsEndpoint(didDoc);

      if (pdsEndpoint == null) {
        _logger.e('PDS endpoint not found in DID document');
        throw Exception('PDS endpoint not found in DID document');
      }

      _logger.d('Found PDS endpoint: $pdsEndpoint');

      // Store user info for later
      _did = resolvedDid;
      _handle = handle;
      _pdsEndpoint = pdsEndpoint;

      // Get client metadata
      final metadata = await getClientMetadata(_clientMetadataUrl);
      // Resolve OAuth server from PDS endpoint
      _oauthServer = await resolveOAuthServer(pdsEndpoint);
      _logger.d('Resolved OAuth server: $_oauthServer');
      _oauthClient = OAuthClient(metadata, service: _oauthServer!);

      // Start OAuth authorization
      final (authUrl, ctx) = await _oauthClient!.authorize(handle);
      _pendingContext = ctx;

      // Extract state parameter from authorization URL for restoration
      final authUri = Uri.parse(authUrl.toString());
      final stateParam = authUri.queryParameters['state'];

      // Store pending context in case app is killed during OAuth flow
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthPendingContext,
        json.encode({
          'handle': handle,
          'did': resolvedDid,
          'pdsEndpoint': pdsEndpoint,
          'oauthServer': _oauthServer,
          'state': stateParam,
        }),
      );

      _logger.i('OAuth authorization URL generated');
      return authUrl.toString();
    } catch (e) {
      _logger.e('Failed to initiate OAuth', error: e);
      rethrow;
    }
  }

  @override
  Future<String> initiateOAuthWithService(String service) async {
    try {
      _logger.i('Initiating OAuth with service: $service');

      // Store service for later
      _pdsEndpoint = 'https://$service';
      _oauthServer = service;

      // Get client metadata
      final metadata = await getClientMetadata(_clientMetadataUrl);
      _logger.d('Using OAuth server: $service');
      _oauthClient = OAuthClient(metadata, service: _oauthServer!);

      // Start OAuth authorization without login hint
      final (authUrl, ctx) = await _oauthClient!.authorize();
      _pendingContext = ctx;

      // Extract state parameter from authorization URL for restoration
      final authUri = Uri.parse(authUrl.toString());
      final stateParam = authUri.queryParameters['state'];

      // Store pending context in case app was killed during OAuth flow
      await StorageManager.instance.secure.setString(
        StorageKeys.oauthPendingContext,
        json.encode({
          'pdsEndpoint': _pdsEndpoint,
          'oauthServer': _oauthServer,
          'state': stateParam,
        }),
      );

      _logger.i('OAuth authorization URL generated');
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
          StorageKeys.oauthPendingContext,
        );
        if (savedContext != null) {
          final contextData = json.decode(savedContext) as Map<String, dynamic>;
          _handle = contextData['handle'] as String?;
          _did = contextData['did'] as String?;
          _pdsEndpoint = contextData['pdsEndpoint'] as String?;
          _oauthServer = contextData['oauthServer'] as String?;
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
                StorageKeys.oauthPendingContext,
              );
              return LoginResult.failed(
                'OAuth state verification failed. Please try again.',
              );
            }
          }

          // Recreate OAuth client with the correct OAuth server
          if (_oauthServer != null) {
            final metadata = await getClientMetadata(_clientMetadataUrl);
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
            StorageKeys.oauthPendingContext,
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
        _atProto = ATProto.fromOAuthSession(
          _oauthSession!,
          service: pdsHost,
        );
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
          _logger.d('Fetched session info - DID: $_did, Handle: $_handle');
        } catch (e) {
          _logger.e('Failed to fetch session info', error: e);
          return LoginResult.failed('Failed to get session info: $e');
        }
      }

      // Save session
      await _saveSession();

      // Clear pending context
      await StorageManager.instance.secure.remove(
        StorageKeys.oauthPendingContext,
      );
      _pendingContext = null;

      _logger.i('OAuth login successful for user: $_handle');
      return LoginResult.success();
    } catch (e, stackTrace) {
      _logger.e('OAuth callback failed', error: e, stackTrace: stackTrace);
      return LoginResult.failed(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      _logger.i('Logging out user: $_handle');
      await _clearSavedSession();
      _oauthSession = null;
      _atProto = null;
      _did = null;
      _handle = null;
      _pdsEndpoint = null;
      _oauthServer = null;
      _oauthClient = null;
      _pendingContext = null;
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout failed', error: e);
    }
  }

  @override
  Future<bool> validateSession() async {
    // Wait for initialization to complete first
    await initializationComplete;

    if (_atProto == null || _oauthSession == null) {
      _logger.d('No session to validate');
      return false;
    }

    try {
      _logger.d('Validating OAuth session for user: $_handle');
      await _atProto!.identity.resolveHandle(handle: _handle ?? '');
      _logger.d('Session validation successful');
      return true;
    } catch (e) {
      _logger.w(
        'Session validation failed, attempting token refresh',
        error: e,
      );

      // Try to refresh the token before giving up
      final refreshed = await refreshToken();
      if (refreshed) {
        _logger.i('Token refresh successful, session is now valid');
        return true;
      }

      _logger.w('Token refresh failed, logging out');
      await logout();
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      if (_oauthSession == null || _oauthClient == null) {
        _logger.w('No OAuth session or client to refresh');

        // Try to recreate OAuth client if we have a session but no client
        if (_oauthSession != null && _oauthServer != null) {
          final metadata = await getClientMetadata(_clientMetadataUrl);
          _oauthClient = OAuthClient(metadata, service: _oauthServer!);
          _logger.d('OAuthClient recreated with service: $_oauthServer');
        } else {
          _logger.w('Cannot refresh: missing session or OAuth server');
          return false;
        }
      }

      _logger.i('Refreshing OAuth token');
      final refreshedSession = await _oauthClient!.refresh(_oauthSession!);
      _oauthSession = refreshedSession;

      final pdsHost = _pdsEndpoint != null
          ? Uri.parse(_pdsEndpoint!).host
          : null;
      _atProto = ATProto.fromOAuthSession(
        _oauthSession!,
        service: pdsHost,
      );

      await _saveSession();
      _logger.i('OAuth token refresh successful');
      return true;
    } catch (e) {
      _logger.e('OAuth token refresh failed', error: e);
      // Don't logout here - let the caller decide what to do
      return false;
    }
  }
}
