import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:core/di/di.dart';
import 'package:core/helper/extension.dart';
import 'package:core/helper/spacer.dart';
import 'package:sandwich_app/core/routing/arguments_keys.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/buttons/app_header.dart';
import 'package:shared/widgets/buttons/app_button.dart';
import 'package:shared/widgets/text_field/phone_number_widget.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:sandwich_app/features/forget_password_screen/logic/cubit/forget_passord_cubit.dart';
import 'package:sandwich_app/features/forget_password_screen/logic/cubit/forget_passord_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => getIt<ForgetPasswordCubit>(),
        child: Scaffold(
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                  listener: (context, state) {
                    if (state is ForgetPasswordErrorState) {
                      showToast(
                        msg: state.error.message,
                        state: ToastStates.ERROR,
                      );
                    }
                    if (state is ForgetPasswordSuccessState) {
                      Navigator.pushNamed(
                        context,
                        ScreensNames.otpScreen,
                        arguments: {
                          AppRoutArgumentsKeys.otpScreenPhoneNumber:
                              ForgetPasswordCubit.get(
                                context,
                              ).phoneNumber.phoneNumber.toString(),
                          AppRoutArgumentsKeys.otpScreenSendFunction: (
                            String value,
                          ) {
                            context.pushNamed(
                              ScreensNames.resetPassword,
                              arguments: {
                                AppRoutArgumentsKeys.resetPasswordPhoneNumber:
                                    ForgetPasswordCubit.get(
                                      context,
                                    ).phoneNumber,
                                AppRoutArgumentsKeys.resetPasswordOtpCode:
                                    value,
                              },
                            );
                          },
                        },
                      );
                    }
                  },
                  builder: (context, state) {
                    ForgetPasswordCubit cubit = ForgetPasswordCubit.get(
                      context,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        appHeader(context),
                        Text(
                          " طلب استعادة كلمة المرور",
                          style: AppTextStyles().fontGoldDark20Bold,
                        ),
                        verticalSpace(12.h),
                        Text(
                          "قم بإدخال رقم الجوال للتحقق من حسابك",
                          style: AppTextStyles().fontGoldDark16Meduim,
                        ),
                        verticalSpace(36.h),
                        Form(
                          key: cubit.formKey,
                          child: phoneNumberField(
                            controller: cubit.phoneNumberController,
                            getPhoneNumber: (phoneNumber) {
                              cubit.phoneNumber = phoneNumber;
                            },
                            phoneNumber: cubit.phoneNumber,
                          ),
                        ),

                        verticalSpace(24.h),
                        appDefaultButton(
                          child: ConditionalBuilder(
                            condition: state is ForgetPasswordLoadingState,
                            builder:
                                (context) => Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors().white,
                                  ),
                                ),
                            fallback:
                                (context) => Text(
                                  "ارسال",
                                  style: AppTextStyles().fontWhite16Bold,
                                ),
                          ),
                          onPressed: () async {
                            if (cubit.formKey.currentState!.validate()) {
                              cubit.forgetPassword();
                            }
                            // cubit.login();
                          },
                        ),
                      ],
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

