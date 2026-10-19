import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final platform = arguments.contains('--ios') ? 'ios' : 'android';
  if (platform == 'ios' && !Platform.isMacOS) {
    throw UnsupportedError('The iOS rehearsal requires a macOS host.');
  }

  final repository = Directory.current.absolute;
  final temporaryRoot = await Directory.systemTemp.createTemp(
    'flutter-optional-capabilities-',
  );
  final appsDirectory = Directory(
    '${temporaryRoot.path}${Platform.pathSeparator}apps',
  );
  final appDirectory = Directory(
    '${appsDirectory.path}${Platform.pathSeparator}consumer_app',
  );

  try {
    await _copyPackages(repository, temporaryRoot);
    await appsDirectory.create(recursive: true);
    await _run('flutter', [
      'create',
      '--empty',
      '--platforms=$platform',
      '--org=com.example.capabilities',
      'consumer_app',
    ], appsDirectory.path);
    await _writeWorkspacePubspec(temporaryRoot);

    await _writeAppPubspec(appDirectory, includeOptionalCapabilities: true);
    await _writeMain(appDirectory, includeOptionalCapabilities: true);
    await _run('flutter', const ['pub', 'get'], temporaryRoot.path);
    await _assertDependencyState(
      temporaryRoot,
      expectsOptionalCapabilities: true,
    );
    await _run('flutter', const ['analyze'], appDirectory.path);
    await _build(appDirectory, platform);

    await _writeAppPubspec(appDirectory, includeOptionalCapabilities: false);
    await _writeMain(appDirectory, includeOptionalCapabilities: false);
    await _run('flutter', const ['pub', 'get'], temporaryRoot.path);
    await _assertDependencyState(
      temporaryRoot,
      expectsOptionalCapabilities: false,
    );
    await _run('flutter', const ['analyze'], appDirectory.path);
    await _build(appDirectory, platform);

    stdout.writeln(
      'PASS: FCM/realtime opt-in and removal both resolve and build on $platform.',
    );
  } finally {
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  }
}

Future<void> _copyPackages(
  Directory repository,
  Directory temporaryRoot,
) async {
  for (final name in const [
    'design_system',
    'notifications_core',
    'notifications_fcm',
    'platform_foundation',
    'realtime_core',
    'realtime_websocket',
  ]) {
    final source = Directory(
      '${repository.path}${Platform.pathSeparator}packages'
      '${Platform.pathSeparator}$name',
    );
    final destination = Directory(
      '${temporaryRoot.path}${Platform.pathSeparator}packages'
      '${Platform.pathSeparator}$name',
    );
    await _copyDirectory(source, destination);
  }
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entity in source.list()) {
    final name = entity.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;
    if (name == '.dart_tool' || name == 'build' || name == 'pubspec.lock') {
      continue;
    }
    final targetPath = '${destination.path}${Platform.pathSeparator}$name';
    if (entity is Directory) {
      await _copyDirectory(entity, Directory(targetPath));
    } else if (entity is File) {
      await entity.copy(targetPath);
    }
  }
}

Future<void> _writeWorkspacePubspec(Directory root) async {
  await File('${root.path}${Platform.pathSeparator}pubspec.yaml').writeAsString(
    '''
name: optional_capabilities_workspace
publish_to: none
environment:
  sdk: ">=3.12.1 <3.13.0"
workspace:
  - apps/consumer_app
  - packages/design_system
  - packages/notifications_core
  - packages/notifications_fcm
  - packages/platform_foundation
  - packages/realtime_core
  - packages/realtime_websocket
''',
  );
}

Future<void> _writeAppPubspec(
  Directory app, {
  required bool includeOptionalCapabilities,
}) async {
  final optional = includeOptionalCapabilities
      ? '''
  notifications_fcm: ^0.1.0
  realtime_websocket: ^0.1.0'''
      : '';
  await File('${app.path}${Platform.pathSeparator}pubspec.yaml').writeAsString(
    '''
name: consumer_app
description: Disposable optional-capability boundary proof.
publish_to: none
environment:
  sdk: ">=3.12.1 <3.13.0"
  flutter: ">=3.44.1 <3.45.0"
resolution: workspace
dependencies:
  flutter:
    sdk: flutter
  design_system: ^0.1.0
  platform_foundation: ^0.1.0
$optional
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''',
  );
}

Future<void> _writeMain(
  Directory app, {
  required bool includeOptionalCapabilities,
}) async {
  final imports = includeOptionalCapabilities
      ? "import 'package:notifications_fcm/notifications_fcm.dart';\n"
            "import 'package:realtime_websocket/realtime_websocket.dart';\n"
      : '';
  final evidence = includeOptionalCapabilities
      ? "const <Type>[FcmPushNotificationClient, RealtimeWebSocketClient]"
      : "const <Type>[]";
  await File(
    '${app.path}${Platform.pathSeparator}lib${Platform.pathSeparator}main.dart',
  ).writeAsString('''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:platform_foundation/platform_foundation.dart';
$imports
void main() {
  const Result<String> result = Success('ready');
  final optionalTypes = $evidence;
  runApp(MaterialApp(
    theme: PlatformTheme.light(seedColor: Colors.blue),
    home: Scaffold(body: Text('\${result.runtimeType}:\${optionalTypes.length}')),
  ));
}
''');
}

Future<void> _assertDependencyState(
  Directory root, {
  required bool expectsOptionalCapabilities,
}) async {
  final result = await Process.run(
    'flutter',
    const ['pub', 'deps', '--json'],
    workingDirectory: root.path,
    runInShell: Platform.isWindows,
  );
  if (result.exitCode != 0) {
    throw ProcessException(
      'flutter',
      const ['pub', 'deps', '--json'],
      result.stderr as String,
      result.exitCode,
    );
  }
  final document = jsonDecode(result.stdout as String) as Map<String, Object?>;
  final packages = <String, Set<String>>{
    for (final package
        in (document['packages']! as List<Object?>)
            .cast<Map<String, Object?>>())
      package['name']! as String: _runtimeDependencies(package),
  };
  final closure = <String>{};
  void collect(String name) {
    if (!closure.add(name)) {
      return;
    }
    for (final dependency in packages[name] ?? <String>{}) {
      collect(dependency);
    }
  }

  collect('consumer_app');
  final optional = closure.where(
    (name) =>
        name.startsWith('firebase_') ||
        name.startsWith('notifications_') ||
        name.startsWith('realtime_') ||
        name.contains('web_socket'),
  );
  if (expectsOptionalCapabilities &&
      (!closure.contains('notifications_fcm') ||
          !closure.contains('realtime_websocket'))) {
    throw StateError('Opt-in app did not resolve both optional adapters.');
  }
  if (!expectsOptionalCapabilities && optional.isNotEmpty) {
    throw StateError(
      'Removed optional capabilities remain in app runtime closure: $optional',
    );
  }
  stdout.writeln(
    'PASS: optional dependency state is '
    '${expectsOptionalCapabilities ? 'present' : 'absent'}.',
  );
}

Set<String> _runtimeDependencies(Map<String, Object?> package) {
  final direct = (package['directDependencies'] as List<Object?>? ?? const [])
      .whereType<String>()
      .toSet();
  final development = (package['devDependencies'] as List<Object?>? ?? const [])
      .whereType<String>()
      .toSet();
  return direct.difference(development);
}

Future<void> _build(Directory app, String platform) => platform == 'ios'
    ? _run('flutter', const [
        'build',
        'ios',
        '--debug',
        '--no-codesign',
        '--no-pub',
      ], app.path)
    : _run('flutter', const ['build', 'apk', '--debug', '--no-pub'], app.path);

Future<void> _run(
  String executable,
  List<String> arguments,
  String workingDirectory,
) async {
  stdout.writeln('> $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(executable, arguments, 'Command failed', exitCode);
  }
}
