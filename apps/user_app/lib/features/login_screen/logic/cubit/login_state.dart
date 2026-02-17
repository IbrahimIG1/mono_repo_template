import 'package:core/network/error/error_model.dart';
import 'package:sandwich_app/features/login_screen/logic/models/login_model_res.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class ChangePasswordVisibilityState extends LoginState {}

final class LoginLoadingState extends LoginState {}

final class LoginErrorState extends LoginState {
  final ErrorModel error;
  LoginErrorState(this.error);
}

final class LoginSuccessState extends LoginState {
  final LoginModelResponse loginModelResponse;
  LoginSuccessState(this.loginModelResponse);
}

