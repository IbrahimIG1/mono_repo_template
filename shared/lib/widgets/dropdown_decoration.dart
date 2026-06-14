import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

InputDecoration appDropDownDecoration() {
  return InputDecoration(
    isDense: true,
    floatingLabelStyle: AppTextStyles().fontGold12Meduim,

    suffixIconColor: AppColors().mainColor,
    prefixIconColor: AppColors().mainColor,
    filled: true,
    fillColor: AppColors().white,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors().mainColor),
      borderRadius: BorderRadius.circular(7.r),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors().mainColor),
      borderRadius: BorderRadius.circular(7.r),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(7.r),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(7.r),
    ),
  );
}
