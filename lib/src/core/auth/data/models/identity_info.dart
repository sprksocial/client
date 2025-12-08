import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity_info.freezed.dart';
part 'identity_info.g.dart';

/// Represents identity information in the AT Protocol
@freezed
abstract class IdentityInfo with _$IdentityInfo {
  const factory IdentityInfo({
    /// Decentralized Identifier (DID)
    required String did,

    /// User handle (username)
    required String handle,

    /// DID Document containing identity details
    Map<String, dynamic>? didDocument,
  }) = _IdentityInfo;

  factory IdentityInfo.fromJson(Map<String, dynamic> json) => _$IdentityInfoFromJson(json);
}

/// Represents the state of identity resolution operations
@freezed
class IdentityState with _$IdentityState {
  /// Loading state
  const factory IdentityState.loading() = _Loading;

  /// Successfully resolved identity
  const factory IdentityState.success(IdentityInfo identityInfo) = _Success;

  /// Error during resolution
  const factory IdentityState.error(String message) = _Error;
}
