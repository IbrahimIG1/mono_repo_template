import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sandwich_app/core/routing/arguments_keys.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:sandwich_app/features/forget_password_screen/forget_password_screen.dart';
import 'package:sandwich_app/features/home_screen/home_screen.dart';
import 'package:sandwich_app/features/language_screen/ui/change_lang_screen.dart';
import 'package:sandwich_app/features/login_screen/ui/login_screen.dart';
import 'package:sandwich_app/features/onboarding_screen/onboarding_screen.dart';
import 'package:sandwich_app/features/register_screen/ui/register_screen.dart';
import 'package:sandwich_app/features/reset_password_screen/reset_password_screen.dart';

class AppRoutes {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    /* Used When I want pass a value from one screen to another */
    final args = settings.arguments as Map<String, dynamic>?;
    // final userName = args?['userName'] ?? 'Guest';
    // final userId = args?['userId'] ?? 0;
    switch (settings.name) {
      //* Home Screen
      case ScreensNames.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      //* Login Screen
      case ScreensNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      //* Register Screen
      case ScreensNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      //* Otp Screen
      // case ScreensNames.otpScreen:
      //   return MaterialPageRoute(
      //     builder:
      //         (_) => OtpScreen(
      //           phoneNumber:
      //               args![AppRoutArgumentsKeys.otpScreenPhoneNumber].toString(),
      //           sendFunction: args[AppRoutArgumentsKeys.otpScreenSendFunction],
      //         ),
      //   );
      //* Forget Password Screen
      case ScreensNames.forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());
      //* Reset Password Screen
      case ScreensNames.resetPassword:
        return MaterialPageRoute(
          builder:
              (_) => ResetPasswordScreen(
                otpCode: args![AppRoutArgumentsKeys.resetPasswordOtpCode],
                phoneNumber:
                    args[AppRoutArgumentsKeys.resetPasswordPhoneNumber],
              ),
        );
      case ScreensNames.changeLangScreen:
        return MaterialPageRoute(builder: (_) => ChangeLangScreen());
      case ScreensNames.onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case '/':
        MaterialPageRoute(
          builder: (context) {
            // Show dialog after first frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (dialogContext) => AlertDialog(
                      title: const Text('تنبيه'),
                      content: const Text(
                        'لا يوجد مسار لهذا الرابط، هل تريد إغلاق التطبيق أم العودة للرئيسية؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            SystemNavigator.pop();
                          },
                          child: const Text('إغلاق التطبيق'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.pushReplacementNamed(
                              context,
                              ScreensNames.home,
                            );
                          },
                          child: const Text('العودة للرئيسية'),
                        ),
                      ],
                    ),
              );
            });
            return const Scaffold(
              body: Center(child: Text('No route defined.')),
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
    return null;
  }
}

