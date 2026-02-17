import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/urls/api_constants%20.dart';
import 'package:sandwich_app/features/otp_screen/logic/repo/otp_repo.dart';

class ForgetPasswordRepo extends OtpRepo {
  @override
  final ApiServices apiServices;
  ForgetPasswordRepo(this.apiServices) : super(apiServices);

  Future<Either<ErrorModel, void>> forgetPassword({
    required String phoneNumber,
  }) async {
    try {
      final response = await apiServices.post(
        baseUrl: ApiConstants.forgetPassword,
        data: {'phone': phoneNumber},
      );

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(
          ErrorModel(message: response.data['message'] ?? "Unknown error"),
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return left(
          ErrorModel(
            message: e.response!.data['message'] ?? "Unknown error",
            statusCode: e.response!.statusCode,
            status: e.response!.data['status'],
          ),
        );
      } else {
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(error);
      }
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }
}

