import 'package:flutter/material.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

PageViewModel onBoardingWidget({
  required String title,
  required String body,
  required String image,
  BuildContext? context,
}) => PageViewModel(
  title: title,
  body: body,
  image: Center(child: Lottie.asset(image, repeat: true, fit: BoxFit.cover)),
  decoration: PageDecoration(
    titleTextStyle: AppTextStyles().fontBlack12SemiBold,
    bodyTextStyle: AppTextStyles().fontBlack12SemiBold,
  ),
);

