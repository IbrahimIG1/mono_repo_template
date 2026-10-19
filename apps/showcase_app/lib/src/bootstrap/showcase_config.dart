enum ShowcaseEnvironment { development, staging, production }

final class ShowcaseConfig {
  const ShowcaseConfig({required this.environment, this.apiBaseUri});

  factory ShowcaseConfig.fromEnvironment() {
    final rawEnvironment = const String.fromEnvironment(
      'SHOWCASE_ENV',
      defaultValue: 'development',
    );
    return ShowcaseConfig(
      environment: _parseEnvironment(rawEnvironment),
      apiBaseUri: _optionalUri(
        const String.fromEnvironment('SHOWCASE_API_BASE_URL'),
      ),
    );
  }

  final ShowcaseEnvironment environment;
  final Uri? apiBaseUri;

  String get appTitle => switch (environment) {
    ShowcaseEnvironment.development => 'Showcase (Development)',
    ShowcaseEnvironment.staging => 'Showcase (Staging)',
    ShowcaseEnvironment.production => 'Showcase',
  };

  static ShowcaseEnvironment _parseEnvironment(String value) =>
      switch (value.trim().toLowerCase()) {
        'staging' => ShowcaseEnvironment.staging,
        'production' || 'prod' => ShowcaseEnvironment.production,
        _ => ShowcaseEnvironment.development,
      };

  static Uri? _optionalUri(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return Uri.tryParse(trimmed);
  }
}
