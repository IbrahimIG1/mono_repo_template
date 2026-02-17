import 'package:core/helper/app_images.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

Widget appHeader(BuildContext context, {String? title, Function? onBack}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () => onBack != null ? onBack() : Navigator.pop(context),
        child: Container(
          height: 24.h,
          width: 24.w,
          margin: EdgeInsets.all(17.5.w),
          child: SizedBox(
            height: 13.5.h,
            width: 7.5.w,
            child: SvgPicture.asset(AppImages().arrowBack),
          ),
        ),
      ),
      Text(title ?? "", style: AppTextStyles().fontGoldDark20Bold),
    ],
  );
}

Widget appHeaderWithLogo(BuildContext context, {String? title}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [Image.asset(AppImages().logo, height: 30.h, width: 85.w)],
  );
}

Widget appHeaderWithoutBack(BuildContext context, {String? title}) {
  return Row(
    children: [
      Container(
        height: 24.h,
        margin: EdgeInsets.all(17.5.w),
        child: Text(title ?? "", style: AppTextStyles().fontGoldDark20Bold),
      ),
    ],
  );
}

