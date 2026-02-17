import 'package:core/network/error/error_model.dart';

sealed class ResetPasswordState {}

final class ResetPasswordInitialState extends ResetPasswordState {}

final class ResetPasswordLoadingState extends ResetPasswordState {}

final class ResetPasswordSuccessState extends ResetPasswordState {}

final class ChangePasswordVisibilityState extends ResetPasswordState {}

final class ResetPasswordErrorState extends ResetPasswordState {
  ErrorModel error;
  ResetPasswordErrorState(this.error);
}

