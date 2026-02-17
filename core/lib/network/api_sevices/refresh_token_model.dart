class RefreshTokenModel {
    String accessToken;
    String refreshToken;

    RefreshTokenModel({
        required this.accessToken,
        required this.refreshToken,
    });

    factory RefreshTokenModel.fromJson(Map<String, dynamic> json) => RefreshTokenModel(
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
    );

    Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "refreshToken": refreshToken,
    };
}