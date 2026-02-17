import 'package:sandwich_app/features/reset_password_screen/logic/cubit/reset_passord_state.dart';
import 'package:sandwich_app/features/reset_password_screen/logic/models/reset_password_req.dart';
import 'package:sandwich_app/features/reset_password_screen/logic/repo/reset_password_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepo resetPasswordRepo;
  ResetPasswordCubit(this.resetPasswordRepo)
    : super(ResetPasswordInitialState());

  static ResetPasswordCubit get(context) => BlocProvider.of(context);

  //* Form Key
  final formKey = GlobalKey<FormState>();

  //* Controllers
  TextEditingController phoneNumberController = TextEditingController();
  var passwordController = TextEditingController();
  var repeatPasswordController = TextEditingController();
  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;
  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> resetPassword({
    required String otpCode,
    required PhoneNumber phoneNumber,
  }) async {
    emit(ResetPasswordLoadingState());
    final result = await resetPasswordRepo.resetPassword(
      resetPasswordReq: ResetPasswordReq(
        phoneNumber: phoneNumber.phoneNumber.toString(),
        code: otpCode,
        newPassword: passwordController.text,
      ),
    );
    result.fold(
      (error) => emit(ResetPasswordErrorState(error)),
      (success) => emit(ResetPasswordSuccessState()),
    );
  }
}
