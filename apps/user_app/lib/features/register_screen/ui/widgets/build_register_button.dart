import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/buttons/app_button.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:monorepo_template/features/otp_screen/otp_screen.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildRegisterButton({
  required BuildContext context,
  required RegisterCubit cubit,
  required RegisterState state,
}) {
  return BlocConsumer<RegisterCubit, RegisterState>(
    listener: (context, state) {
      if (state is RegisterOtpSuccessState) {
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OtpScreen(
                    phoneNumber: cubit.phoneNumber.phoneNumber.toString(),
                    sendFunction: (otpCode) {
                      cubit.register(otpCode);
                    },
                  ),
            ),
          );
        }
      }
    },
    builder: (context, state) {
      return Center(
        child: SizedBox(
          width: 335.w,
          height: 50.h,
          child: appDefaultButton(
            color: AppColors().mainColor,
            child: ConditionalBuilder(
              condition: state is RegisterLoadingState, //* Change it to state
              builder:
                  (context) => Center(
                    child: CircularProgressIndicator(color: AppColors().white),
                  ),
              fallback:
                  (context) => Text(
                    "إنشاء حساب",
                    style: AppTextStyles().fontWhite16Bold,
                  ),
            ),
            onPressed: () async {
              if (cubit.formKey.currentState!.validate()) {
                if (cubit.isCommitmentConfirmed) {
                  if (cubit.isTermsConfirmed) {
                    await cubit
                        .sendVerificationCode(
                          cubit.phoneNumber.phoneNumber.toString(),
                        )
                        .then((value) {});
                  } else {
                    showToast(
                      msg: "يرجى الموافقة على الشروط والاحكام",
                      state: ToastStates.WARNING,
                    );
                  }
                } else {
                  showToast(
                    msg: "يرجى الموافقة على التعهد القانوني أولا ",
                    state: ToastStates.WARNING,
                  );
                }
              }
            },
          ),
        ),
      );
    },
  );
}
