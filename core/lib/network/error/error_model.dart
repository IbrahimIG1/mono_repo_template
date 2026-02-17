class ErrorModel {
  final String message;
  final int? statusCode;
  final String? status;

  ErrorModel({required this.message, this.statusCode, this.status}); 
}
