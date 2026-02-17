import 'package:shared/styles/colors/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastStates { SUCCESS, ERROR, WARNING }

showToast({
  required String msg,
  required ToastStates state,
  int sec = 2,
  bool immediate = false,
}) async {
  if (immediate) {
    await Fluttertoast.cancel();
  }

  if (state == ToastStates.WARNING) {
    await HapticFeedback.lightImpact();
  }

  return await Fluttertoast.showToast(
    msg: chooseToastIcon(state) + msg,
    toastLength: Toast.LENGTH_LONG,
    gravity:
        ToastGravity
            .CENTER, //immediate? ToastGravity.CENTER : ToastGravity.BOTTOM,
    webShowClose: immediate,
    timeInSecForIosWeb: 2,
    backgroundColor: AppColors().white,
    textColor: chooseToastColor(state), //WHITE,
    fontSize: 12.sp,
  );
}

String chooseToastIcon(ToastStates state) {
  switch (state) {
    case ToastStates.SUCCESS:
      return "✅ ";
    case ToastStates.WARNING:
      return "⚠️ ";
    case ToastStates.ERROR:
      return "❌ ";
  }
}

Color chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = AppColors().green;
      break;
    case ToastStates.WARNING:
      color = AppColors().blackLight;
      break;
    case ToastStates.ERROR:
      color = AppColors().red;
      break;
  }
  return color;
}

