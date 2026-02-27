import 'package:core/di/core_setup.dart';
import 'package:core/di/di.dart';
import 'package:core/network/api_sevices/api_services.dart';
import 'package:core/network/api_sevices/dio_factory.dart';
import 'package:flutter/material.dart';
import 'package:monorepo_template/app_navigation.dart';
import 'package:monorepo_template/features/notifications_screen/logic/notification_factory.dart';
import 'package:monorepo_template/core/routing/screens_names.dart';

class SetupForServices {
  static Future<void> setupForServices() async {
    await setupCoreDependencies();

    getIt.registerLazySingleton<ApiServices>(
      () => ApiServices(
        getIt<DioFactory>(),
        onUnauthorized: () async {
          final context = activeContext;
          if (context != null) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              ScreensNames.login,
              (route) => false,
            );
          }
        },
      ),
    );

    getIt.registerLazySingleton<NotificationFactory>(
      () => NotificationFactory(),
    );
  }
}
