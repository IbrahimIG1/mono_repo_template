import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';

class AppTextFormFeild extends StatelessWidget {
  const AppTextFormFeild({
    super.key,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.onChanged,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.borderColor,
    this.hintTextStyle,
    this.textStyle,
    this.maxLines,
    this.textAlign,
    this.raduis,
    this.suffixIcon,
    this.obscure,
    this.readOnly,
    this.onTap,
    this.autofocus,
    this.label,
    this.inputFormatters,
  });
  final String? hintText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Color? borderColor;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final int? maxLines;
  final TextAlign? textAlign;
  final double? raduis;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscure;
  final bool? readOnly;
  final void Function()? onTap;
  final Widget? label;
  final bool? autofocus;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode ?? FocusNode(),
      minLines: 1,
      style: textStyle ?? AppTextStyles().fontBlack16Medium,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      cursorColor: AppColors().goldNormalLight,

      onTap: onTap,
      autofocus: autofocus ?? false,
      readOnly: readOnly ?? false,
      obscureText: obscure ?? false,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: obscure ?? false ? 1 : maxLines,
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        isDense: true,
        label: label,
        labelStyle: AppTextStyles().fontGrey14Bold,
        floatingLabelStyle: AppTextStyles().fontGold12Meduim,
        suffixIcon: suffixIcon,
        suffixIconColor: AppColors().greyNormal,
        prefixIcon: prefixIcon,
        prefixIconColor: AppColors().greyNormal,

        hintStyle: AppTextStyles().fontGrey14Bold,
        filled: true,
        fillColor: AppColors().white,
        hintText: hintText ?? "",

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors().greyNormal),
          borderRadius: BorderRadius.circular(7.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors().goldNormalLight),
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
      inputFormatters: inputFormatters ?? [],
    );
  }
}

