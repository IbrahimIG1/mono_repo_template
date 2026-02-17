import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/helper/extension.dart';
import 'package:core/local/secure_storage_helper.dart';
import 'package:core/local/shared_prefrence.dart';
import 'package:sandwich_app/app_navigation.dart';
import 'package:sandwich_app/core/di/app_dependencies.dart';
import 'package:sandwich_app/core/routing/generate_route.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:sandwich_app/features/language_screen/logic/language_cubit.dart';
import 'package:sandwich_app/generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env_dev");
  await setupAllDependencies();

  final token = await AppSecureStorageHelper.getToken(SharedPrefKeys.token);

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (context, child) => BlocProvider(
            create: (context) => LanguageCubit(),
            child: BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  navigatorKey: navigatorKeyDev,
                  locale: locale,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  title: 'App',
                  theme: ThemeData(scaffoldBackgroundColor: Colors.white),
                  onGenerateRoute: AppRoutes.generateRoute,
                  initialRoute:
                      token.isNullOrEmpty()
                          ? ScreensNames.login
                          : ScreensNames.home,
                );
              },
            ),
          ),
    );
  }
}

