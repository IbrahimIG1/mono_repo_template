import 'package:flutter/material.dart';

final class AppConfig {
  const AppConfig({
    required this.apiBaseUri,
    required this.themeSeed,
    required this.title,
  });

  factory AppConfig.local() => AppConfig(
    apiBaseUri: Uri.parse('https://example.invalid'),
    themeSeed: Colors.indigo,
    title: 'Flutter Platform Minimal',
  );

  final Uri apiBaseUri;
  final Color themeSeed;
  final String title;
}
