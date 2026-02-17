// re/themes/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/helper/spacer.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';

Widget loginBuildHeader() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("تــسجيـــل الدخـــول", style: AppTextStyles().fontGoldDark20Bold),
      verticalSpace(10.h),
      Text("أهلاً بعودتك مجدداً", style: AppTextStyles().fontGoldDark16Meduim),
    ],
  );
}

