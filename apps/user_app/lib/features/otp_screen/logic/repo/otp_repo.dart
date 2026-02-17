import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/urls/api_constants%20.dart';

class OtpRepo {
  final ApiServices apiServices;
  OtpRepo(this.apiServices);

  Future<Either<ErrorModel, String>> requestOtpCode(String phone) async {
    try {
      final response = await apiServices.post(
        baseUrl: ApiConstants.requestOtpCode,
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        return right(response.data['message'] ?? "Verification code sent.");
      } else {
        return left(
          ErrorModel(message: response.data['message'] ?? "Unknown error"),
        );
      }
    } on DioException catch (e) {
      return left(DioExceptionHandler.handleDioError(e));
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }
}

