import 'dart:io';

import 'package:test/test.dart';

import '../verify_optional_capabilities.dart';

void main() {
  test(
    'rehearsal analyzes owned Dart source instead of generated products',
    () {
      expect(optionalCapabilityAnalyzeArguments, ['analyze', 'lib']);
      expect(optionalCapabilityAnalyzeArguments, isNot(contains('build')));
    },
  );

  test('opt-out rehearsal removes opt-in build products only', () async {
    final root = await Directory.systemTemp.createTemp(
      'capability-clean-test-',
    );
    try {
      final vendoredFixture = File(
        '${root.path}${Platform.pathSeparator}build${Platform.pathSeparator}'
        'ios${Platform.pathSeparator}SourcePackages${Platform.pathSeparator}'
        'firebase_messaging${Platform.pathSeparator}test${Platform.pathSeparator}'
        'mock.dart',
      );
      final appSource = File(
        '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}'
        'main.dart',
      );
      await vendoredFixture.parent.create(recursive: true);
      await vendoredFixture.writeAsString('generated dependency fixture');
      await appSource.parent.create(recursive: true);
      await appSource.writeAsString('void main() {}');

      await clearOptionalCapabilityBuildArtifacts(root);

      expect(
        Directory('${root.path}${Platform.pathSeparator}build').existsSync(),
        isFalse,
      );
      expect(appSource.existsSync(), isTrue);
    } finally {
      await root.delete(recursive: true);
    }
  });

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
