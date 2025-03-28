import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum LoginStatus { success, failed, codeRequired }

class AuthService extends ChangeNotifier {
  Session? _session;
  bool _isLoading = false;
  String? _error;
  ATProto? _atProto;
  static const String _sessionKey = 'user_session';

  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Session? get session => _session;
  ATProto? get atproto => _atProto;

  AuthService() {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionJson = prefs.getString(_sessionKey);

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
      _error = 'Failed to load saved session: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isTokenExpired(Jwt token) {
    try {
      return DateTime.now().isAfter(token.exp.subtract(const Duration(minutes: 5)));
    } catch (e) {
      print('Failed to check token expiry: $e');
      return true;
    }
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
      _error = 'Failed to refresh session: ${e.toString()}';
      await _clearSavedSession();
      _session = null;
      _atProto = null;
    }
  }

  Future<void> _saveSession(Session sessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = sessionData.toJson();
      await prefs.setString(_sessionKey, json.encode(sessionJson));
    } catch (e) {
      _error = 'Failed to save session: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      _error = 'Failed to clear session: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<LoginStatus> login(String handle, String password, {String? authCode}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      ATProto at = ATProto.anonymous(service: 'shimeji.us-east.host.bsky.network');
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

        _isLoading = false;
        notifyListeners();
        return LoginStatus.success;
      } catch (e) {
        if (e.toString().contains('401') &&
            (e.toString().contains('sign in code') ||
                e.toString().contains('sign-in code') ||
                e.toString().contains('verification code'))) {
          _error = 'Authentication code required. Check your email for a verification code.';
          _isLoading = false;
          notifyListeners();
          return LoginStatus.codeRequired;
        }
        rethrow;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return LoginStatus.failed;
    }
  }

  Future<bool> register(String handle, String email, String password, String? inviteCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_atProto != null) {
        await _clearSavedSession();
        _session = null;
        _atProto = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (_atProto == null) return null;

    try {
      final response = await _atProto!.repo.getRecord(uri: AtUri.parse('at://${_session!.did}/app.bsky.actor.profile/self'));
      return response.data.toJson();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
