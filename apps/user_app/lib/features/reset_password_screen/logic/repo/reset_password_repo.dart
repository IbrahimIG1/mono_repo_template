import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/urls/api_constants%20.dart';
import 'package:monorepo_template/features/reset_password_screen/logic/models/reset_password_req.dart';

class ResetPasswordRepo {
  final ApiServices apiServices;
  ResetPasswordRepo(this.apiServices);

  Future<Either<ErrorModel, void>> resetPassword({
    required ResetPasswordReq resetPasswordReq,
  }) async {
    try {
      final response = await apiServices.patch(
        baseUrl: ApiConstants.resetPassword,
        data: resetPasswordReq.toJson(),
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
