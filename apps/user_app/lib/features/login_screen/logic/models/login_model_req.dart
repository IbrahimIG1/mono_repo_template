
class LoginModelRequest {
    String phone;
    String password;

    LoginModelRequest({
        required this.phone,
        required this.password,
    });

    factory LoginModelRequest.fromJson(Map<String, dynamic> json) => LoginModelRequest(
        phone: json["phone"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "phone": phone,
        "password": password,
    };
}
