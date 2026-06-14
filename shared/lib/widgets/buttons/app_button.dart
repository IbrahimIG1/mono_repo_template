import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget appDefaultButton({
  TextStyle? titleStyle,
  String? text,
  Widget? child,
  bool disabled = false,
  required Function onPressed,
  Color? color,
  double width = double.infinity,
  BoxBorder? border,
}) {
  return Padding(
    padding: EdgeInsetsDirectional.only(start: 3.w, end: 3.w),
    child: Container(
      width: width,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.all(Radius.circular(7.r)),
        color: color ?? AppColors().mainColor,
      ),

      child: MaterialButton(
        onPressed: () {
          if (disabled) return;
          onPressed();
        },
        disabledColor: AppColors().greyLight,
        child:
            (text != null)
                ? Text(
                  text,
                  style: titleStyle ?? AppTextStyles().fontWhite16Bold,
                )
                : child,
      ),
    ),
  );
}
