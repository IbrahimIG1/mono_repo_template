import 'package:flutter_test/flutter_test.dart';
import 'package:goal2_scratch_app/main.dart';

void main() {
  testWidgets('workspace dependency and typed route render', (tester) async {
    await tester.pumpWidget(const SpikeApp());

    expect(find.text('resolved-from-scratch-package:/'), findsOneWidget);
    await tester.tap(find.text('Open typed route'));
    await tester.pumpAndSettle();

    expect(find.text('typed-route:home'), findsOneWidget);
  });
}
