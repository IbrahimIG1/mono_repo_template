import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/urls/api_constants%20.dart';
import 'package:sandwich_app/features/login_screen/logic/repo/login_repo.dart';
import 'package:sandwich_app/features/otp_screen/logic/repo/otp_repo.dart';
import 'package:sandwich_app/features/register_screen/logic/model/register_model_req.dart';

class RegisterRepo extends OtpRepo {
  @override
  final ApiServices apiServices;

  RegisterRepo(this.apiServices) : super(apiServices);

  Future<Either<ErrorModel, void>> register(
    RegisterModelRequest registerData,
  ) async {
    try {
      final response = await apiServices.post(
        baseUrl: ApiConstants.registerUrl,
        data: registerData.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        final error = handleErrorResponse(response.data);
        if (error != null) {
          return left(error);
        }
      }

      // Parse successful response
      // RegisterModelResponse registerModelResponse =
      //     RegisterModelResponse.fromJson(response.data);
      return right(null);
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

