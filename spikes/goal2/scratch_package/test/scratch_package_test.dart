import 'package:scratch_package/scratch_package.dart';
import 'package:test/test.dart';

void main() {
  test('exposes deterministic workspace evidence', () {
    expect(
      describeWorkspaceResolution('/probe'),
      'resolved-from-scratch-package:/probe',
    );
  });
}
