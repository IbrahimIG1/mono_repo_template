import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/helper/get_user_token.dart';
import 'package:core/helper/spacer.dart';
import 'package:core/local/shared_prefrence.dart';
import 'package:monorepo_template/core/routing/screens_names.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/buttons/app_button.dart';
import 'package:monorepo_template/features/language_screen/logic/language_cubit.dart';

// import 'package:dio/dio.dart';
class ChangeLangScreenBody extends StatelessWidget {
  const ChangeLangScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageCubit, Locale>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select Language - اختار اللغة",
              style: AppTextStyles().fontBlack12SemiBold.copyWith(
                color: Colors.black.withOpacity(.5),
              ),
            ),
            verticalSpace(30),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align Arabic text to right
                    children: [
                      const Text("عربي"),
                      const SizedBox(width: 5), // Reduce space manually
                      Radio<String>(
                        toggleable: false,
                        activeColor: AppColors().mainColorSecondDark,
                        value: 'ar',
                        groupValue:
                            SharedPreferencesHelper.getString(
                              SharedPrefKeys.language,
                            ) ??
                            "ar",
                        onChanged: (value) {
                          log(
                            "Change language to Arabic >> ${SharedPreferencesHelper.getString(SharedPrefKeys.language)}",
                          );

                          context.read<LanguageCubit>().langChange(
                            langCode: "ar",
                          );
                          log(
                            "After Change language to Arabic >> ${SharedPreferencesHelper.getString(SharedPrefKeys.language)}",
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align English text to left
                    children: [
                      const Text("English"),
                      const SizedBox(width: 5), // Reduce space manually
                      Radio<String>(
                        toggleable: false,
                        activeColor: AppColors().mainColorSecondDark,
                        value: 'en',
                        groupValue:
                            SharedPreferencesHelper.getString(
                              SharedPrefKeys.language,
                            ) ??
                            "ar",
                        onChanged: (value) {
                          log(
                            " Change language to English >> ${SharedPreferencesHelper.getString(SharedPrefKeys.language)}",
                          );
                          context.read<LanguageCubit>().langChange(
                            langCode: "en",
                          );
                          log(
                            "After Change language to English >> ${SharedPreferencesHelper.getString(SharedPrefKeys.language)}",
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpace(30),

            appDefaultButton(
              text: "Done - حفظ",

              width: .5.sw,
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  !WelcomeScreenOpend.getWelcomeScreenOpend()
                      ? ScreensNames.onBoardingScreen
                      : GetUserToken.getToken() == null
                      ? ScreensNames.login
                      : ScreensNames.home,
                  (route) {
                    return false;
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
