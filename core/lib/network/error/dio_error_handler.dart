import 'package:dio/dio.dart';
import 'package:core/network/error/error_model.dart';

class DioExceptionHandler {
  static ErrorModel handleDioError(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final String? statusMessage = error.response?.statusMessage;
    String message = "An unknown error occurred.";

    if (statusCode == 502 || statusCode == 501 || statusCode == 504) {
      message = "Server Error: Bad gateway.\nPlease try again later.";
    } else if (statusCode == 413) {
      message = "Image is Too Large. Max allowed is 5MB.";
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = "Connection timed out. Please try again.";
    } else if (error.type == DioExceptionType.sendTimeout) {
      message = "Request timed out. Please try again.";
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = "Response timed out. Please try again.";
    } else if (error.type == DioExceptionType.connectionError) {
      message = "Failed to connect to the server.";
    } else if (error.type == DioExceptionType.badCertificate) {
      message = "Invalid SSL Certificate.";
    } else if (error.type == DioExceptionType.badResponse &&
        error.response != null) {
      return _handleServerError(error.response!);
    } else if (error.type == DioExceptionType.cancel) {
      message = "Request was cancelled.";
    } else if (error.type == DioExceptionType.unknown) {
      message = "Unexpected error occurred. Check your connection.";
    }

    return ErrorModel(
      message: message,
      status: statusMessage ?? "Unknown",
      statusCode: statusCode ?? 0,
    );
  }

  static ErrorModel _handleServerError(Response response) {
    final data = response.data;
    return ErrorModel(
      message: data['message'] ?? "Server error.",
      status: data['status'] ?? "error",
      statusCode: data['statusCode'] ?? response.statusCode ?? 0,
    );
  }
}

