import 'dart:convert';
import 'dart:async';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/auth/data/models/login_result.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

/// Implementation of the authentication repository for AT Protocol
class AuthRepositoryImpl implements AuthRepository {
  Session? _session;
  ATProto? _atProto;
  String? _dmAccessToken;
  String? _dmRefreshToken;

  final _logger = GetIt.instance<LogService>().getLogger('AuthRepository');

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;

  @override
  bool get isAuthenticated => _session != null;

  @override
  Session? get session => _session;

  @override
  ATProto? get atproto => _atProto;

  @override
  String? get dmAccessToken => _dmAccessToken;

  @override
  String? get dmRefreshToken => _dmRefreshToken;

  AuthRepositoryImpl() {
    _logger.i('Initializing AuthRepository');
    _initialize();
  }

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

  String? _extractPdsDomain(Map<String, dynamic> doc) {
    final services = doc['service'] as List<dynamic>?;
    if (services == null || services.isEmpty) {
      return null;
    }

    final pdsService = services.firstWhere((s) => s['id'] == '#atproto_pds', orElse: () => {});

    final String? pdsUrl = pdsService['serviceEndpoint'] as String?;
    if (pdsUrl == null) {
      return null;
    }

    return pdsUrl.replaceFirst('http://', '').replaceFirst('https://', '').replaceFirst('/', '');
  }

  bool _isTokenExpired(Jwt token) {
    return DateTime.now().isAfter(token.exp.subtract(const Duration(minutes: 5)));
  }

  /// Logs in the message service
  Future<void> loginMessageService() async {
    try {
      _logger.i('Logging in to message service');
      final response = await http.post(
        Uri.parse('${AppConfig.messagesServiceUrl}/auth/login'),
        headers: {'Content-Type': 'application/json', 'did': _session!.did, 'jwt': _session!.accessTokenJwt.toString()},
        body: jsonEncode({'accessJwt': _session!.accessTokenJwt, 'refreshJwt': _session!.refreshJwt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _dmAccessToken = data['access_token'];
        _dmRefreshToken = data['refresh_token'];
        await StorageManager.instance.secure.setString(StorageKeys.dmAccessToken, _dmAccessToken!);
        await StorageManager.instance.secure.setString(StorageKeys.dmRefreshToken, _dmRefreshToken!);
        _logger.i('Logged in to message service successfully');
      } else {
        throw Exception('Failed to login to message service: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Failed to login to message service', error: e);
      rethrow;
    }
  }

  Future<void> _loadSavedSession() async {
    try {
      _logger.d('Loading saved session');
      final savedSessionJson = await StorageManager.instance.secure.getString(StorageKeys.userSession);

      if (savedSessionJson == null) {
        _logger.d('No saved session found');
        return;
      }

      _session = Session.fromJson(json.decode(savedSessionJson));
      if (_session == null) {
        _logger.w('Failed to parse saved session');
        return;
      }

      if (!_session!.active || _isTokenExpired(_session!.accessTokenJwt)) {
        _logger.i('Session inactive or token expired, refreshing');
        await _refreshSession();
        return;
      }

      _atProto = ATProto.fromSession(_session!);

      _dmAccessToken = await StorageManager.instance.secure.getString(StorageKeys.dmAccessToken);
      _dmRefreshToken = await StorageManager.instance.secure.getString(StorageKeys.dmRefreshToken);
      if (_dmAccessToken == null) {
        _logger.w('DM access token not found, refreshing DM token');
        if (!await _refreshDMToken()) {
          _logger.e('Failed to refresh DM token, trying to login again');
          await loginMessageService();
        }
      }

      try {
        final response = await http.get(
          Uri.parse('${AppConfig.messagesServiceUrl}/auth/session'),
          headers: {'Authorization': 'Bearer $_dmAccessToken'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _dmAccessToken = data['access_token'];
          _dmRefreshToken = data['refresh_token'];
        } else {
          if (!await _refreshDMToken()) {
            _logger.e('Failed to refresh DM token, trying to login again');
            await loginMessageService();
          }
        }
      } catch (e) {
        if (!await _refreshDMToken()) {
          _logger.e('Failed to refresh DM token, trying to login again');
          await loginMessageService();
        }
      }

      _logger.i('Session loaded successfully for user: ${_session!.handle}');
    } catch (e) {
      _logger.e('Error loading saved session', error: e);
      rethrow;
    }
  }

  Future<bool> _refreshDMToken() async {
    final response = await http.post(
      Uri.parse('${AppConfig.messagesServiceUrl}/auth/refresh'),
      headers: {'Content-Type': 'application/json', 'Cookie': 'refresh_token=$refreshToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await StorageManager.instance.secure.setString(StorageKeys.dmAccessToken, data['access_token']);
      _dmAccessToken = data['access_token'];
      _dmRefreshToken = data['refresh_token'];
      await StorageManager.instance.secure.setString(StorageKeys.dmRefreshToken, data['refresh_token']);
      return true;
    }
    return false;
  }

  Future<void> _refreshSession() async {
    try {
      if (_session == null) {
        _logger.w('No refresh token available');
        throw Exception('No refresh token available');
      }

      _logger.i('Refreshing session for user: ${_session!.handle}');
      String? service = _session!.didDoc != null ? _extractPdsDomain(_session!.didDoc!) : null;

      if (service == null) {
        _logger.d('Fetching DID document from PLC directory');
        final didDocResponse = await http.get(Uri.parse('https://plc.directory/${_session!.did}'));
        if (didDocResponse.statusCode == 200) {
          service = _extractPdsDomain(json.decode(didDocResponse.body));
        }
      }

      if (service == null) {
        _logger.e('Could not determine service endpoint');
        throw Exception('Could not determine service endpoint');
      }

      _logger.d('Using service endpoint: $service');
      final response = await refreshSession(service: service, refreshJwt: _session!.refreshJwt);

      if (response.status != HttpStatus.ok) {
        _logger.e('Failed to refresh session: ${response.status}');
        throw Exception('Failed to refresh session: ${response.status}');
      }

      _session = response.data;

      await _refreshDMToken();

      await _saveSession(_session!);
      _atProto = ATProto.fromSession(_session!);
      _logger.i('Session refreshed successfully');
    } catch (e) {
      _logger.e('Session refresh failed', error: e);
      await _clearSavedSession();
      _session = null;
      _atProto = null;
    }
  }

  Future<void> _saveSession(Session sessionData) async {
    try {
      _logger.d('Saving session for user: ${sessionData.handle}');
      final sessionJson = sessionData.toJson();
      await StorageManager.instance.secure.setString(StorageKeys.userSession, json.encode(sessionJson));
      await StorageManager.instance.secure.setString(StorageKeys.dmAccessToken, _dmAccessToken ?? '');
      await StorageManager.instance.secure.setString(StorageKeys.dmRefreshToken, _dmRefreshToken ?? '');
      _logger.d('Session saved successfully');
    } catch (e) {
      _logger.e('Failed to save session', error: e);
      // Failed to save session
    }
  }

  Future<void> _clearSavedSession() async {
    try {
      _logger.d('Clearing saved session');
      await StorageManager.instance.secure.remove(StorageKeys.userSession);
      _logger.d('Session cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear session', error: e);
      // Failed to clear session
    }
  }

  @override
  Future<LoginResult> login(String handle, String password, {String? authCode}) async {
    try {
      _logger.i('Login attempt for user: $handle');
      ATProto at = ATProto.anonymous(service: 'pds.sprk.so');
      _logger.d('Resolving handle: $handle');
      final didRes = await at.identity.resolveHandle(handle: handle);
      String did = didRes.data.did;
      _logger.d('Resolved DID: $did');

      _logger.d('Fetching DID document');
      final didDocResponse = await http.get(Uri.parse('https://plc.directory/$did'));

      if (didDocResponse.statusCode != 200) {
        _logger.e('Failed to fetch DID document: ${didDocResponse.statusCode}');
        throw Exception('Failed to fetch DID document: ${didDocResponse.statusCode}');
      }

      final didDoc = json.decode(didDocResponse.body);

      String? pdsUrl =
          (didDoc['service'] as List<dynamic>).firstWhere((s) => s['id'] == '#atproto_pds', orElse: () => {})['serviceEndpoint']
              as String?;

      if (pdsUrl == null) {
        _logger.e('PDS endpoint not found in DID document');
        throw Exception('PDS endpoint not found in DID document');
      }

      String pdsDomain = Uri.parse(pdsUrl).host;
      _logger.d('Using PDS domain: $pdsDomain');

      try {
        _logger.d('Creating session');
        final session = await createSession(
          identifier: handle,
          password: password,
          service: pdsDomain,
          authFactorToken: authCode,
        );

        _session = session.data;
        if (_session == null) {
          _logger.e('Failed to create session');
          throw Exception('Failed to create session');
        }

        _atProto = ATProto.fromSession(_session!);
        await _saveSession(_session!);
        _logger.i('Login successful for user: $handle');
        await loginMessageService();

        return LoginResult.success();
      } catch (e) {
        if (e.toString().contains('401') &&
            (e.toString().contains('sign in code') ||
                e.toString().contains('sign-in code') ||
                e.toString().contains('verification code'))) {
          _logger.i('Authentication code required for user: $handle');
          return LoginResult.codeRequired('Authentication code required. Check your email for a verification code.');
        }
        rethrow;
      }
    } catch (e) {
      _logger.e('Login failed', error: e);
      return LoginResult.failed(e.toString());
    }
  }

  @override
  Future<({bool success, String? error})> register(String handle, String email, String password, String? inviteCode) async {
    try {
      _logger.i('Registration attempt for handle: $handle, email: $email');
      ATProto at = ATProto.anonymous(service: 'pds.sprk.so');
      _logger.d('Creating account');
      final createResponse = await at.server.createAccount(
        handle: handle,
        email: email,
        password: password,
        inviteCode: inviteCode,
      );
      if (createResponse.status != HttpStatus.ok) {
        _logger.e('Failed to create account: ${createResponse.status}');
        throw Exception('Failed to create account: ${createResponse.status}');
      }

      _logger.d('Account created, creating session');
      await login(handle, password);

      _session = session;
      if (_session == null) {
        _logger.e('Failed to create session after registration');
        throw Exception('Failed to create session');
      }

      _atProto = ATProto.fromSession(_session!);

      await _saveSession(_session!);
      _logger.i('Registration successful for user: $handle');

      return (success: true, error: null);
    } catch (e) {
      _logger.e('Registration failed', error: e);
      return (success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (_atProto != null) {
        _logger.i('Logging out user: ${_session?.handle}');
        await _clearSavedSession();
        _session = null;
        _atProto = null;
        _dmAccessToken = null;
        _dmRefreshToken = null;
        await http.post(
          Uri.parse('${AppConfig.messagesServiceUrl}/auth/logout'),
          headers: {'Authorization': 'Bearer $_dmAccessToken', 'Cookie': 'refresh_token=$_dmRefreshToken'},
        );
        _logger.i('Logout successful');
      }
    } catch (e) {
      _logger.e('Logout failed', error: e);
      // Logout failed
    }
  }

  @override
  Future<bool> validateSession() async {
    if (_atProto == null || _session == null) {
      _logger.d('No session to validate');
      return false;
    }

    try {
      _logger.d('Validating session for user: ${_session!.handle}');
      await _atProto!.identity.resolveHandle(handle: _session!.handle);
      _logger.d('Session validation successful');
      return true;
    } catch (e) {
      _logger.w('Session validation failed, logging out', error: e);
      await logout();
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      _logger.i('Refreshing token');
      await _refreshSession();
      final result = _session != null;
      _logger.i(result ? 'Token refresh successful' : 'Token refresh failed');
      return result;
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
      return false;
    }
  }
}
