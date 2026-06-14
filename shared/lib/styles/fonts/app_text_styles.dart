import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/family_font.dart';
import 'package:shared/styles/fonts/font_weights.dart';

class AppTextStyles {
  // Private constructor
  AppTextStyles._internal();

  // Static private field
  static AppTextStyles? _instance;

  // Public factory constructor with lazy init
  factory AppTextStyles() {
    _instance ??= AppTextStyles._internal();
    return _instance!;
  }

  //* Gold Light
  TextStyle fontGold12Meduim = TextStyle(
    fontSize: 12.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGold12Bold = TextStyle(
    fontSize: 12.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGold12SimiBold = TextStyle(
    fontSize: 12.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.semiBold,
  );
  TextStyle fontGold14Meduim = TextStyle(
    fontSize: 14.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGold14Bold = TextStyle(
    fontSize: 14.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGold14Regular = TextStyle(
    fontSize: 14.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontGold16Meduim = TextStyle(
    fontSize: 16.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGold16Bold = TextStyle(
    fontSize: 16.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGold20Bold = TextStyle(
    fontSize: 20.sp,
    color: AppColors().mainColor,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  //* Gold Dark
  TextStyle fontGoldDark12Bold = TextStyle(
    fontSize: 12.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGoldDark14Meduim = TextStyle(
    fontSize: 14.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGoldDark14Regular = TextStyle(
    fontSize: 14.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontGoldDark14Bold = TextStyle(
    fontSize: 14.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGoldDark12Meduim = TextStyle(
    fontSize: 12.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGoldDark12Regular = TextStyle(
    fontSize: 12.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontGoldDark20Bold = TextStyle(
    fontSize: 20.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGoldDark24Bold = TextStyle(
    fontSize: 24.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGoldDark16Meduim = TextStyle(
    fontSize: 16.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGoldDark16Bold = TextStyle(
    fontSize: 16.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGoldDark18Bold = TextStyle(
    fontSize: 18.sp,
    color: AppColors().mainColorSecondDark,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  //* White
  TextStyle fontWhite16Bold = TextStyle(
    fontSize: 16.sp,
    color: AppColors().white,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontWhite10Bold = TextStyle(
    fontSize: 10.sp,
    color: AppColors().white,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontWhite12Regular = TextStyle(
    fontSize: 12.sp,
    color: AppColors().white,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontWhite12Medium = TextStyle(
    fontSize: 12.sp,
    color: AppColors().white,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontWhite14Bold = TextStyle(
    fontSize: 14.sp,
    color: AppColors().white,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );

  //* Grey
  TextStyle fontGrey12SimiBold = TextStyle(
    fontSize: 12.sp,
    color: AppColors().greyNormal,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.semiBold,
  );
  TextStyle fontGrey16Bold = TextStyle(
    fontSize: 16.sp,
    color: AppColors().greyNormal,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
  TextStyle fontGrey16Medium = TextStyle(
    fontSize: 16.sp,
    color: AppColors().greyNormal,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontGreyLight16Regular = TextStyle(
    fontSize: 16.sp,
    color: AppColors().greyC7,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontGrey14Bold = TextStyle(
    fontSize: 14.sp,
    color: AppColors().greyNormal,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontGrey14Regular = TextStyle(
    fontSize: 14.sp,
    color: AppColors().greyNormal,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );

  //* Black
  TextStyle fontBlack16Medium = TextStyle(
    fontSize: 16.sp,
    color: AppColors().black,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.medium,
  );
  TextStyle fontBlack16Regular = TextStyle(
    fontSize: 16.sp,
    color: AppColors().black,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.regular,
  );
  TextStyle fontBlack12SemiBold = TextStyle(
    fontSize: 12.sp,
    color: AppColors().black,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.semiBold,
  );
  TextStyle fontBlack20Bold = TextStyle(
    fontSize: 20.sp,
    color: AppColors().black,
    fontFamily: AppFontFamily.plex,
    fontWeight: AppFontWeights.bold,
  );
}
