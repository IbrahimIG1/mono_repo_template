import 'package:platform_foundation/platform_foundation.dart';
import 'package:test/test.dart';

void main() {
  test('redacts structured secrets and secret-bearing text', () {
    LogRecord? captured;
    final logger = StructuredLogger(
      (record) => captured = record,
      clock: () => DateTime.utc(2026, 10, 15),
    );

    logger.info(
      'GET /profile?token=abc Bearer visible-token',
      fields: {
        'accessToken': 'abc',
        'nested': {
          'password': 'unsafe',
          'url': '/refresh?refresh_token=refresh-value',
        },
      },
    );

    expect(captured, isNotNull);
    expect(captured!.message, isNot(contains('abc')));
    expect(captured!.message, isNot(contains('visible-token')));
    expect(captured!.fields['accessToken'], '<redacted>');
    expect(captured!.fields.toString(), isNot(contains('unsafe')));
    expect(captured!.fields.toString(), isNot(contains('refresh-value')));
    expect(captured!.timestamp, DateTime.utc(2026, 10, 15));
  });
}
