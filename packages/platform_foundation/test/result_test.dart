import 'package:platform_foundation/platform_foundation.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('fold handles success', () {
      const result = Success<int>(7);

      final output = result.fold(
        onSuccess: (value) => 'value:$value',
        onFailure: (failure) => failure.code,
      );

      expect(output, 'value:7');
    });

    test('fold handles a capability-owned failure', () {
      const result = Failure<int>(_TestFailure());

      final output = result.fold(
        onSuccess: (value) => '$value',
        onFailure: (failure) => failure.code,
      );

      expect(output, 'test.failed');
    });
  });
}

final class _TestFailure extends AppFailure {
  const _TestFailure()
    : super(code: 'test.failed', message: 'Expected failure');
}
