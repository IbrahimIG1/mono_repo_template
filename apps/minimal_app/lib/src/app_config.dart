import 'package:flutter/material.dart';

import 'auth/reference_auth_backend.dart';

final class AppConfig {
  const AppConfig({
    required this.apiBaseUri,
    required this.themeSeed,
    required this.title,
    required this.authBackend,
    required this.sessionStorageKey,
  });

  factory AppConfig.local() => AppConfig(
    apiBaseUri: Uri.parse('https://example.invalid'),
    themeSeed: Colors.indigo,
    title: 'Flutter Platform Minimal',
    authBackend: const ReferenceAuthBackendConfiguration(),
    sessionStorageKey: 'minimal_app.auth_session.v1',
  );

  final Uri apiBaseUri;
  final Color themeSeed;
  final String title;
  final ReferenceAuthBackendConfiguration authBackend;
  final String sessionStorageKey;
}
