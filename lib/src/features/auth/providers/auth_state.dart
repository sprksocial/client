import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Authentication state for the application
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    Session? session,
    ATProto? atproto,
    @Default(false) bool isLoading,
    String? error,
  }) = _AuthState;
  
  const AuthState._();
} 