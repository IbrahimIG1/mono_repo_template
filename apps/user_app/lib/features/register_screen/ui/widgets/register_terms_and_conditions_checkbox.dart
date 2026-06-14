import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget registerTermsAndConditionsCheckbox(
  RegisterCubit cubit,
  BuildContext context,
) {
  return Row(
    children: [
      Checkbox(
        side: BorderSide(color: AppColors().mainColorSecondDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        activeColor: AppColors().mainColorSecondDark,
        value: cubit.isTermsConfirmed,
        onChanged: (bool? value) {
          cubit.changeTermsConfirmed(value);
        },
      ),
      Text("اوافق علي ", style: AppTextStyles().fontGrey16Medium),
      InkWell(
        child: Text(
          "الشروط و الاحكام",
          style: AppTextStyles().fontGold16Meduim,
        ),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => TermsScreen()),
          // );
        },
      ),
    ],
  );
}

Widget registerCommitmentCheckbox(RegisterCubit cubit) {
  return Row(
    children: [
      Checkbox(
        side: BorderSide(color: AppColors().mainColorSecondDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        activeColor: AppColors().mainColorSecondDark,
        value: cubit.isCommitmentConfirmed,
        onChanged: (bool? value) {
          cubit.changeCommitmentConfirmed(value);
        },
      ),
      Expanded(
        child: Text(
          "أتعهد بأن جميع المعلومات المدخله صحيحة واتحمل كامل المسؤولية والاجراءات القانونية المتخذة",
          style: AppTextStyles().fontGrey16Medium.copyWith(fontSize: 14.sp),
        ),
      ),
    ],
  );
}
