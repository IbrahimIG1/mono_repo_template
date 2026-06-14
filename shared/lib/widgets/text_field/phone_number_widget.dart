import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

Widget phoneNumberField({
  required Function(PhoneNumber) getPhoneNumber,
  required PhoneNumber phoneNumber,
  required TextEditingController controller,
}) {
  return SizedBox(
    height: 50.h,
    child: InternationalPhoneNumberInput(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      countries: ['SA', "EG"],
      cursorColor: AppColors().mainColorDark,
      onInputChanged: (value) {
        getPhoneNumber(value);
      },
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DIALOG,
      ),
      initialValue: phoneNumber,
      textFieldController: controller,
      keyboardType: TextInputType.phone,

      inputDecoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.sp, vertical: 15.sp),

        labelStyle: AppTextStyles().fontGrey16Medium,
        floatingLabelStyle: AppTextStyles().fontGold16Meduim,

        label: Text("رقم الجوال"),
        hintMaxLines: 3,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors().greyNormal),
          borderRadius: BorderRadius.circular(7.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors().mainColor),
          borderRadius: BorderRadius.circular(7.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(7.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(7.r),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return "من فضلك ادخل رقم الهاتف المحمول";
        }
        return null;
      },
    ),
  );
}
