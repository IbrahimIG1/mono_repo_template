import 'package:shared/widgets/text_field/app_text_form_feild.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget registerUserNameField(RegisterCubit cubit) {
  return Center(
    child: SizedBox(
      width: 335.sp,
      child: AppTextFormFeild(
        controller: cubit.userNameController,
        keyboardType: TextInputType.text,
        validator: (String? value) {
          return (value!.isEmpty || value.length < 6)
              ? "من فضلك ادخل اسم المستخدم لا تقل عن 6 حروف"
              : null;
        },
        label: Text("اسم المستخدم"),

        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            String pattern = '((?![\u0660-\u0669])[\u0600-\u06FF\\s\\.])*';
            if (!(RegExp(pattern).stringMatch(newValue.text) ==
                newValue.text)) {
              showToast(
                msg: "اكتب باللغة العربية",
                state: ToastStates.WARNING,
                sec: 1,
                immediate: true,
              );
              return oldValue;
            }
            return newValue;
          }),
        ],
      ),
    ),
  );
}
