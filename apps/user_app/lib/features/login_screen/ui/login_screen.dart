import 'package:core/di/di.dart';
import 'package:core/helper/app_images.dart';
import 'package:core/helper/spacer.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:sandwich_app/features/login_screen/logic/cubit/login_cubit.dart';
import 'package:sandwich_app/features/login_screen/logic/cubit/login_state.dart';
import 'package:sandwich_app/features/login_screen/ui/widgets/forget_password.dart';
import 'package:sandwich_app/features/login_screen/ui/widgets/login_button.dart';
import 'package:sandwich_app/features/login_screen/ui/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => getIt<LoginCubit>(),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccessState) {
              showToast(msg: "مرحبا بك فى التطبيق", state: ToastStates.SUCCESS);

              Navigator.pushReplacementNamed(context, ScreensNames.home);
            }
            if (state is LoginErrorState) {
              showToast(msg: state.error.message, state: ToastStates.ERROR);
            }
          },
          builder: (context, state) {
            LoginCubit cubit = LoginCubit.get(context);
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 2.h,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: cubit.loginkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(40.h),
                          Center(
                            child: Image.asset(
                              AppImages().logo,
                              color: Colors.green,
                              width: 90.w,
                              height: 90.h,
                            ),
                          ),
                          verticalSpace(48.h),
                          // loginBuildHeader(),
                          verticalSpace(24.h),
                          loginFormFeilds(cubit),
                          verticalSpace(16.sp),
                          buildForgotPassword(context),
                          verticalSpace(28.sp),
                          loginButton(
                            context: context,
                            state: state,
                            cubit: cubit,
                          ),
                          verticalSpace(24.sp),
                          loginRegisterSection(context),
                          verticalSpace(24.sp),
                          loginGuestSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

