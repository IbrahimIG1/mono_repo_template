import 'dart:io';

import 'src/architecture_checker.dart';

Future<void> main() async {
  final checker = ArchitectureChecker(
    root: Directory.current,
    policy: ArchitecturePolicy.production,
  );
  final violations = await checker.check();
  if (violations.isNotEmpty) {
    for (final violation in violations) {
      stderr.writeln('FAIL: $violation');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'PASS: offline workspace dependencies and source boundaries are valid.',
  );
}
