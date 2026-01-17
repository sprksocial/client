import 'dart:convert';

/// Represents a stored user account with all authentication data
class Account {
  const Account({
    required this.accessToken,
    required this.refreshToken,
    required this.publicKey,
    required this.privateKey,
    this.dpopNonce,
    this.expiresAt,
    this.did,
    this.handle,
    this.pdsEndpoint,
    this.server,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      publicKey: json['publicKey'] as String,
      privateKey: json['privateKey'] as String,
      dpopNonce: json['dpopNonce'] as String?,
      expiresAt: json['expiresAt'] as String?,
      did: json['did'] as String?,
      handle: json['handle'] as String?,
      pdsEndpoint: json['pdsEndpoint'] as String?,
      server: json['server'] as String?,
    );
  }

  factory Account.fromJsonString(String jsonString) {
    return Account.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  final String accessToken;
  final String refreshToken;
  final String publicKey;
  final String privateKey;
  final String? dpopNonce;
  final String? expiresAt;
  final String? did;
  final String? handle;
  final String? pdsEndpoint;
  final String? server;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'publicKey': publicKey,
      'privateKey': privateKey,
      'dpopNonce': dpopNonce,
      'expiresAt': expiresAt,
      'did': did,
      'handle': handle,
      'pdsEndpoint': pdsEndpoint,
      'server': server,
    };
  }

  String toJsonString() => json.encode(toJson());

  Account copyWith({
    String? accessToken,
    String? refreshToken,
    String? publicKey,
    String? privateKey,
    String? dpopNonce,
    String? expiresAt,
    String? did,
    String? handle,
    String? pdsEndpoint,
    String? server,
  }) {
    return Account(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      dpopNonce: dpopNonce ?? this.dpopNonce,
      expiresAt: expiresAt ?? this.expiresAt,
      did: did ?? this.did,
      handle: handle ?? this.handle,
      pdsEndpoint: pdsEndpoint ?? this.pdsEndpoint,
      server: server ?? this.server,
    );
  }
}
