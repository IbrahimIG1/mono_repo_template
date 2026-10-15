import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/app.dart';
import 'package:minimal_app/src/app_composition.dart';
import 'package:minimal_app/src/app_config.dart';
import 'package:minimal_app/src/app_controller.dart';
import 'package:minimal_app/src/launch_counter_repository.dart';
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';
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

  testWidgets('renders the injected foundation and persistent launch count', (
    tester,
  ) async {
    final composition = AppComposition.forTest(
      config: AppConfig(
        apiBaseUri: Uri.parse('https://example.invalid'),
        themeSeed: Colors.indigo,
        title: 'Test platform',
      ),
      networkClient: _FakeNetworkClient(),
      preferences: MemoryKeyValueStore(
        initialValues: {'minimal_app.launch_count': 2},
      ),
    );

    await tester.pumpWidget(MinimalApp(composition: composition));
    await tester.pumpAndSettle();

    expect(find.text('Test platform'), findsOneWidget);
    expect(find.text('Successful launches: 3'), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
    expect(find.text('Networking'), findsOneWidget);
  });
}

final class _FakeNetworkClient implements NetworkClient {
  @override
  void close() {}

  @override
  Future<Result<NetworkResponse>> send(NetworkRequest request) async =>
      const Success(NetworkResponse(statusCode: 200, data: null, headers: {}));
}
