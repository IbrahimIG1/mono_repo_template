import 'package:monorepo_template/features/register_screen/logic/cubit/register_state.dart';
import 'package:monorepo_template/features/register_screen/logic/model/register_model_req.dart';
import 'package:monorepo_template/features/register_screen/logic/repo/register_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo registerRepo;
  RegisterCubit(this.registerRepo) : super(RegisterInitialState());
  static RegisterCubit get(context) => BlocProvider.of(context);

  //* formKey
  final formKey = GlobalKey<FormState>();
  //* Controllers
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  //* Phone Number
  PhoneNumber phoneNumber = PhoneNumber(isoCode: "SA", dialCode: "+966");

  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;

  //* Gender Selection
  bool isMale = true;

  void changeGender(bool value) {
    isMale = value;
    emit(ChangeGenderState());
  }

  bool isTermsConfirmed = false;

  void changeTermsConfirmed(bool? value) {
    isTermsConfirmed = value ?? false;
    emit(ChangeGenderState());
  }

  bool isCommitmentConfirmed = false;

  void changeCommitmentConfirmed(bool? value) {
    isCommitmentConfirmed = value ?? false;
    emit(ChangeGenderState());
  }

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> sendVerificationCode(String phone) async {
    emit(RegisterLoadingState());

    final response = await registerRepo.requestOtpCode(phone.trim());
    response.fold(
      (error) {
        emit(RegisterErrorState(error));
      },
      (success) {
        emit(RegisterOtpSuccessState());
      },
    );
  }

  Future<void> register(String otpCode) async {
    emit(RegisterLoadingState());
    final result = await registerRepo.register(
      RegisterModelRequest(
        userName: userNameController.text,
        password: passwordController.text,
        gender: isMale ? "Male" : "Female",
        code: otpCode,
        phone: phoneNumber.phoneNumber.toString(),
      ),
    );
    result.fold((l) => emit(RegisterErrorState(l)), (r) {
      emit(RegisterSuccessState());
    });
  }
}
