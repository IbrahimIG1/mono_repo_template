import 'package:shared/widgets/text_field/app_text_form_feild.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:flutter/material.dart';

Widget registerPasswordField(RegisterCubit cubit) {
  return Center(
    child: SizedBox(
      child: AppTextFormFeild(
        obscure: cubit.isPassword,
        suffixIcon: GestureDetector(
          onTap: () {
            cubit.changePasswordVisibility();
          },
          child: Icon(cubit.suffix),
        ),
        controller: cubit.passwordController,
        keyboardType: TextInputType.text,
        validator: (String? value) {
          if (value!.isEmpty) {
            return "من فضلك ادخل كلمة السر";
          } else if (value.length < 7) {
            return "من فضلك ادخل كلمة مرور لا تقل عن 7 حروف";
          } else {
            return null;
          }
        },
        label: Text("كلمة السر"),
      ),
    ),
  );
}
