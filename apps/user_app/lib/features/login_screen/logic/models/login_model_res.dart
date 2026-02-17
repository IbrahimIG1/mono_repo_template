import 'package:shared/models/user_mode.dart';

class LoginModelResponse {
  String token;
  String refreshToken;
  UserModel user;

  LoginModelResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginModelResponse.fromJson(Map<String, dynamic> json) =>
      LoginModelResponse(
        token: json["token"],
        refreshToken: json["refreshToken"],
        user: UserModel.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
    "token": token,
    "refreshToken": refreshToken,
    "user": user.toJson(),
  };
}

