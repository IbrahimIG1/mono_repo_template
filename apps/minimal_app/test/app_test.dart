import 'package:auth_core/auth_core.dart';
import 'package:auth_core/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/app.dart';
import 'package:minimal_app/src/app_composition.dart';
import 'package:minimal_app/src/app_config.dart';
import 'package:minimal_app/src/app_controller.dart';
import 'package:minimal_app/src/auth/reference_auth_backend.dart';
import 'package:minimal_app/src/launch_counter_repository.dart';
import 'package:storage/storage.dart';

void main() {
  test('controller ignores a storage completion after disposal', () async {
    final controller = AppController(
      LaunchCounterRepository(MemoryKeyValueStore()),
    );

    final load = controller.load();
    controller.dispose();
    await load;

    expect(controller.state, isA<AppLoading>());
  });

  testWidgets('protected deep link resumes after typed sign-in', (
    tester,
  ) async {
    final composition = _composition(
      initialLocation: '/protected/report?tab=activity',
    );

    await tester.pumpWidget(MinimalApp(composition: composition));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(
      find.text('Continue to /protected/report?tab=activity'),
      findsOneWidget,
    );
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'person@example.com');
    await tester.enterText(fields.at(1), 'long-enough-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Protected item: report'), findsOneWidget);
    expect(find.text('Selected tab: activity'), findsOneWidget);
  });

  testWidgets('external post-login destination is rejected', (tester) async {
    final external = Uri.encodeQueryComponent('https://example.com/steal');
    final composition = _composition(
      initialLocation: '/sign-in?from=$external',
    );

    await tester.pumpWidget(MinimalApp(composition: composition));
    await tester.pumpAndSettle();

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'person@example.com');
    await tester.enterText(fields.at(1), 'long-enough-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('V2 authentication'), findsOneWidget);
    expect(find.textContaining('example.com/steal'), findsNothing);
  });

  testWidgets('restored session opens protected typed route directly', (
    tester,
  ) async {
    final composition = _composition(
      initialLocation: '/protected/account?tab=security',
      storedSession: _storedSession,
    );

    await tester.pumpWidget(MinimalApp(composition: composition));
    await tester.pumpAndSettle();

    expect(find.text('Protected item: account'), findsOneWidget);
    expect(find.text('Selected tab: security'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });
}

AppComposition _composition({
  required String initialLocation,
  AuthSession? storedSession,
}) {
  final config = AppConfig.local();
  final backend = ReferenceAuthBackend(configuration: config.authBackend);
  return AppComposition.forTest(
    config: config,
    preferences: MemoryKeyValueStore(),
    sessionStore: MemorySessionStore(initialSession: storedSession),
    authGateway: ReferenceEmailPasswordAuthGateway(backend),
    sessionGateway: ReferenceSessionGateway(backend),
    initialLocation: initialLocation,
  );
}

final _storedSession = AuthSession(
  accessToken: 'stored-access',
  refreshToken: 'stored-refresh',
  subjectId: 'stored-user',
  expiresAt: DateTime.utc(2030, 1, 1),
);
