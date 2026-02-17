import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget registerPasswordRequirements() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.sp),
    child: RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: AppTextStyles().fontBlack12SemiBold,
        children: [
          TextSpan(
            text: "يجب أن تتكون كلمة المرور من ",
            style: AppTextStyles().fontGoldDark12Bold,
          ),
          TextSpan(text: ' 8 أحرف', style: AppTextStyles().fontGold12Meduim),
          TextSpan(
            text: " على الأقل ويجب أن تحتوي على ",
            style: AppTextStyles().fontGoldDark12Bold,
          ),
          TextSpan(text: 'حرف كبير', style: AppTextStyles().fontGold12Meduim),
          TextSpan(text: ' و ', style: AppTextStyles().fontGoldDark12Bold),
          TextSpan(text: 'رقم', style: AppTextStyles().fontGold12Meduim),
          TextSpan(text: ' و ', style: AppTextStyles().fontGoldDark12Bold),
          TextSpan(text: 'حرف خاص', style: AppTextStyles().fontGold12Meduim),
          TextSpan(
            text: ' على الأقل.',
            style: AppTextStyles().fontGoldDark12Bold,
          ),
        ],
      ),
    ),
  );
}

