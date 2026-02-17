import 'package:core/network/error/error_model.dart';

abstract class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class GetFCMTokenSuccess extends NotificationState {}

final class GetFCMTokenError extends NotificationState {
  ErrorModel errorModel;
  GetFCMTokenError(this.errorModel);
}

final class SendFCMTokenSuccess extends NotificationState {}

final class SendFCMTokenError extends NotificationState {
  ErrorModel errorModel;
  SendFCMTokenError(this.errorModel);
}

final class GetMyNotificationsLoading extends NotificationState {
  GetMyNotificationsLoading();
}

final class GetMyNotificationsSuccess extends NotificationState {
  GetMyNotificationsSuccess();
}

final class GetMyNotificationsError extends NotificationState {
  ErrorModel errorModel;
  GetMyNotificationsError(this.errorModel);
}

final class GetMyNotificationsCountSuccess extends NotificationState {
  int notificationCount;
  GetMyNotificationsCountSuccess(this.notificationCount);
}

final class GetMyNotificationsCountError extends NotificationState {
  ErrorModel errorModel;
  GetMyNotificationsCountError(this.errorModel);
}

final class UpdateNotificationsSuccess extends NotificationState {
  UpdateNotificationsSuccess();
}

final class UpdateNotificationsError extends NotificationState {
  ErrorModel errorModel;
  UpdateNotificationsError(this.errorModel);
}

final class MarkAsReadNSuccess extends NotificationState {
  MarkAsReadNSuccess();
}

