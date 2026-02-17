// emes/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/helper/extension.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';

Widget buildForgotPassword(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 13.w),
    child: InkWell(
      child: Text(
        "هل نسيت كلمة المرور؟",
        style: AppTextStyles().fontGrey14Bold,
      ),
      onTap: () {
        context.pushNamed(ScreensNames.forgetPassword);
      },
    ),
  );
}

