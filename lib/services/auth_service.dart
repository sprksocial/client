import 'package:atproto/atproto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  dynamic _session;
  bool _isLoading = false;
  String? _error;
  ATProto? _atProto;

  // Getters
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get session => _session;
  ATProto? get atproto => _atProto;

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
        print(didDocResponse);
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
      _atProto = ATProto.fromSession(_session);
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
        // Create a new session with the ATProto client
        // final atproto = ATProto.fromSession(_session);
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

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (_atProto == null) return null;

    try {
      // final response = await _atProto!.repo.getProfile(
      //   actor: _session.did,
      // );
      return <String, dynamic>{};
      // return response.data.toJson();
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
