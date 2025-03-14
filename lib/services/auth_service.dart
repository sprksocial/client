import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  Session? _session;
  bool _isLoading = false;
  String? _error;
  ATProto? _atProto;
  static const String _sessionKey = 'user_session';

  // Getters
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Session? get session => _session;
  ATProto? get atproto => _atProto;

  // Constructor to initialize and check for saved session
  AuthService() {
    _loadSavedSession();
  }

  // Load saved session from SharedPreferences
  Future<void> _loadSavedSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionJson = prefs.getString(_sessionKey);

      if (savedSessionJson != null) {
        Map<String, dynamic> savedSession = json.decode(savedSessionJson);
        _session = Session.fromJson(savedSession);
        if (_session != null) {
          _atProto = ATProto.fromSession(_session!);
        }
      }
    } catch (e) {
      _error = 'Failed to load saved session: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save session to SharedPreferences
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

  // Clear saved session from SharedPreferences
  Future<void> _clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      _error = 'Failed to clear session: ${e.toString()}';
      notifyListeners();
    }
  }

  // Login with handle and password
  Future<bool> login(String handle, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      ATProto at = ATProto.anonymous(
        service: 'shimeji.us-east.host.bsky.network',
      );
      final didRes = await at.identity.resolveHandle(handle: handle);
      String did = didRes.data.did;

      // Fetch DID document from PLC directory
      final didDocResponse = await http.get(
        Uri.parse('https://plc.directory/$did/data'),
      );

      if (didDocResponse.statusCode != 200) {
        throw Exception(
          'Failed to fetch DID document: ${didDocResponse.statusCode}',
        );
      }

      final didDoc = json.decode(didDocResponse.body);

      // Extract PDS endpoint from DID document
      String? pdsUrl = didDoc['services']['atproto_pds']['endpoint'];

      if (pdsUrl == null) {
        throw Exception('PDS endpoint not found in DID document');
      }

      String pdsDomain = pdsUrl.replaceFirst('http://', '').replaceFirst('https://', '').replaceFirst('/', '');
      final session = await createSession(
        identifier: handle,
        password: password,
        service: pdsDomain,
      );

      _session = session.data;
      if (_session == null) {
        throw Exception('Failed to create session');
      }

      _atProto = ATProto.fromSession(_session!);

      // Save session to persistent storage
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

  // Logout
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

  // Check if session is valid
  Future<bool> validateSession() async {
    if (_atProto == null || _session == null) return false;

    try {
      // Perform a lightweight API call to check session validity
      await _atProto!.identity.resolveHandle(handle: _session!.handle);
      return true;
    } catch (e) {
      // Session is invalid, clear it
      await logout();
      return false;
    }
  }

  // Get current user profile
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
