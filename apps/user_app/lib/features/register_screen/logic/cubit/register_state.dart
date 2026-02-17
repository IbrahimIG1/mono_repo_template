import 'package:core/network/error/error_model.dart';

sealed class RegisterState {}

final class RegisterInitialState extends RegisterState {}

final class RegisterLoadingState extends RegisterState {}

final class RegisterErrorState extends RegisterState {
  final ErrorModel error;

  RegisterErrorState(this.error);
}

final class RegisterOtpSuccessState extends RegisterState {}

final class RegisterSuccessState extends RegisterState {}

/* Password Visibility */
final class ChangePasswordVisibilityState extends RegisterState {}

/* Gender Selection */
final class ChangeGenderState extends RegisterState {}

