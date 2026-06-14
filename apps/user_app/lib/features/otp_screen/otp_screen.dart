import 'package:core/di/di.dart';
import 'package:core/helper/spacer.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/buttons/app_header.dart';
import 'package:shared/widgets/buttons/app_button.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:monorepo_template/features/otp_screen/logic/cubit/otp_cubit.dart';
import 'package:monorepo_template/features/otp_screen/logic/cubit/otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  final Function(String) sendFunction;
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.sendFunction,
  });

  @override
  Widget build(BuildContext context) {
    String lastPhoneNumber = phoneNumber.substring(
      phoneNumber.length - 3,
      phoneNumber.length,
    );
    return BlocProvider(
      create: (_) => getIt<OtpCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state is OtpErrorState) {
                showToast(
                  msg: state.errorModel.message,
                  state: ToastStates.ERROR,
                );
              }
            },
            builder: (context, state) {
              OtpCubit otpCubit = OtpCubit.get(context);

              int seconds = 180;
              bool canResend = false;

              if (state is OtpTimerState) {
                seconds = state.remainingSeconds;
                canResend = state.canResend;
              }

              String formatTime(int seconds) {
                int minutes = (seconds / 60).floor();
                int remainingSeconds = seconds % 60;
                return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appHeader(context),
                      Text(
                        'تحقق من حسابك',
                        style: AppTextStyles().fontGoldDark20Bold,
                      ),
                      verticalSpace(12.h),
                      Text(
                        'تم إرسال كود التحقق على رقم الجوال المنتهي ب $lastPhoneNumber، أدخل الرمز الخاص بك المكون من 4 أرقام',
                        style: AppTextStyles().fontGoldDark16Meduim,
                      ),
                      verticalSpace(24.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Form(
                          key: otpCubit.formKey,
                          child: PinCodeTextField(
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'من فضلك ادخل الكود'
                                        : null,
                            controller: otpCubit.otpController,
                            scrollPadding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                            ),
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            appContext: context,
                            length: 6,
                            obscureText: false,
                            textStyle: AppTextStyles().fontGold20Bold,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              print(value);
                              otpCubit.otpController.text = value;
                              print(otpCubit.otpController.text);
                            },
                            pinTheme: PinTheme(
                              errorBorderColor: AppColors().red,

                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10.r),
                              fieldHeight: 50.h,
                              fieldWidth: 50.w,
                              activeColor: AppColors().mainColor,
                              selectedColor: AppColors().mainColor,
                              inactiveColor: AppColors().greyLight,
                              inactiveFillColor: AppColors().greyLight,
                              activeFillColor: AppColors().mainColor,
                              selectedFillColor: AppColors().mainColor,
                              disabledColor: AppColors().greyLight,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(24.h),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              formatTime(seconds),
                              style: AppTextStyles().fontGold16Meduim,
                            ),
                            verticalSpace(16.h),
                            GestureDetector(
                              onTap:
                                  canResend
                                      ? () {
                                        otpCubit.startTimer();
                                        otpCubit.sendVerificationCode(
                                          phoneNumber,
                                        );
                                      }
                                      : null,
                              child: Text(
                                "لم تحصل على الكود بعد؟ أعد إرساله",
                                style:
                                    canResend
                                        ? AppTextStyles().fontGoldDark14Meduim
                                        : AppTextStyles().fontGrey12SimiBold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      verticalSpace(24.h),
                      appDefaultButton(
                        onPressed: () async {
                          if (otpCubit.formKey.currentState!.validate()) {
                            sendFunction(otpCubit.otpController.text);
                          }
                        },
                        child: Text(
                          'تحقق',
                          style: AppTextStyles().fontWhite16Bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
