import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatusCard uses the configured theme extension', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PlatformTheme.light(seedColor: Colors.indigo),
        home: const Scaffold(
          body: StatusCard(
            title: 'Foundation ready',
            description: 'Dependencies are injected.',
            icon: Icons.check_circle_outline,
          ),
        ),
      ),
    );

    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.text('Dependencies are injected.'), findsOneWidget);
  });
}
