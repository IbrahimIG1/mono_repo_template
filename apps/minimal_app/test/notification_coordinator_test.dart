import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:auth_core/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/app.dart';
import 'package:minimal_app/src/app_composition.dart';
import 'package:minimal_app/src/app_config.dart';
import 'package:minimal_app/src/auth/reference_auth_backend.dart';
import 'package:minimal_app/src/notifications/handled_interaction_store.dart';
import 'package:minimal_app/src/notifications/notification_destination_mapper.dart';
import 'package:minimal_app/src/notifications/pending_interaction_coordinator.dart';
import 'package:minimal_app/src/routing/app_router.dart';
import 'package:notifications_core/notifications_core.dart';
import 'package:notifications_core/testing.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

void main() {
  test('waits for router and session readiness before navigating', () async {
    final client = FakePushNotificationClient();
    final sessionManager = SessionManager(
      store: MemorySessionStore(),
      gateway: FakeSessionGateway(
        refreshHandler: (_) async => const Failure(
          AuthFailure(
            kind: AuthFailureKind.invalidSession,
            code: 'auth.no_session',
            message: 'No session.',
          ),
        ),
      ),
    );
    final routerReady = Completer<void>();
    final navigator = _RecordingNavigator();
    final coordinator = PendingInteractionCoordinator(
      client: client,
      decoder: const NotificationPayloadDecoder(),
      mapper: const ReferenceNotificationDestinationMapper(),
      deduplicator: InteractionDeduplicator(
        store: MemoryHandledInteractionStore(),
      ),
      sessionManager: sessionManager,
      navigator: navigator,
      routerReady: routerReady.future,
    )..start();

    client.addInteraction(_interaction('tap-1', itemId: 'report'));
    await Future<void>.delayed(Duration.zero);
    expect(navigator.destinations, isEmpty);

    routerReady.complete();
    await Future<void>.delayed(Duration.zero);
    expect(navigator.destinations, isEmpty);

    await sessionManager.restore();
    await Future<void>.delayed(Duration.zero);
    expect(navigator.destinations, ['/protected/report']);

    await coordinator.dispose().timeout(const Duration(seconds: 2));
    await client.dispose().timeout(const Duration(seconds: 2));
    await sessionManager.dispose();
  });

  testWidgets(
    'protected notification resumes and is re-authorized after login',
    (tester) async {
      final composition = _composition(
        destinationAuthorizer: (destination, session) =>
            destination.path != '/protected/blocked' &&
            session.subjectId.isNotEmpty,
      );
      final client = FakePushNotificationClient();
      final coordinator = PendingInteractionCoordinator(
        client: client,
        decoder: const NotificationPayloadDecoder(),
        mapper: const ReferenceNotificationDestinationMapper(),
        deduplicator: InteractionDeduplicator(
          store: MemoryHandledInteractionStore(),
        ),
        sessionManager: composition.sessionManager,
        navigator: AppRouterNotificationNavigator(composition.appRouter),
        routerReady: Future.value(),
      )..start();

      await tester.pumpWidget(MinimalApp(composition: composition));
      await _settle(tester);
      client.addInteraction(_interaction('tap-2', itemId: 'report'));
      await _settle(tester);

      expect(find.text('Continue to /protected/report'), findsOneWidget);
      await _signIn(tester);
      expect(find.text('Protected item: report'), findsOneWidget);

      client.addInteraction(_interaction('tap-3', itemId: 'blocked'));
      await _settle(tester);
      expect(find.text('Protected item: blocked'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await coordinator.dispose().timeout(const Duration(seconds: 2));
      await client.dispose().timeout(const Duration(seconds: 2));
    },
  );

  test(
    'deduplicates repeated interactions and retains the configured bound',
    () async {
      final keyValues = MemoryKeyValueStore();
      final store = KeyValueHandledInteractionStore(store: keyValues);
      final deduplicator = InteractionDeduplicator(
        store: store,
        maximumRetainedIds: 2,
      );

      await deduplicator.claim('one');
      await deduplicator.claim('two');
      await deduplicator.claim('three');

      expect((await store.read() as Success<List<String>>).value, [
        'two',
        'three',
      ]);
      expect(
        (await deduplicator.claim('three') as Success<bool>).value,
        isFalse,
      );
    },
  );

  test('rejects mismatched envelope and payload interaction IDs', () async {
    final client = FakePushNotificationClient();
    final sessionManager = SessionManager(
      store: MemorySessionStore(),
      gateway: FakeSessionGateway(
        refreshHandler: (_) async => const Failure(
          AuthFailure(
            kind: AuthFailureKind.invalidSession,
            code: 'auth.no_session',
            message: 'No session.',
          ),
        ),
      ),
    );
    await sessionManager.restore();
    final navigator = _RecordingNavigator();
    final coordinator = PendingInteractionCoordinator(
      client: client,
      decoder: const NotificationPayloadDecoder(),
      mapper: const ReferenceNotificationDestinationMapper(),
      deduplicator: InteractionDeduplicator(
        store: MemoryHandledInteractionStore(),
      ),
      sessionManager: sessionManager,
      navigator: navigator,
      routerReady: Future.value(),
    )..start();

    final interaction = _interaction('payload-id', itemId: 'report');
    client.addInteraction(
      NotificationInteraction(
        id: 'envelope-id',
        data: interaction.data,
        occurredAt: interaction.occurredAt,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(navigator.destinations, isEmpty);
    await coordinator.dispose();
    await client.dispose();
    await sessionManager.dispose();
  });

  test('an unexpected interaction failure does not poison the queue', () async {
    final client = FakePushNotificationClient();
    final sessionManager = SessionManager(
      store: MemorySessionStore(),
      gateway: FakeSessionGateway(
        refreshHandler: (_) async => const Failure(
          AuthFailure(
            kind: AuthFailureKind.invalidSession,
            code: 'auth.no_session',
            message: 'No session.',
          ),
        ),
      ),
    );
    await sessionManager.restore();
    final navigator = _RecordingNavigator();
    final errors = <Object>[];
    final coordinator = PendingInteractionCoordinator(
      client: client,
      decoder: const NotificationPayloadDecoder(),
      mapper: _ThrowOnceDestinationMapper(),
      deduplicator: InteractionDeduplicator(
        store: MemoryHandledInteractionStore(),
      ),
      sessionManager: sessionManager,
      navigator: navigator,
      routerReady: Future.value(),
      onUnexpectedError: (error, _) => errors.add(error),
    )..start();

    client.addInteraction(_interaction('first', itemId: 'first'));
    client.addInteraction(_interaction('second', itemId: 'second'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(1));
    expect(navigator.destinations, ['/protected/second']);
    await coordinator.dispose();
    await client.dispose();
    await sessionManager.dispose();
  });
}

NotificationInteraction _interaction(String id, {required String itemId}) =>
    NotificationInteraction(
      id: id,
      data: {
        'v': '1',
        'type': 'protected_item',
        'interaction_id': id,
        'item_id': itemId,
      },
      occurredAt: DateTime.utc(2026, 10, 15),
    );

AppComposition _composition({DestinationAuthorizer? destinationAuthorizer}) {
  final config = AppConfig.local();
  final backend = ReferenceAuthBackend(configuration: config.authBackend);
  return AppComposition.forTest(
    config: config,
    preferences: MemoryKeyValueStore(),
    sessionStore: MemorySessionStore(),
    authGateway: ReferenceEmailPasswordAuthGateway(backend),
    sessionGateway: ReferenceSessionGateway(backend),
    initialLocation: '/',
    destinationAuthorizer: destinationAuthorizer,
  );
}

Future<void> _signIn(WidgetTester tester) async {
  final fields = find.byType(EditableText);
  await tester.enterText(fields.at(0), 'person@example.com');
  await tester.enterText(fields.at(1), 'long-enough-password');
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle(
  const Duration(milliseconds: 100),
  EnginePhase.sendSemanticsUpdate,
  const Duration(seconds: 2),
);

final class _RecordingNavigator implements NotificationNavigator {
  final List<String> destinations = [];

  @override
  void go(String destination) => destinations.add(destination);
}

final class _ThrowOnceDestinationMapper
    implements NotificationDestinationMapper {
  var _shouldThrow = true;

  @override
  Result<String> map(NotificationPayload payload) {
    if (_shouldThrow) {
      _shouldThrow = false;
      throw StateError('synthetic mapper failure');
    }
    return const ReferenceNotificationDestinationMapper().map(payload);
  }
}
