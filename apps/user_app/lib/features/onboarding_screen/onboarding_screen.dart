import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/helper/extension.dart';
import 'package:core/helper/get_user_token.dart';
import 'package:core/local/shared_prefrence.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:shared/styles/colors/colors.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:sandwich_app/features/onboarding_screen/widget/onboarding_widget.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentPage = 0; // Track the current page index

  final List<PageViewModel> pages = [
    onBoardingWidget(
      title: " S.current.dashboard_screen_1_title",
      body: " S.current.dashboard_screen_1_content",
      image: "",
    ),
    onBoardingWidget(
      title: " S.current.dashboard_screen_2_title",
      body: " S.current.dashboard_screen_2_content",
      image: "",
    ),
    onBoardingWidget(
      title: " S.current.dashboard_screen_3_title",
      body: " S.current.dashboard_screen_3_content",
      image: "",
    ),
    onBoardingWidget(
      title: " S.current.dashboard_screen_4_title",
      body: " S.current.dashboard_screen_4_content",
      image: "",
    ),
    onBoardingWidget(
      title: " S.current.dashboard_screen_5_title",
      body: " S.current.dashboard_screen_5_content",
      image: "",
    ),
    onBoardingWidget(
      title: " S.current.dashboard_screen_6_title",
      body: " S.current.dashboard_screen_6_content",
      image: "",
    ),
    onBoardingWidget(
      title: " S.current.dashboard_screen_7_title",
      body: " S.current.dashboard_screen_7_content",
      image: "",
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _completeOnboarding(BuildContext context) {
    SharedPreferencesHelper.saveString(SharedPrefKeys.onBoarding, "done");
    context.pushNamedAndRemoveUntil(
      GetUserToken.getToken() == null ? ScreensNames.login : ScreensNames.home,
      predicate: ((c) {
        return false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1F3763),
      body: IntroductionScreen(
        pages: pages,
        onDone: () => _completeOnboarding(context),
        onSkip: () => _completeOnboarding(context),
        showSkipButton: currentPage != pages.length - 1,
        skip: Text("تخطي", style: AppTextStyles().fontBlack12SemiBold),
        skipStyle: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors().goldDark,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        next: Icon(Icons.arrow_forward, color: AppColors().white, size: 16),
        nextStyle: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors().goldDark,
          minimumSize: const Size(24, 24),
        ),
        done: Text("تم", style: AppTextStyles().fontBlack12SemiBold),
        doneStyle: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors().goldDark,
          minimumSize: Size.zero,
        ),
        dotsDecorator: DotsDecorator(
          activeColor: AppColors().goldDark,
          size: Size(7.w, 7.h),
          color: Colors.black26,
          activeSize: Size(15.w, 7.h),
          spacing: EdgeInsets.symmetric(horizontal: 2.w),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        curve: Curves.easeInOut,
        onChange: _onPageChanged,
      ),
    );
  }
}

