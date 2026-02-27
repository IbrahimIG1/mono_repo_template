import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:core/network/error/dio_error_handler.dart';
import 'package:core/network/error/error_model.dart';
import 'package:core/network/error/firebase_handeler.dart';
import 'package:monorepo_template/features/notifications_screen/ui/widgets/notification_item/notiification_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationFactory {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Firebase Messaging and request permissions
  Future<Either<dynamic, bool>> initialize() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // For iOS foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("Foreground Notification: ${message.notification?.title}");
        //* show snac bar
        notificationsUi(message);
      });
      // For background and terminated state notifications
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      return right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return left(ErrorModel(message: e.response.toString()));
      } else {
        ErrorModel error = DioExceptionHandler.handleDioError(e);
        return left(ErrorModel(message: error.message));
      }
    } on FirebaseException catch (e) {
      return left(FirebaseMessagingHandler.handleMessagingError(e));
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }

  // Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    log("Background Notification: ${message.notification?.title}");
  }

  // Get the current FCM token
  Future<Either<dynamic, String>> getFCMToken() async {
    log("Get FCM Token In Factory Function");
    try {
      final response = await _firebaseMessaging.getToken();

      return right(response.toString());
    } on FirebaseException catch (e) {
      log("Error In Get FCM Token :- ${e.toString()}");
      return left(FirebaseMessagingHandler.handleMessagingError(e));
    } catch (e) {
      return left(ErrorModel(message: e.toString()));
    }
  }

  // Listen for token refresh
  void onTokenRefresh(void Function(String token) callback) {
    log("Refresh FCM Token In Factory Function");
    _firebaseMessaging.onTokenRefresh.listen(callback);
  }
}
