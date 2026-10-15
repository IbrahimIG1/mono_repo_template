import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/routing/destination_policy.dart';

void main() {
  group('AppDestinationPolicy', () {
    test('accepts a valid destination at the maximum length', () {
      final destination =
          '/protected/${List.filled(AppDestinationPolicy.maxDestinationLength - 11, 'a').join()}';

      expect(destination.length, AppDestinationPolicy.maxDestinationLength);
      expect(
        AppDestinationPolicy.safeInternalDestination(destination),
        destination,
      );
    });

    test('rejects a destination over the maximum length', () {
      final destination =
          '/protected/${List.filled(AppDestinationPolicy.maxDestinationLength - 10, 'a').join()}';

      expect(destination.length, AppDestinationPolicy.maxDestinationLength + 1);
      expect(AppDestinationPolicy.safeInternalDestination(destination), isNull);
    });

    test('rejects malformed percent encoding', () {
      expect(
        AppDestinationPolicy.safeInternalDestination('/protected/%ZZ'),
        isNull,
      );
    });

    test('rejects repeated destination query values', () {
      expect(
        AppDestinationPolicy.safeInternalDestination(
          '/protected/report?tab=one&tab=two',
        ),
        isNull,
      );
    });

    test('rejects repeated from query values', () {
      final uri = Uri.parse(
        '/sign-in?from=%2Fprotected%2Fa&from=%2Fprotected%2Fb',
      );

      expect(AppDestinationPolicy.singleQueryValue(uri, 'from'), isNull);
    });
  });
}
