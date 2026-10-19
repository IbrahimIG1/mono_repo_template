import 'package:flutter_test/flutter_test.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:showcase_app/showcase_app.dart';

void main() {
  test('environment config is typed and keeps endpoints app-owned', () {
    const config = ShowcaseConfig(environment: ShowcaseEnvironment.staging);

    expect(config.environment, ShowcaseEnvironment.staging);
    expect(config.appTitle, 'Showcase (Staging)');
    expect(config.apiBaseUri, isNull);
  });

  testWidgets('bootstrap renders the selected environment', (tester) async {
    const config = ShowcaseConfig(environment: ShowcaseEnvironment.production);

    await tester.pumpWidget(
      ShowcaseApp(config: config, logger: const _RecordingLogger()),
    );

    expect(find.text('Showcase'), findsOneWidget);
    expect(find.text('Bootstrap ready for production.'), findsOneWidget);
  });
}

final class _RecordingLogger implements AppLogger {
  const _RecordingLogger();

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const {},
  }) {}
}
