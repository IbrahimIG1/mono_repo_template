import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:core/helper/extension.dart';
import 'package:monorepo_template/core/routing/screens_names.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/buttons/app_button.dart';
import 'package:monorepo_template/features/login_screen/logic/cubit/login_cubit.dart';
import 'package:monorepo_template/features/login_screen/logic/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget loginButton({
  required BuildContext context,
  required LoginState state,
  required LoginCubit cubit,
}) {
  return ConditionalBuilder(
    condition: state is! LoginLoadingState,
    fallback:
        (context) => Center(
          child: CircularProgressIndicator(
            backgroundColor: AppColors().goldNormalLight,
            color: AppColors().white,
          ),
        ),
    builder:
        (context) => Center(
          child: SizedBox(
            width: 335.w,
            height: 50.h,
            child: appDefaultButton(
              color: AppColors().goldNormalLight,
              titleStyle: AppTextStyles().fontWhite16Bold,
              text: "تسجيل دخول",
              onPressed: () {
                cubit.login();
              },
            ),
          ),
        ),
  );
}

Widget loginRegisterSection(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("ليس لديك حساب؟", style: AppTextStyles().fontGrey14Bold),
      SizedBox(width: 1.w),
      InkWell(
        onTap: () {
          context.pushNamed(ScreensNames.register);
        },
        child: Text(" إنشاء حساب", style: AppTextStyles().fontGold16Meduim),
      ),
    ],
  );
}

Widget loginGuestSection(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("الـدخـول كـزائر..", style: AppTextStyles().fontGrey14Bold),
      SizedBox(width: 1.w),
      InkWell(
        onTap: () {
          context.pushReplacementNamed(ScreensNames.home);
        },
        child: Text("تصفح أولاً", style: AppTextStyles().fontGold14Meduim),
      ),
    ],
  );
}
