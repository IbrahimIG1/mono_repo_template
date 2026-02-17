import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/helper/get_user_token.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/urls/api_constants%20.dart';
import 'package:sandwich_app/features/notifications_screen/logic/models/notification_model.dart';

class NotificationRepo {
  final ApiServices apiServices;
  NotificationRepo(this.apiServices);

  // Send FCM token to the backend
  Future<Either<ErrorModel, bool>> sendTokenToBackend({
    required String fcmToken,
  }) async {
    try {
      apiServices.post(
        token: await GetUserToken.getToken(),
        baseUrl: ApiConstants.fcmSendToBackendURL,
        data: {"fcm": fcmToken},
      );
      return right(true);
    } on DioException catch (e) {
      log("Error In Repo Notification Dio :- ${e.response.toString()}");
      if (e.response != null) {
        return left(ErrorModel(message: e.response.toString()));
      } else {
        log("Error In Repo Notification Dio Else :- ${e.response.toString()}");
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(ErrorModel(message: error.message));
      }
    } catch (e) {
      log("Error In Repo Notification catch :- ${e.toString()}");
      return left(ErrorModel(message: e.toString()));
    }
  }

  //* Get My Notifications
  Future<Either<ErrorModel, NotificationModel>> getMyNotifications() async {
    try {
      var response = await apiServices.getMap(
        baseUrl: ApiConstants.getNotifications,
        token: await GetUserToken.getToken(),
      );
      NotificationModel notificationModel = NotificationModel.fromJson(
        response,
      );
      return right(notificationModel);
    } on DioException catch (e) {
      if (e.response != null) {
        return left(ErrorModel(message: e.response.toString()));
      } else {
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(ErrorModel(message: error.message));
      }
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }

  Future<Either<ErrorModel, int>> getNotificationsCount() async {
    try {
      var response = await apiServices.getMap(
        baseUrl: ApiConstants.getNotificationsCount,
        token: await GetUserToken.getToken(),
      );

      return right(response['count']);
    } on DioException catch (e) {
      if (e.response != null) {
        return left(ErrorModel(message: e.response.toString()));
      } else {
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(ErrorModel(message: error.message));
      }
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }
  //* update Notification

  Future<Either<ErrorModel, bool>> updateNotification({
    required String notificationId,
  }) async {
    try {
      final response = await apiServices.put(
        baseUrl: "${ApiConstants.readNotification}$notificationId",
      );
      return right(response.data['isRead']);
    } on DioException catch (e) {
      if (e.response != null) {
        return left(ErrorModel(message: e.response.toString()));
      } else {
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(ErrorModel(message: error.message));
      }
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }
}

