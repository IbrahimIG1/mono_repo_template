import 'package:core/network/error/error_model.dart';

sealed class ForgetPasswordState {}

final class ForgetPassordInitialState extends ForgetPasswordState {}

final class ForgetPasswordLoadingState extends ForgetPasswordState {}

final class ForgetPasswordSuccessState extends ForgetPasswordState {}

final class ForgetPasswordOtpSuccessState extends ForgetPasswordState {}

final class ForgetPasswordErrorState extends ForgetPasswordState {
  ErrorModel error;
  ForgetPasswordErrorState(this.error);
}

