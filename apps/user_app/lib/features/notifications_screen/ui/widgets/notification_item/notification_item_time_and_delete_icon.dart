import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';

Widget notificationItemTimeAndDelete({required String time}) {
  return Column(
    children: [
      Text(time, style: AppTextStyles().fontGold12Bold),
      // const Spacer(),
      // Icon(Icons.delete_outline, color: AppColors().red, size: 24.sp),
    ],
  );
}

