import 'package:core/helper/spacer.dart';
import 'package:shared/widgets/text_field/app_text_form_feild.dart';
import 'package:shared/widgets/text_field/phone_number_widget.dart';
import 'package:sandwich_app/features/login_screen/logic/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget loginFormFeilds(LoginCubit cubit) => Column(
  children: [
    phoneNumberField(
      controller: cubit.phoneNumberController,
      getPhoneNumber: (phoneNumber) {
        cubit.phoneNumber = phoneNumber;
      },
      phoneNumber: cubit.phoneNumber,
    ),
    verticalSpace(16.h),
    AppTextFormFeild(
      controller: cubit.passwordController,
      keyboardType: TextInputType.text,
      validator: (String? value) {
        return (value!.isEmpty) ? "من فضلك ادخل كلمة السر" : null;
      },
      obscure: cubit.isPassword,
      label: Text("كلمة المرور"),
      suffixIcon: GestureDetector(
        onTap: () {
          cubit.changePasswordVisibility();
        },
        child: Icon(cubit.suffix),
      ),
    ),
  ],
);

