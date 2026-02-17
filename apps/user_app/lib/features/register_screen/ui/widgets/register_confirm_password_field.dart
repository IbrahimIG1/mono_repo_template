import 'package:shared/widgets/text_field/app_text_form_feild.dart';
import 'package:sandwich_app/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:flutter/material.dart';

Widget registerConfirmPasswordField(RegisterCubit cubit) {
  return Center(
    child: AppTextFormFeild(
      suffixIcon: GestureDetector(
        onTap: () {
          cubit.changePasswordVisibility();
        },
        child: Icon(cubit.suffix),
      ),
      obscure: cubit.isPassword,
      controller: cubit.confirmPasswordController,
      keyboardType: TextInputType.text,
      validator: (val) {
        if (val!.isEmpty) {
          return "من فضلك ادخل كلمة السر";
        } else if (val != cubit.passwordController.text) {
          return "كلمة السر غير متطابقة";
        } else {
          return null;
        }
      },
      label: Text("  تاكيد كلمة السر"),
    ),
  );
}

