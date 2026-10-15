import 'package:networking/dio.dart';
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/shared_preferences.dart';
import 'package:storage/storage.dart';

import 'app_config.dart';
import 'app_controller.dart';
import 'launch_counter_repository.dart';

final class AppComposition {
  AppComposition._({
    required this.config,
    required this.networkClient,
    required KeyValueStore preferences,
  }) : controller = AppController(LaunchCounterRepository(preferences));

  factory AppComposition.create() {
    final config = AppConfig.local();
    const logger = NullLogger();
    final networkClient = DioNetworkClient.create(
      configuration: NetworkConfiguration(baseUri: config.apiBaseUri),
      logger: logger,
    );
    final preferences = SharedPreferencesStore.create();
    return AppComposition._(
      config: config,
      networkClient: networkClient,
      preferences: preferences,
    );
  }

  factory AppComposition.forTest({
    required AppConfig config,
    required NetworkClient networkClient,
    required KeyValueStore preferences,
  }) => AppComposition._(
    config: config,
    networkClient: networkClient,
    preferences: preferences,
  );

  final AppConfig config;
  final NetworkClient networkClient;
  final AppController controller;

  void dispose() {
    controller.dispose();
    networkClient.close();
  }
}
