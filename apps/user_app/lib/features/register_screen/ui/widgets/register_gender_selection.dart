import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget registerGenderSelection(RegisterCubit cubit) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildGenderOption(
        label: 'ذكر',
        isSelected: cubit.isMale,
        onTap: (value) {
          cubit.changeGender(!value);
        },
        topRightRaduis: 4.r,
        bottomRightRaduis: 4.r,
      ),
      _buildGenderOption(
        label: 'أنثى',
        isSelected: !cubit.isMale,
        onTap: (value) {
          cubit.changeGender(value);
        },
        topLeftRaduis: 4.r,
        bottomLeftRaduis: 4.r,
      ),
    ],
  );
}

Widget _buildGenderOption({
  required String label,
  required bool isSelected,
  required Function(bool value) onTap,
  double? topLeftRaduis,
  double? topRightRaduis,
  double? bottomLeftRaduis,
  double? bottomRightRaduis,
}) {
  return GestureDetector(
    onTap: () {
      onTap(isSelected);
    },
    child: Container(
      width: 167.5.w,
      height: 35.h,
      decoration: BoxDecoration(
        color: isSelected ? AppColors().goldNormalLight : null,
        border: Border.all(
          color:
              isSelected
                  ? AppColors().goldNormalLight
                  : AppColors().greyNormalHover,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeftRaduis ?? 0),
          topRight: Radius.circular(topRightRaduis ?? 0),
          bottomLeft: Radius.circular(bottomLeftRaduis ?? 0),
          bottomRight: Radius.circular(bottomRightRaduis ?? 0),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles().fontGrey14Bold.copyWith(
            color: isSelected ? AppColors().white : AppColors().goldNormalLight,
          ),
        ),
      ),
    ),
  );
}
