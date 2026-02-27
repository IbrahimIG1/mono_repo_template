import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/urls/api_constants%20.dart';
import 'package:monorepo_template/features/login_screen/logic/models/login_model_req.dart';
import 'package:monorepo_template/features/login_screen/logic/models/login_model_res.dart';

class LoginRepo {
  final ApiServices apiServices;

  LoginRepo(this.apiServices);

  Future<Either<ErrorModel, LoginModelResponse>> login(
    LoginModelRequest loginData,
  ) async {
    try {
      final response = await apiServices.post(
        baseUrl: ApiConstants.loginUrl,
        data: loginData.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final error = handleErrorResponse(response.data);
        if (error != null) {
          return left(error);
        }
      }

      // Parse successful response
      LoginModelResponse loginModelResponse = LoginModelResponse.fromJson(
        response.data,
      );
      return right(loginModelResponse);
    } on DioException catch (e) {
      if (e.response != null) {
        print("DioException : ${e.response!.data['message']}");
        return left(
          ErrorModel(
            message: e.response!.data['message'] ?? "Unknown error",
            statusCode: e.response!.statusCode,
            status: e.response!.data['status'],
          ),
        );
      } else {
        print("DioException else : ${e.message}");
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(error);
      }
    } catch (e) {
      print("catch : ${e.toString()}");
      return left(ErrorModel(message: e.toString()));
    }
  }
}

ErrorModel? handleErrorResponse(Map<String, dynamic> responseData) {
  if (responseData.containsKey('message') &&
      responseData.containsKey('statusCode')) {
    return ErrorModel(
      message: responseData['message'] ?? "Unknown error",
      statusCode: responseData['statusCode'],
      status: responseData['status'],
    );
  }
  return null; // Return null if the response doesn't match the error structure
}
