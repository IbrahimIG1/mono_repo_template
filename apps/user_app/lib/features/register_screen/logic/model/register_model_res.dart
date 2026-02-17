import 'package:shared/models/user_mode.dart';

class RegisterModelResponse {
  UserModel user;
  int statusCode;
  String status;

  RegisterModelResponse({
    required this.user,
    required this.statusCode,
    required this.status,
  });

  factory RegisterModelResponse.fromJson(Map<String, dynamic> json) =>
      RegisterModelResponse(
        user: UserModel.fromJson(json["data"]),
        statusCode: json["statusCode"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": user.toJson(),
    "statusCode": statusCode,
    "status": status,
  };
}

