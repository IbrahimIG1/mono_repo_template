import 'dart:developer';
import 'package:monorepo_template/features/notifications_screen/logic/cubit/notification_state.dart';
import 'package:monorepo_template/features/notifications_screen/logic/models/notification_model.dart';
import 'package:monorepo_template/features/notifications_screen/logic/notification_factory.dart';
import 'package:monorepo_template/features/notifications_screen/logic/repo/notification_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationFactory notificationFactory;
  final NotificationRepo notificationRepository;

  NotificationCubit(this.notificationFactory, this.notificationRepository)
    : super(NotificationInitial());
  static NotificationCubit get(context) => BlocProvider.of(context);

  // Initialize Notifications
  Future<void> initializeNotifications() async {
    log("Start Initialize Notifications In Cubit");
    await notificationFactory.initialize();
    // Retrieve FCM Token
    final result = await notificationFactory.getFCMToken();
    result.fold(
      (error) {
        // log("Error In Get FCM Token :- ${error.errormsg}");
        emit(GetFCMTokenError(error)); // Emit error state
      },
      (success) async {
        log("Get FCM Token In Cubit :- $success");
        await sendTokenToBackend(success);
        emit(GetFCMTokenSuccess());
      },
    );
  }

  // Send FCM Token to Backend
  Future<void> sendTokenToBackend(String token) async {
    final success = await notificationRepository.sendTokenToBackend(
      fcmToken: token,
    );
    success.fold(
      (error) {
        log("Error In Send Token :- ${error.toString()}");
        emit(SendFCMTokenError(error)); // Emit error state
      },
      (success) {
        log("Send FCM Token To backend In Cubit :- $token");
        emit(GetFCMTokenSuccess());
      },
    );
  }

  //* get my notifications
  NotificationModel? notificationModel;

  Future<void> getMyNotifications() async {
    emit(GetMyNotificationsLoading());
    log("Start Notification Func");

    final result = await notificationRepository.getMyNotifications();
    result.fold(
      (error) {
        log("Error In Get My Notifications :- ${error.message}");
        emit(GetMyNotificationsError(error)); // Emit error state
      },
      (success) {
        if (!isClosed) {
          notificationNumber = success.notifications.length;
          notificationModel = success;
          log("Get My Notifications In Cubit :- $success");
          emit(GetMyNotificationsSuccess()); // Emit success state
        }
      },
    );
  }
  //* get my notificationsCount

  int notificationNumber = 0;
  Future<void> getMyNotificationsCount() async {
    log("Starting getMyNotificationsCount");

    final result = await notificationRepository.getNotificationsCount();

    result.fold(
      (error) {
        log("Error fetching notifications count: ${error.message}");
        if (!isClosed) emit(GetMyNotificationsCountError(error));
      },
      (count) {
        log("Fetched notifications count: $count");
        if (!isClosed) {
          notificationNumber = count;
          emit(GetMyNotificationsSuccess());
        }
      },
    );
  }

  Future<void> updateNotifications(String notificationId, bool isRead) async {
    if (!isRead) {
      await notificationRepository.updateNotification(
        notificationId: notificationId,
      );
      getMyNotificationsCount();
    }
  }
}
