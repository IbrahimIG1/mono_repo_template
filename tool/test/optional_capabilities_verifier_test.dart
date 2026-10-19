import 'dart:io';

import 'package:test/test.dart';

import '../verify_optional_capabilities.dart';

void main() {
  test('iOS rehearsal raises every app deployment target to 15.0', () async {
    final root = await Directory.systemTemp.createTemp('ios-target-test-');
    try {
      final project = File(
        '${root.path}${Platform.pathSeparator}ios${Platform.pathSeparator}'
        'Runner.xcodeproj${Platform.pathSeparator}project.pbxproj',
      );
      await project.parent.create(recursive: true);
      await project.writeAsString('''
buildSettings = {
  IPHONEOS_DEPLOYMENT_TARGET = 13.0;
};
buildSettings = {
  IPHONEOS_DEPLOYMENT_TARGET = 14.0;
};
''');

      await configureIosMinimumVersionForRehearsal(root);

      final content = await project.readAsString();
      expect(content, isNot(contains('13.0')));
      expect(content, isNot(contains('14.0')));
      expect(
        RegExp('IPHONEOS_DEPLOYMENT_TARGET = 15.0;').allMatches(content).length,
        2,
      );
    } finally {
      await root.delete(recursive: true);
    }
  });
}
