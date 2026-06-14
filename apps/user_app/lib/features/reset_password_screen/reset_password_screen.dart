import 'package:core/di/di.dart';
import 'package:core/helper/extension.dart';
import 'package:core/helper/spacer.dart';
import 'package:monorepo_template/core/routing/screens_names.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/buttons/app_header.dart';
import 'package:shared/widgets/buttons/app_button.dart';
import 'package:shared/widgets/text_field/app_text_form_feild.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:monorepo_template/features/reset_password_screen/logic/cubit/reset_passord_cubit.dart';
import 'package:monorepo_template/features/reset_password_screen/logic/cubit/reset_passord_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String otpCode;
  final PhoneNumber phoneNumber;
  const ResetPasswordScreen({
    super.key,
    required this.otpCode,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => getIt<ResetPasswordCubit>(),
        child: Scaffold(
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                  listener: (context, state) {
                    if (state is ResetPasswordSuccessState) {
                      showToast(
                        msg: "تم تحديث كلمة المرور",
                        state: ToastStates.SUCCESS,
                      );
                      context.pushReplacementNamed(ScreensNames.login);
                    }
                    if (state is ResetPasswordErrorState) {
                      showToast(
                        msg: state.error.message,
                        state: ToastStates.ERROR,
                      );
                    }
                  },
                  builder: (context, state) {
                    ResetPasswordCubit cubit = ResetPasswordCubit.get(context);
                    return Form(
                      key: cubit.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          appHeader(context),
                          Text(
                            "تعيين كلمة مرور جديدة",
                            style: AppTextStyles().fontGoldDark20Bold,
                          ),
                          verticalSpace(12.h),
                          Text(
                            "قم بتعيين كلمة المرور الجديدة حتى تتمكن من تسجيل الدخول والوصول إلى حسابك",
                            style: AppTextStyles().fontGoldDark16Meduim,
                          ),
                          verticalSpace(36.h),
                          AppTextFormFeild(
                            controller: cubit.passwordController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return (value!.isEmpty)
                                  ? "من فضلك ادخل كلمة السر"
                                  : null;
                            },
                            obscure: cubit.isPassword,
                            label: Text("كلمة المرور"),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                cubit.changePasswordVisibility();
                              },
                              child: Icon(cubit.suffix),
                            ),
                          ),
                          verticalSpace(24.h),
                          AppTextFormFeild(
                            controller: cubit.repeatPasswordController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return (value!.isEmpty)
                                  ? "من فضلك ادخل كلمة السر"
                                  : null;
                            },
                            obscure: cubit.isPassword,
                            label: Text("تأكيد كلمة المرور"),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                cubit.changePasswordVisibility();
                              },
                              child: Icon(cubit.suffix),
                            ),
                          ),
                          verticalSpace(24.h),
                          appDefaultButton(
                            color: AppColors().mainColor,
                            titleStyle: AppTextStyles().fontWhite16Bold,
                            text: "إرسال",
                            onPressed: () {
                              if (cubit.formKey.currentState!.validate()) {
                                if (cubit.passwordController.text !=
                                    cubit.repeatPasswordController.text) {
                                  showToast(
                                    msg: "كلمة المرور غير متطابقة",
                                    state: ToastStates.ERROR,
                                  );
                                  return;
                                } else {
                                  cubit.resetPassword(
                                    otpCode: otpCode,
                                    phoneNumber: phoneNumber,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
