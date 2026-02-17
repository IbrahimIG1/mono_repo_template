class ResetPasswordReq {
  final String phoneNumber;
  final String code;
  final String newPassword;

  ResetPasswordReq({
    required this.phoneNumber,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone': phoneNumber,
      'code': code,
      'newPassword': newPassword,
    };
  }

  factory ResetPasswordReq.fromJson(Map<String, dynamic> map) {
    return ResetPasswordReq(
      phoneNumber: map['phone'],
      code: map['code'],
      newPassword: map['newPassword'],
    );
  }
}
