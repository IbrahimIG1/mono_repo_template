import 'package:shared/styles/colors/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> notificationsUi(RemoteMessage message) {
  return Fluttertoast.showToast(
    msg: message.notification!.body.toString(),
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 3,
    backgroundColor: AppColors().goldNormalLight,
    textColor: Colors.white,
    fontSize: 16.0.sp,
  );
}

