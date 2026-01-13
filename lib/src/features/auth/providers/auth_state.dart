import 'package:atproto/atproto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Authentication state for the application using OAuth
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    String? did,
    String? handle,
    String? dmAccessToken,
    ATProto? atproto,
    @Default(false) bool isLoading,
    String? error,
  }) = _AuthState;

  const AuthState._();
}
