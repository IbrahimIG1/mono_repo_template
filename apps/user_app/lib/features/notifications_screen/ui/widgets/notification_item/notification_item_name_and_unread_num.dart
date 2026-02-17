import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';

Widget notificationItemName({required String title}) {
  return Text(
    title,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyles().fontGoldDark16Bold,
  );
}

