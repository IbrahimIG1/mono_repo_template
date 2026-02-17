import 'package:flutter/material.dart';

class AppColors {
  // Private constructor
  AppColors._internal();

  // Static private field
  static AppColors? _instance;

  // Public factory constructor with lazy init
  factory AppColors() {
    _instance ??= AppColors._internal();
    return _instance!;
  }
  //* Gold Color
   Color goldNormalLight = Color(0xFFB4953D);
   Color goldNormalLighter = Color(0xFFE8DEC3);

   Color goldNormalDark = Color(0xFF907731);
   Color goldDark = Color(0xFF3F3415);

  //* Grey Light
   Color greyLight = Color(0xFFEEEEEE);
   Color greyLighter = Color(0xFFF9F9F9);
   Color greyNormal = Color(0xFF9F9F9F);
   Color greyNormalHover = Color(0xFFB3B3B3);
   Color greyC7 = Color(0xFFC7C7C7);

  //* White
   Color white = Color(0xFFFFFFFF);

  //* Black
   Color blackLight = Color(0xff24242C);
   Color black = Colors.black;
  //* Green
   Color green = Color(0xFF27AE60);
  //* Red
   Color red = Color(0xFFEB5757);
   Color redLight = Color(0xFFFEECEB);
}
