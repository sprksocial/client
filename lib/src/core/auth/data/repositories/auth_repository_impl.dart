import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:atproto/atproto.dart';
import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:spark/src/core/auth/data/models/aip_session_response.dart';
import 'package:spark/src/core/auth/data/models/auth_snapshot.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/storage/storage.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

typedef AtprotoSessionFetcher =
    Future<({String did, String handle})> Function(ATProto atproto);

const String _redirectUriValue = 'sprk://oauth-callback';
const String _clientName = 'Spark Mobile App';
const String _clientUri = 'https://sprk.so';
const String _softwareId = 'spark-mobile';
const String _softwareVersion = '1.0.0';
const Duration _refreshLeeway = Duration(minutes: 5);
const String _randomCharset =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

List<String> _buildAipScopes() {
  return const <String>['atproto', 'transition:generic'];
}

String _buildAipScope() => _buildAipScopes().join(' ');

bool _registrationScopeMatches(AipClientRegistration registration) {
  return registration.scope == _buildAipScope();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    LocalStorageInterface? secureStorage,
    http.Client? httpClient,
    SparkLogger? logger,
    DateTime Function()? now,
    AtprotoSessionFetcher? fetchSessionInfo,
  }) : _secureStorage = secureStorage ?? StorageManager.instance.secure,
       _httpClient = httpClient ?? http.Client(),
       _logger = logger ?? _buildLogger(),
       _now = now ?? DateTime.now,
       _fetchSessionInfo = fetchSessionInfo ?? _defaultFetchSessionInfo,
       _aipBaseUri = _normalizeBaseUri(AppConfig.aipBaseUrl) {
    _initialize();
  }

  final LocalStorageInterface _secureStorage;
  final http.Client _httpClient;
  final SparkLogger _logger;
  final DateTime Function() _now;
  final AtprotoSessionFetcher _fetchSessionInfo;
  final Uri _aipBaseUri;
  final List<String> _aipScopes = _buildAipScopes();
  final Completer<void> _initCompleter = Completer<void>();

  Future<bool>? _refreshInFlight;
  int _authGeneration = 0;
  AuthSnapshot? _snapshot;
  OAuthSession? _oauthSession;
  ATProto? _atProto;
  String? _did;
  String? _handle;
  String? _pdsEndpoint;

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
  String? get lastKnownHandle => _handle ?? _snapshot?.pdsSessionCache?.handle;

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
    } catch (e, stackTrace) {
      _logger.e(
        'AuthRepository initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e, stackTrace);
      }
    }
  }

  Future<void> _loadSavedSession() async {
    final snapshot = await _loadSnapshotFromStorage();
    if (snapshot == null) {
      return;
    }

    final cachedSession = snapshot.pdsSessionCache;
    if (cachedSession != null && _isFresh(cachedSession.expiresAtDateTime)) {
      try {
        _applyCachedPdsSession(cachedSession);
        return;
      } catch (e, stackTrace) {
        _logger.w(
          'Failed to restore cached PDS session, falling back to AIP bootstrap',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    if (snapshot.aipGrant != null) {
      final refreshed = await _refreshAuthState();
      if (!refreshed) {
        _resetInMemorySession();
      }
      return;
    }

    if (snapshot.pdsSessionCache != null) {
      _resetInMemorySession();
    }
  }

  Future<AuthSnapshot?> _loadSnapshotFromStorage() async {
    final snapshotJson = await _secureStorage.getString(StorageKeys.account);
    if (snapshotJson == null) {
      _snapshot = null;
      return null;
    }

    try {
      final payload = _decodeJsonObject(snapshotJson);
      final snapshot = await _parseStoredAuthSnapshot(payload);
      _snapshot = snapshot;
      return snapshot;
    } catch (e, stackTrace) {
      _logger.w(
        'Clearing legacy or invalid auth snapshot',
        error: e,
        stackTrace: stackTrace,
      );
      await _removeAllAuthStorage();
      _snapshot = null;
      return null;
    }
  }

  Future<AuthSnapshot> _parseStoredAuthSnapshot(
    Map<String, dynamic> payload,
  ) async {
    final version = payload['version'];
    if (version != null) {
      return AuthSnapshot.fromJson(payload);
    }

    throw const FormatException(
      'Legacy auth payloads are no longer supported.',
    );
  }

  void _applyCachedPdsSession(PdsSessionCache cache) {
    final normalizedCache = cache.copyWith(
      publicKey: normalizeDpopKeyEncoding(cache.publicKey),
      privateKey: normalizeDpopKeyEncoding(cache.privateKey),
    );
    _oauthSession = restorePdsOAuthSessionFromCache(normalizedCache);
    _did = normalizedCache.did;
    _handle = normalizedCache.handle;
    _pdsEndpoint = normalizedCache.pdsEndpoint;
    _atProto = ATProto.fromOAuthSession(
      _oauthSession!,
      service: Uri.parse(normalizedCache.pdsEndpoint).host,
    );
    if (normalizedCache.publicKey != cache.publicKey ||
        normalizedCache.privateKey != cache.privateKey) {
      _snapshot = (_snapshot ?? const AuthSnapshot()).copyWith(
        pdsSessionCache: normalizedCache,
      );
      unawaited(_saveSnapshot());
    }
  }

  Future<void> _saveSnapshot() async {
    final snapshot = _snapshot;
    if (snapshot == null || snapshot.isEmpty) {
      await _secureStorage.remove(StorageKeys.account);
      return;
    }

    await _secureStorage.setString(
      StorageKeys.account,
      snapshot.toJsonString(),
    );
  }

  Future<void> _saveCurrentPdsSession() async {
    final oauthSession = _oauthSession;
    final did = _did;
    final handle = _handle;
    final pdsEndpoint = _pdsEndpoint;
    if (oauthSession == null ||
        did == null ||
        handle == null ||
        pdsEndpoint == null) {
      return;
    }

    _snapshot = (_snapshot ?? const AuthSnapshot()).copyWith(
      pdsSessionCache: PdsSessionCache(
        accessToken: oauthSession.accessToken,
        expiresAt: oauthSession.expiresAt.toIso8601String(),
        did: did,
        handle: handle,
        pdsEndpoint: pdsEndpoint,
        scope: oauthSession.scope,
        dpopNonce: oauthSession.$dPoPNonce,
        publicKey: oauthSession.$publicKey,
        privateKey: oauthSession.$privateKey,
      ),
    );
    await _saveSnapshot();
  }

  Future<void> _clearPendingContext() async {
    await _secureStorage.remove(StorageKeys.pendingAuthContext);
  }

  Future<void> _removeAllAuthStorage() async {
    await _secureStorage.remove(StorageKeys.account);
    await _secureStorage.remove(StorageKeys.pendingAuthContext);
    await _secureStorage.remove(StorageKeys.userSession);
  }

  void _invalidateInFlightRefreshes() {
    _authGeneration += 1;
  }

  bool _isCurrentAuthGeneration(int generation) {
    return generation == _authGeneration;
  }

  Future<void> _waitForInFlightRefresh() async {
    final inFlight = _refreshInFlight;
    if (inFlight == null) {
      return;
    }

    try {
      await inFlight;
    } catch (_) {
      // Ignore the refresh outcome here. Callers are invalidating it anyway.
    }
  }

  Future<void> _clearSessionState({required bool preserveRegistration}) async {
    _invalidateInFlightRefreshes();
    await _waitForInFlightRefresh();

    final registration = preserveRegistration
        ? _snapshot?.aipClientRegistration
        : null;

    _snapshot = registration == null
        ? null
        : AuthSnapshot(aipClientRegistration: registration);

    await _clearPendingContext();
    await _secureStorage.remove(StorageKeys.userSession);
    await _saveSnapshot();
    _resetInMemorySession();
  }

  void _resetInMemorySession() {
    _oauthSession = null;
    _atProto = null;
    _did = null;
    _handle = null;
    _pdsEndpoint = null;
  }

  bool _isFresh(DateTime expiresAt) {
    return expiresAt.isAfter(_now().toUtc().add(_refreshLeeway));
  }

  bool _credentialsNeedRefresh(oauth2.Credentials credentials) {
    final expiration = credentials.expiration;
    if (expiration == null) {
      return false;
    }

    return expiration.isBefore(_now().toUtc().add(_refreshLeeway));
  }

  bool _registrationNeedsRefresh(AipClientRegistration registration) {
    final expiration = registration.clientSecretExpiresAtDateTime;
    if (expiration == null) {
      return false;
    }

    return expiration.isBefore(_now().toUtc().add(_refreshLeeway));
  }

  Future<_AipOAuthMetadata> _discoverOAuthMetadata() async {
    final response = await _httpClient.get(
      _aipBaseUri.resolve('/.well-known/oauth-authorization-server'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch AIP OAuth metadata: '
                '${response.statusCode} ${response.reasonPhrase ?? ''}'
            .trim(),
      );
    }

    return _AipOAuthMetadata.fromJson(
      _decodeJsonObject(response.body),
      baseUri: _aipBaseUri,
    );
  }

  Future<AipClientRegistration> _ensureClientRegistration(
    _AipOAuthMetadata metadata,
  ) async {
    final existing = _snapshot?.aipClientRegistration;
    if (existing != null &&
        !_registrationNeedsRefresh(existing) &&
        _registrationScopeMatches(existing)) {
      return existing;
    }

    final response = await _httpClient.post(
      metadata.registrationEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'client_name': _clientName,
        'client_uri': _clientUri,
        'redirect_uris': [_redirectUriValue],
        'response_types': ['code'],
        'grant_types': ['authorization_code', 'refresh_token'],
        'token_endpoint_auth_method': 'client_secret_post',
        'scope': _buildAipScope(),
        'software_id': _softwareId,
        'software_version': _softwareVersion,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'AIP client registration failed: ${_responseError(response)}',
      );
    }

    final registration = _AipClientRegistrationResponse.fromJson(
      _decodeJsonObject(response.body),
    ).toStoredRegistration(scope: _buildAipScope());

    final previousClientId = existing?.clientId;
    _snapshot = (_snapshot ?? const AuthSnapshot()).copyWith(
      aipClientRegistration: registration,
      aipGrant: previousClientId == registration.clientId
          ? _snapshot?.aipGrant
          : null,
    );
    await _saveSnapshot();
    return registration;
  }

  oauth2.AuthorizationCodeGrant _createAuthorizationGrant(
    _AipOAuthMetadata metadata,
    AipClientRegistration registration,
    String codeVerifier,
  ) {
    return oauth2.AuthorizationCodeGrant(
      registration.clientId,
      metadata.authorizationEndpoint,
      metadata.tokenEndpoint,
      secret: registration.clientSecret,
      basicAuth: false,
      httpClient: _httpClient,
      codeVerifier: codeVerifier,
    );
  }

  Future<void> _storePendingContext(PendingAipAuthContext context) async {
    await _secureStorage.setString(
      StorageKeys.pendingAuthContext,
      context.toJsonString(),
    );
  }

  Future<PendingAipAuthContext?> _readPendingContext() async {
    final raw = await _secureStorage.getString(StorageKeys.pendingAuthContext);
    if (raw == null) {
      return null;
    }

    return PendingAipAuthContext.fromJsonString(raw);
  }

  String _generateRandomToken(int length) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _randomCharset[random.nextInt(_randomCharset.length)],
    ).join();
  }

  @override
  Future<String> initiateOAuth(String handle) async {
    return _startOAuthFlow(loginHint: handle.trim());
  }

  @override
  Future<String> initiateOAuthWithService(String service) async {
    if (service.isNotEmpty) {
      _logger.d(
        'Ignoring initiateOAuthWithService service hint in AIP auth mode: $service',
      );
    }

    return _startOAuthFlow();
  }

  Future<String> _startOAuthFlow({String? loginHint}) async {
    try {
      final metadata = await _discoverOAuthMetadata();
      final registration = await _ensureClientRegistration(metadata);
      final state = _generateRandomToken(32);
      final codeVerifier = _generateRandomToken(64);
      final redirectUri = Uri.parse(_redirectUriValue);
      final grant = _createAuthorizationGrant(
        metadata,
        registration,
        codeVerifier,
      );

      var authorizationUri = grant.getAuthorizationUrl(
        redirectUri,
        scopes: _aipScopes,
        state: state,
      );

      if (loginHint != null && loginHint.isNotEmpty) {
        authorizationUri = authorizationUri.replace(
          queryParameters: {
            ...authorizationUri.queryParameters,
            'login_hint': loginHint,
          },
        );
      }

      await _storePendingContext(
        PendingAipAuthContext(
          clientId: registration.clientId,
          state: state,
          codeVerifier: codeVerifier,
          redirectUri: redirectUri.toString(),
        ),
      );

      return authorizationUri.toString();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initiate AIP OAuth',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<LoginResult> completeOAuth(String callbackUrl) async {
    AuthSnapshot? previousSnapshot;
    try {
      await initializationComplete;
      previousSnapshot = _snapshot;

      final context = await _readPendingContext();
      if (context == null) {
        return LoginResult.failed(
          'OAuth session was interrupted. Please start again.',
        );
      }

      _snapshot ??= await _loadSnapshotFromStorage();
      final registration = _snapshot?.aipClientRegistration;
      if (registration == null || registration.clientId != context.clientId) {
        return LoginResult.failed(
          'OAuth client registration was lost. Please try again.',
        );
      }

      final metadata = await _discoverOAuthMetadata();
      final grant = _createAuthorizationGrant(
        metadata,
        registration,
        context.codeVerifier,
      );

      grant.getAuthorizationUrl(
        Uri.parse(context.redirectUri),
        scopes: _aipScopes,
        state: context.state,
      );

      final client = await grant.handleAuthorizationResponse(
        Uri.parse(callbackUrl).queryParameters,
      );

      _snapshot = (_snapshot ?? const AuthSnapshot()).copyWith(
        aipGrant: AipGrant(credentialsJson: client.credentials.toJson()),
      );
      await _saveSnapshot();

      final bootstrapped = await _bootstrapPdsSession(
        client.credentials,
        authGeneration: _authGeneration,
      );
      if (!bootstrapped) {
        _snapshot = previousSnapshot;
        await _saveSnapshot();
        _resetInMemorySession();
        return LoginResult.failed(
          'Failed to bootstrap a direct PDS session from AIP.',
        );
      }

      return LoginResult.success();
    } catch (e, stackTrace) {
      _logger.e('AIP OAuth callback failed', error: e, stackTrace: stackTrace);
      _snapshot = previousSnapshot;
      await _saveSnapshot();
      _resetInMemorySession();
      return LoginResult.failed(e.toString());
    } finally {
      await _clearPendingContext();
    }
  }

  Future<oauth2.Credentials?> _loadAipCredentials() async {
    final aipGrant = _snapshot?.aipGrant;
    if (aipGrant == null) {
      return null;
    }

    return oauth2.Credentials.fromJson(aipGrant.credentialsJson);
  }

  Future<oauth2.Credentials?> _ensureFreshAipGrant({
    required int authGeneration,
  }) async {
    final credentials = await _loadAipCredentials();
    if (credentials == null) {
      return null;
    }

    if (!_credentialsNeedRefresh(credentials)) {
      return credentials;
    }

    return _refreshStoredAipGrant(
      credentials: credentials,
      authGeneration: authGeneration,
    );
  }

  Future<oauth2.Credentials?> _refreshStoredAipGrant({
    oauth2.Credentials? credentials,
    required int authGeneration,
  }) async {
    final currentCredentials = credentials ?? await _loadAipCredentials();
    final registration = _snapshot?.aipClientRegistration;
    if (currentCredentials == null || registration == null) {
      return null;
    }

    if (!currentCredentials.canRefresh) {
      throw Exception('Stored AIP credentials cannot be refreshed.');
    }

    final client = oauth2.Client(
      currentCredentials,
      identifier: registration.clientId,
      secret: registration.clientSecret,
      basicAuth: false,
      httpClient: _httpClient,
    );

    await client.refreshCredentials();
    final refreshed = client.credentials;
    if (!_isCurrentAuthGeneration(authGeneration)) {
      return null;
    }

    _snapshot = (_snapshot ?? const AuthSnapshot()).copyWith(
      aipGrant: AipGrant(credentialsJson: refreshed.toJson()),
    );
    await _saveSnapshot();
    return refreshed;
  }

  Future<AipAtprotocolSessionResponse> _fetchAtprotocolSession(
    oauth2.Credentials credentials,
  ) async {
    final response = await _httpClient.get(
      _aipBaseUri.resolve('/api/atprotocol/session'),
      headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'AIP session request failed: ${_responseError(response)}',
      );
    }

    return AipAtprotocolSessionResponse.fromJson(
      _decodeJsonObject(response.body),
    );
  }

  Future<bool> _bootstrapPdsSession(
    oauth2.Credentials credentials, {
    required int authGeneration,
  }) async {
    try {
      final sessionResponse = await _fetchAtprotocolSession(credentials);
      if (!_isCurrentAuthGeneration(authGeneration)) {
        return false;
      }

      final existingNonce =
          _oauthSession?.$dPoPNonce ??
          _snapshot?.pdsSessionCache?.dpopNonce ??
          '';
      final pdsSession = buildPdsSessionCacheFromAipResponse(
        sessionResponse,
        dpopNonce: existingNonce,
      );

      _snapshot = (_snapshot ?? const AuthSnapshot()).copyWith(
        pdsSessionCache: pdsSession,
      );
      await _saveSnapshot();
      if (!_isCurrentAuthGeneration(authGeneration)) {
        return false;
      }

      _applyCachedPdsSession(pdsSession);
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to bootstrap direct PDS session from AIP',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _refreshAuthState() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _refreshAuthStateInternal();
    _refreshInFlight = future;

    try {
      return await future;
    } finally {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<bool> _refreshAuthStateInternal() async {
    final authGeneration = _authGeneration;

    try {
      final credentials = await _ensureFreshAipGrant(
        authGeneration: authGeneration,
      );
      if (credentials == null) {
        return false;
      }

      return _bootstrapPdsSession(credentials, authGeneration: authGeneration);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to refresh auth state from AIP',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _clearSessionState(preserveRegistration: true);
    } catch (e, stackTrace) {
      _logger.e('Logout failed', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> validateSession() async {
    await initializationComplete;

    final atProto = _atProto;
    final did = _did;
    if (atProto == null || did == null || did.isEmpty) {
      return false;
    }

    try {
      final session = await _fetchSessionInfo(atProto);
      if (session.did != did) {
        _logger.w('Session DID mismatch. Expected $did but got ${session.did}');
        _resetInMemorySession();
        return false;
      }

      if (session.handle.isNotEmpty) {
        _handle = session.handle;
      }
      await _saveCurrentPdsSession();
      return true;
    } catch (e, stackTrace) {
      _logger.w(
        'Direct PDS session validation failed, attempting AIP rebootstrap',
        error: e,
        stackTrace: stackTrace,
      );

      final refreshed = await _refreshAuthState();
      if (!refreshed || _atProto == null) {
        _resetInMemorySession();
        return false;
      }

      try {
        final session = await _fetchSessionInfo(_atProto!);
        if (session.did != did) {
          _logger.w(
            'Session DID mismatch after AIP rebootstrap. '
            'Expected $did but got ${session.did}',
          );
          _resetInMemorySession();
          return false;
        }

        if (session.handle.isNotEmpty) {
          _handle = session.handle;
        }
        await _saveCurrentPdsSession();
        return true;
      } catch (refreshError, refreshStackTrace) {
        _logger.e(
          'Session validation failed after AIP rebootstrap',
          error: refreshError,
          stackTrace: refreshStackTrace,
        );
        _resetInMemorySession();
        return false;
      }
    }
  }

  @override
  Future<bool> refreshToken() async {
    await initializationComplete;

    final refreshed = await _refreshAuthState();
    if (!refreshed) {
      _resetInMemorySession();
    }

    return refreshed;
  }
}

Future<({String did, String handle})> _defaultFetchSessionInfo(
  ATProto atproto,
) async {
  final sessionResponse = await atproto.server.getSession();
  return (did: sessionResponse.data.did, handle: sessionResponse.data.handle);
}

SparkLogger _buildLogger() {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<LogService>()) {
    return getIt<LogService>().getLogger('AuthRepository');
  }

  return SparkLogger(name: 'AuthRepository');
}

Uri _normalizeBaseUri(String rawValue) {
  final uri = Uri.parse(rawValue);
  final trimmedPath = uri.path.length > 1 && uri.path.endsWith('/')
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;
  return uri.replace(path: trimmedPath);
}

Map<String, dynamic> _decodeJsonObject(String body) {
  final decoded = json.decode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Expected a JSON object.');
  }

  return decoded;
}

String _responseError(http.Response response) {
  try {
    final body = _decodeJsonObject(response.body);
    final description = body['error_description'] ?? body['error'];
    if (description is String && description.isNotEmpty) {
      return description;
    }
  } catch (_) {
    if (response.body.trim().isNotEmpty) {
      return response.body.trim();
    }
  }

  return '${response.statusCode} ${response.reasonPhrase ?? ''}'.trim();
}

class _AipOAuthMetadata {
  const _AipOAuthMetadata({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.registrationEndpoint,
  });

  factory _AipOAuthMetadata.fromJson(
    Map<String, dynamic> json, {
    required Uri baseUri,
  }) {
    Uri resolveEndpoint(String value) {
      final endpoint = Uri.parse(value);
      if (endpoint.hasScheme) {
        return endpoint;
      }

      return baseUri.resolveUri(endpoint);
    }

    final registrationValue =
        json['registration_endpoint'] as String? ??
        baseUri.resolve('/oauth/clients/register').toString();

    return _AipOAuthMetadata(
      authorizationEndpoint: resolveEndpoint(
        json['authorization_endpoint'] as String,
      ),
      tokenEndpoint: resolveEndpoint(json['token_endpoint'] as String),
      registrationEndpoint: resolveEndpoint(registrationValue),
    );
  }

  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri registrationEndpoint;
}

class _AipClientRegistrationResponse {
  const _AipClientRegistrationResponse({
    required this.clientId,
    this.clientSecret,
    this.registrationAccessToken,
    this.clientSecretExpiresAt,
  });

  factory _AipClientRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return _AipClientRegistrationResponse(
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String?,
      registrationAccessToken: json['registration_access_token'] as String?,
      clientSecretExpiresAt: json['client_secret_expires_at'] as int?,
    );
  }

  final String clientId;
  final String? clientSecret;
  final String? registrationAccessToken;
  final int? clientSecretExpiresAt;

  AipClientRegistration toStoredRegistration({required String scope}) {
    final secretExpiry = clientSecretExpiresAt;
    final expiryDateTime = secretExpiry == null || secretExpiry <= 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(secretExpiry * 1000, isUtc: true);

    return AipClientRegistration(
      clientId: clientId,
      clientSecret: clientSecret,
      registrationAccessToken: registrationAccessToken,
      clientSecretExpiresAt: expiryDateTime?.toIso8601String(),
      scope: scope,
    );
  }
}
