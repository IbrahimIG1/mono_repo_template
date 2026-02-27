import 'package:core/di/di.dart';
import 'package:monorepo_template/features/forget_password_screen/logic/cubit/forget_passord_cubit.dart';
import 'package:monorepo_template/features/language_screen/logic/language_cubit.dart';
import 'package:monorepo_template/features/login_screen/logic/cubit/login_cubit.dart';
import 'package:monorepo_template/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:monorepo_template/features/reset_password_screen/logic/cubit/reset_passord_cubit.dart';

class SetupForCubits {
  static void setUpForCubits() {
    //* Notification Factory
    // NotificationFactory().initialize();

    //* Login
    getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
    //* Register
    getIt.registerFactory<RegisterCubit>(() => RegisterCubit(getIt()));
    //* Forget Password
    getIt.registerFactory<ForgetPasswordCubit>(
      () => ForgetPasswordCubit(getIt()),
    );
    //* Rest Password
    getIt.registerFactory<ResetPasswordCubit>(
      () => ResetPasswordCubit(getIt()),
    );
    getIt.registerFactory<LanguageCubit>(() => LanguageCubit());
    //* Notification
    // getIt.registerFactory<NotificationCubit>(() => NotificationCubit(getIt(), getIt()));
  }
}
