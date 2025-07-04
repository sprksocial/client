import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_auth_models.freezed.dart';
part 'messages_auth_models.g.dart';

@freezed
abstract class MessagesUser with _$MessagesUser {
  factory MessagesUser({required String did, required String handle, String? displayName}) = _MessagesUser;
  factory MessagesUser.fromJson(Map<String, dynamic> json) => _$MessagesUserFromJson(json);
}

@freezed
abstract class MessagesAuthResponse with _$MessagesAuthResponse {
  factory MessagesAuthResponse({required String accessToken, required String refreshToken, required MessagesUser user}) =
      _MessagesAuthResponse;

  factory MessagesAuthResponse.fromJson(Map<String, dynamic> json) => _$MessagesAuthResponseFromJson(json);
}
