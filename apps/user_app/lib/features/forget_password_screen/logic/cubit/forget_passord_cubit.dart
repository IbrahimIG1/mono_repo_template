import 'package:monorepo_template/features/forget_password_screen/logic/cubit/forget_passord_state.dart';
import 'package:monorepo_template/features/forget_password_screen/logic/repo/forget_password_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepo forgetPasswordRepo;
  ForgetPasswordCubit(this.forgetPasswordRepo)
    : super(ForgetPassordInitialState());

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);

  //* Form Key
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //* Controllers
  TextEditingController phoneNumberController = TextEditingController();

  //* Phone Number
  PhoneNumber phoneNumber = PhoneNumber(isoCode: "SA", dialCode: "+966");

  void changePhoneNumber(PhoneNumber number) => phoneNumber = number;

  Future<void> forgetPassword() async {
    emit(ForgetPasswordLoadingState());
    final result = await forgetPasswordRepo.forgetPassword(
      phoneNumber: phoneNumber.phoneNumber!,
    );
    result.fold(
      (error) => emit(ForgetPasswordErrorState(error)),
      (success) => emit(ForgetPasswordSuccessState()),
    );
  }

  Future<void> sendVerificationCode(String phone) async {
    emit(ForgetPasswordLoadingState());

    final response = await forgetPasswordRepo.requestOtpCode(phone.trim());
    response.fold(
      (error) {
        emit(ForgetPasswordErrorState(error));
      },
      (success) {
        emit(ForgetPasswordOtpSuccessState());
      },
    );
  }
}
