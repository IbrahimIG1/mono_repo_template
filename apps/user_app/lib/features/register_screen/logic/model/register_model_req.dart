class RegisterModelRequest {
    String userName;
    String phone;
    String code;
    String password;
    String gender;


    RegisterModelRequest({
        required this.userName,
        required this.phone,
        required this.code,
        required this.password,
        required this.gender,

    });

    factory RegisterModelRequest.fromJson(Map<String, dynamic> json) => RegisterModelRequest(
        userName: json["userName"],
        phone: json["phone"],
        code: json["code"],
        password: json["password"],
        gender: json["gender"],

    );

    Map<String, dynamic> toJson() => {
        "userName": userName,
        "phone": phone,
        "code": code,
        "password": password,
        "gender": gender,

    };
}
