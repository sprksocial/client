import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/auth/data/models/login_status.dart';

part 'login_result.freezed.dart';

/// Result of a login attempt
@freezed
class LoginResult with _$LoginResult {
  const factory LoginResult({
    required LoginStatus status,
    String? error,
  }) = _LoginResult;
  const LoginResult._();

  factory LoginResult.success() => const LoginResult(status: LoginStatus.success);
  factory LoginResult.failed(String error) => LoginResult(status: LoginStatus.failed, error: error);
  factory LoginResult.codeRequired(String error) => LoginResult(status: LoginStatus.codeRequired, error: error);

  bool get isSuccess => status == LoginStatus.success;
  bool get isCodeRequired => status == LoginStatus.codeRequired;
}
