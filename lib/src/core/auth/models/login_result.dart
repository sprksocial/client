import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/auth/models/login_status.dart';

part 'login_result.freezed.dart';
part 'login_result.g.dart';

/// Result of a login attempt
@freezed
class LoginResult with _$LoginResult {
  const factory LoginResult({
    required LoginStatus status,
    String? error,
  }) = _LoginResult;

  factory LoginResult.success() => const LoginResult(status: LoginStatus.success);
  factory LoginResult.failed(String error) => LoginResult(status: LoginStatus.failed, error: error);
  factory LoginResult.codeRequired(String error) => LoginResult(status: LoginStatus.codeRequired, error: error);

  factory LoginResult.fromJson(Map<String, dynamic> json) => _$LoginResultFromJson(json);

  const LoginResult._();

  bool get isSuccess => status == LoginStatus.success;
  bool get isCodeRequired => status == LoginStatus.codeRequired;
} 