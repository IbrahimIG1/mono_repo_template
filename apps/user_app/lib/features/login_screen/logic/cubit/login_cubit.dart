import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/local/secure_storage_helper.dart';
import 'package:core/local/shared_prefrence.dart';
import 'package:monorepo_template/features/login_screen/logic/cubit/login_state.dart';
import 'package:monorepo_template/features/login_screen/logic/models/login_model_req.dart';
import 'package:monorepo_template/features/login_screen/logic/repo/login_repo.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;
  LoginCubit(this.loginRepo) : super(LoginInitial());
  static LoginCubit get(context) => BlocProvider.of(context);

  //* FormKey
  var loginkey = GlobalKey<FormState>();
  //* Controllers
  TextEditingController phoneNumberController = TextEditingController();
  var passwordController = TextEditingController();
  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;

  //* Phone Number
  PhoneNumber phoneNumber = PhoneNumber(isoCode: "SA", dialCode: "+966");

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> login() async {
    if (loginkey.currentState!.validate()) {
      emit(LoginLoadingState());
      var result = await loginRepo.login(
        LoginModelRequest(
          phone: phoneNumber.phoneNumber.toString(),
          password: passwordController.text,
        ),
      );

      result.fold((error) => emit(LoginErrorState(error)), (success) {
        SharedPreferencesHelper.saveBool(SharedPrefKeys.language, false);
        SharedPreferencesHelper.saveString(
          SharedPrefKeys.userId,
          success.user.id,
        );
        SharedPreferencesHelper.saveBool(
          SharedPrefKeys.userAllowChatStatus,
          success.user.allowChat,
        );
        SharedPreferencesHelper.saveBool(
          SharedPrefKeys.userMarriedStatus,
          success.user.allowKhattaba,
        );
        SharedPreferencesHelper.saveBool(
          SharedPrefKeys.userWasalStatus,
          success.user.allowKhattaba,
        );
        AppSecureStorageHelper.saveToken(SharedPrefKeys.token, success.token);
        AppSecureStorageHelper.saveToken(
          SharedPrefKeys.refreshToken,
          success.refreshToken,
        );
        emit(LoginSuccessState(success));
      });
    }
  }
}
