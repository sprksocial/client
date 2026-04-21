import 'dart:convert';

const Object _missingValue = Object();

class AuthSnapshot {
  const AuthSnapshot({
    this.version = currentVersion,
    this.aipClientRegistration,
    this.aipGrant,
    this.pdsSessionCache,
  });

  factory AuthSnapshot.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int?;
    if (version != currentVersion) {
      throw const FormatException('Unsupported auth snapshot version.');
    }

    return AuthSnapshot(
      version: version!,
      aipClientRegistration: json['aipClientRegistration'] == null
          ? null
          : AipClientRegistration.fromJson(
              json['aipClientRegistration'] as Map<String, dynamic>,
            ),
      aipGrant: json['aipGrant'] == null
          ? null
          : AipGrant.fromJson(json['aipGrant'] as Map<String, dynamic>),
      pdsSessionCache: json['pdsSessionCache'] == null
          ? null
          : PdsSessionCache.fromJson(
              json['pdsSessionCache'] as Map<String, dynamic>,
            ),
    );
  }

  factory AuthSnapshot.fromJsonString(String jsonString) {
    return AuthSnapshot.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  static const int currentVersion = 2;

  final int version;
  final AipClientRegistration? aipClientRegistration;
  final AipGrant? aipGrant;
  final PdsSessionCache? pdsSessionCache;

  bool get isEmpty =>
      aipClientRegistration == null &&
      aipGrant == null &&
      pdsSessionCache == null;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'aipClientRegistration': aipClientRegistration?.toJson(),
      'aipGrant': aipGrant?.toJson(),
      'pdsSessionCache': pdsSessionCache?.toJson(),
    };
  }

  String toJsonString() => json.encode(toJson());

  AuthSnapshot copyWith({
    Object? aipClientRegistration = _missingValue,
    Object? aipGrant = _missingValue,
    Object? pdsSessionCache = _missingValue,
  }) {
    return AuthSnapshot(
      version: version,
      aipClientRegistration: identical(aipClientRegistration, _missingValue)
          ? this.aipClientRegistration
          : aipClientRegistration as AipClientRegistration?,
      aipGrant: identical(aipGrant, _missingValue)
          ? this.aipGrant
          : aipGrant as AipGrant?,
      pdsSessionCache: identical(pdsSessionCache, _missingValue)
          ? this.pdsSessionCache
          : pdsSessionCache as PdsSessionCache?,
    );
  }
}

class AipClientRegistration {
  const AipClientRegistration({
    required this.clientId,
    this.clientSecret,
    this.registrationAccessToken,
    this.clientSecretExpiresAt,
  });

  factory AipClientRegistration.fromJson(Map<String, dynamic> json) {
    return AipClientRegistration(
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String?,
      registrationAccessToken: json['registrationAccessToken'] as String?,
      clientSecretExpiresAt: json['clientSecretExpiresAt'] as String?,
    );
  }

  final String clientId;
  final String? clientSecret;
  final String? registrationAccessToken;
  final String? clientSecretExpiresAt;

  DateTime? get clientSecretExpiresAtDateTime {
    final value = clientSecretExpiresAt;
    if (value == null || value.isEmpty) return null;
    return DateTime.parse(value);
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'registrationAccessToken': registrationAccessToken,
      'clientSecretExpiresAt': clientSecretExpiresAt,
    };
  }
}

class AipGrant {
  const AipGrant({required this.credentialsJson});

  factory AipGrant.fromJson(Map<String, dynamic> json) {
    return AipGrant(credentialsJson: json['credentialsJson'] as String);
  }

  final String credentialsJson;

  Map<String, dynamic> toJson() {
    return {'credentialsJson': credentialsJson};
  }
}

class PdsSessionCache {
  const PdsSessionCache({
    required this.accessToken,
    required this.expiresAt,
    required this.did,
    required this.handle,
    required this.pdsEndpoint,
    required this.scope,
    required this.dpopNonce,
    required this.publicKey,
    required this.privateKey,
  });

  factory PdsSessionCache.fromJson(Map<String, dynamic> json) {
    return PdsSessionCache(
      accessToken: json['accessToken'] as String,
      expiresAt: json['expiresAt'] as String,
      did: json['did'] as String,
      handle: json['handle'] as String,
      pdsEndpoint: json['pdsEndpoint'] as String,
      scope: json['scope'] as String,
      dpopNonce: json['dpopNonce'] as String? ?? '',
      publicKey: json['publicKey'] as String,
      privateKey: json['privateKey'] as String,
    );
  }

  final String accessToken;
  final String expiresAt;
  final String did;
  final String handle;
  final String pdsEndpoint;
  final String scope;
  final String dpopNonce;
  final String publicKey;
  final String privateKey;

  DateTime get expiresAtDateTime => DateTime.parse(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt,
      'did': did,
      'handle': handle,
      'pdsEndpoint': pdsEndpoint,
      'scope': scope,
      'dpopNonce': dpopNonce,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }

  PdsSessionCache copyWith({
    String? accessToken,
    String? expiresAt,
    String? did,
    String? handle,
    String? pdsEndpoint,
    String? scope,
    String? dpopNonce,
    String? publicKey,
    String? privateKey,
  }) {
    return PdsSessionCache(
      accessToken: accessToken ?? this.accessToken,
      expiresAt: expiresAt ?? this.expiresAt,
      did: did ?? this.did,
      handle: handle ?? this.handle,
      pdsEndpoint: pdsEndpoint ?? this.pdsEndpoint,
      scope: scope ?? this.scope,
      dpopNonce: dpopNonce ?? this.dpopNonce,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
    );
  }
}

class PendingAipAuthContext {
  const PendingAipAuthContext({
    required this.clientId,
    required this.state,
    required this.codeVerifier,
    required this.redirectUri,
  });

  factory PendingAipAuthContext.fromJson(Map<String, dynamic> json) {
    return PendingAipAuthContext(
      clientId: json['clientId'] as String,
      state: json['state'] as String,
      codeVerifier: json['codeVerifier'] as String,
      redirectUri: json['redirectUri'] as String,
    );
  }

  factory PendingAipAuthContext.fromJsonString(String jsonString) {
    return PendingAipAuthContext.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  final String clientId;
  final String state;
  final String codeVerifier;
  final String redirectUri;

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'state': state,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    };
  }

  String toJsonString() => json.encode(toJson());
}
