import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/storage/storage.dart';

/// Authentication service for AT Protocol
/// Handles user session management and authentication operations
class AuthService {
  Session? _session;
  ATProto? _atProto;

  bool get isAuthenticated => _session != null;
  Session? get session => _session;
  ATProto? get atproto => _atProto;

  AuthService() {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final savedSessionJson = await StorageManager.instance.secure.getString(StorageKeys.userSession);

      if (savedSessionJson == null) {
        return;
      }

      _session = Session.fromJson(json.decode(savedSessionJson));
      if (_session == null) {
        return;
      }

      if (!_session!.active || _isTokenExpired(_session!.accessTokenJwt)) {
        await _refreshSession();
        return;
      }

      _atProto = ATProto.fromSession(_session!);
    } catch (e) {
      // Session loading failed, continue with no session
    }
  }

  bool _isTokenExpired(Jwt token) {
    return DateTime.now().isAfter(token.exp.subtract(const Duration(minutes: 5)));
  }

  String? _extractPdsDomain(Map<String, dynamic> doc) {
    final services = doc['service'] as List<dynamic>?;
    if (services == null || services.isEmpty) return null;

    final pdsService = services.firstWhere((s) => s['id'] == '#atproto_pds', orElse: () => {});

    final String? pdsUrl = pdsService['serviceEndpoint'] as String?;
    if (pdsUrl == null) return null;

    return pdsUrl.replaceFirst('http://', '').replaceFirst('https://', '').replaceFirst('/', '');
  }

  Future<void> _refreshSession() async {
    try {
      if (_session == null) {
        throw Exception('No refresh token available');
      }

      String? service = _session!.didDoc != null ? _extractPdsDomain(_session!.didDoc!) : null;

      if (service == null) {
        final didDocResponse = await http.get(Uri.parse('https://plc.directory/${_session!.did}'));
        if (didDocResponse.statusCode == 200) {
          service = _extractPdsDomain(json.decode(didDocResponse.body));
        }
      }

      if (service == null) {
        throw Exception('Could not determine service endpoint');
      }

      final response = await refreshSession(service: service, refreshJwt: _session!.refreshJwt);

      if (response.status != HttpStatus.ok) {
        throw Exception('Failed to refresh session: ${response.status}');
      }

      _session = response.data;

      await _saveSession(_session!);
      _atProto = ATProto.fromSession(_session!);
    } catch (e) {
      await _clearSavedSession();
      _session = null;
      _atProto = null;
    }
  }

  Future<void> _saveSession(Session sessionData) async {
    try {
      final sessionJson = sessionData.toJson();
      await StorageManager.instance.secure.setString(StorageKeys.userSession, json.encode(sessionJson));
    } catch (e) {
      // Failed to save session
    }
  }

  Future<void> _clearSavedSession() async {
    try {
      await StorageManager.instance.secure.remove(StorageKeys.userSession);
    } catch (e) {
      // Failed to clear session
    }
  }

  /// Attempts to log in a user with the provided credentials
  /// 
  /// [handle] - The user handle
  /// [password] - The user password
  /// [authCode] - Optional authentication code for two-factor authentication
  /// 
  /// Returns [LoginResult] indicating success or failure
  Future<LoginResult> login(String handle, String password, {String? authCode}) async {
    try {
      ATProto at = ATProto.anonymous(service: 'pds.sprk.so');
      final didRes = await at.identity.resolveHandle(handle: handle);
      String did = didRes.data.did;

      final didDocResponse = await http.get(Uri.parse('https://plc.directory/$did'));

      if (didDocResponse.statusCode != 200) {
        throw Exception('Failed to fetch DID document: ${didDocResponse.statusCode}');
      }

      final didDoc = json.decode(didDocResponse.body);

      String? pdsUrl =
          (didDoc['service'] as List<dynamic>).firstWhere((s) => s['id'] == '#atproto_pds', orElse: () => {})['serviceEndpoint']
              as String?;

      if (pdsUrl == null) {
        throw Exception('PDS endpoint not found in DID document');
      }

      String pdsDomain = Uri.parse(pdsUrl).host;

      try {
        final session = await createSession(
          identifier: handle,
          password: password,
          service: pdsDomain,
          authFactorToken: authCode,
        );

        _session = session.data;
        if (_session == null) {
          throw Exception('Failed to create session');
        }

        _atProto = ATProto.fromSession(_session!);
        await _saveSession(_session!);

        return LoginResult.success();
      } catch (e) {
        if (e.toString().contains('401') &&
            (e.toString().contains('sign in code') ||
                e.toString().contains('sign-in code') ||
                e.toString().contains('verification code'))) {
          return LoginResult.codeRequired('Authentication code required. Check your email for a verification code.');
        }
        rethrow;
      }
    } catch (e) {
      return LoginResult.failed(e.toString());
    }
  }

  /// Registers a new user account
  /// 
  /// [handle] - The user handle
  /// [email] - The user email
  /// [password] - The user password
  /// [inviteCode] - Optional invite code for restricted registrations
  /// 
  /// Returns [bool] indicating success or failure and [String?] error message if failed
  Future<(bool, String?)> register(String handle, String email, String password, String? inviteCode) async {
    try {
      ATProto at = ATProto.anonymous(service: 'pds.sprk.so');
      final createResponse = await at.server.createAccount(
        handle: handle,
        email: email,
        password: password,
        inviteCode: inviteCode,
      );
      if (createResponse.status != HttpStatus.ok) {
        throw Exception('Failed to create account: ${createResponse.status}');
      }

      Session session = Session.fromJson({
        'did': createResponse.data.did,
        'handle': handle,
        'email': email,
        'emailConfirmed': false,
        'accessJwt': createResponse.data.accessJwt,
        'refreshJwt': createResponse.data.refreshJwt,
        'didDoc': createResponse.data.didDoc,
        'active': true,
      });

      _session = session;
      if (_session == null) {
        throw Exception('Failed to create session');
      }

      _atProto = ATProto.fromSession(_session!);

      await _saveSession(_session!);

      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    try {
      if (_atProto != null) {
        await _clearSavedSession();
        _session = null;
        _atProto = null;
      }
    } catch (e) {
      // Logout failed
    }
  }

  /// Validates if the current session is still active
  /// Returns true if valid, false otherwise
  Future<bool> validateSession() async {
    if (_atProto == null || _session == null) return false;

    try {
      await _atProto!.identity.resolveHandle(handle: _session!.handle);
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  /// Refreshes the authentication token
  /// Returns true if the session was successfully refreshed
  Future<bool> refreshToken() async {
    try {
      await _refreshSession();
      return _session != null;
    } catch (e) {
      return false;
    }
  }
}

/// Result of a login attempt
class LoginResult {
  final LoginStatus status;
  final String? error;

  LoginResult.success() : status = LoginStatus.success, error = null;
  LoginResult.failed(this.error) : status = LoginStatus.failed;
  LoginResult.codeRequired(this.error) : status = LoginStatus.codeRequired;
  
  bool get isSuccess => status == LoginStatus.success;
  bool get isCodeRequired => status == LoginStatus.codeRequired;
}

/// Login status enumeration
enum LoginStatus { 
  success, 
  failed, 
  codeRequired 
} 