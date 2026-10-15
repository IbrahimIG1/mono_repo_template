import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final repository = Directory.current.absolute;
  final temporaryRoot = await Directory.systemTemp.createTemp(
    'flutter-platform-consumer-',
  );
  final appsDirectory = Directory(
    '${temporaryRoot.path}${Platform.pathSeparator}apps',
  );
  final appDirectory = Directory(
    '${appsDirectory.path}${Platform.pathSeparator}consumer_app',
  );

  try {
    await _copyFoundationPackages(repository, temporaryRoot);
    await appsDirectory.create(recursive: true);
    await _run('flutter', const [
      'create',
      '--empty',
      '--platforms=android,ios',
      '--org=com.example.consumer',
      'consumer_app',
    ], appsDirectory.path);
    await _writeWorkspacePubspec(temporaryRoot);
    await _writeAppPubspec(appDirectory);
    await _writeMain(appDirectory);
    await _run('flutter', const ['pub', 'get'], temporaryRoot.path);
    await _assertMinimalDependencyBoundary(temporaryRoot);
    await _run('flutter', const ['analyze'], appDirectory.path);
    await _run('flutter', const [
      'build',
      'apk',
      '--debug',
      '--no-pub',
    ], appDirectory.path);
    stdout.writeln(
      'PASS: a temporary app consumed only foundation and design system.',
    );
  } finally {
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  }
}

Future<void> _copyFoundationPackages(
  Directory repository,
  Directory temporaryRoot,
) async {
  for (final name in const ['design_system', 'platform_foundation']) {
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
name: consumer_workspace
publish_to: none
environment:
  sdk: ">=3.12.1 <3.13.0"
workspace:
  - apps/consumer_app
  - packages/design_system
  - packages/platform_foundation
''',
  );
}

Future<void> _writeAppPubspec(Directory app) async {
  await File('${app.path}${Platform.pathSeparator}pubspec.yaml').writeAsString(
    '''
name: consumer_app
description: Temporary architecture-consumer proof.
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
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''',
  );
}

Future<void> _writeMain(Directory app) async {
  await File(
    '${app.path}${Platform.pathSeparator}lib${Platform.pathSeparator}main.dart',
  ).writeAsString(r'''
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:platform_foundation/platform_foundation.dart';

void main() {
  const Result<String> result = Success('ready');
  runApp(MaterialApp(
    theme: PlatformTheme.light(seedColor: Colors.blue),
    home: Scaffold(
      body: Text('${result.runtimeType}'),
    ),
  ));
}
''');
}

Future<void> _assertMinimalDependencyBoundary(Directory root) async {
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
  final runtimeClosure = <String>{};

  void collect(String name) {
    if (!runtimeClosure.add(name)) {
      return;
    }
    for (final dependency in packages[name] ?? <String>{}) {
      collect(dependency);
    }
  }

  collect('consumer_app');
  const forbidden = {
    'auth_core',
    'auth_ui',
    'dio',
    'firebase_core',
    'firebase_messaging',
    'networking',
    'storage',
    'core',
    'shared',
  };
  final violations = runtimeClosure.intersection(forbidden).toList()..sort();
  final namedViolations =
      runtimeClosure
          .where(
            (name) =>
                name.contains('chat') ||
                name.contains('realtime') ||
                name.contains('socket_io') ||
                name.contains('web_socket'),
          )
          .toList()
        ..sort();
  if (violations.isNotEmpty || namedViolations.isNotEmpty) {
    throw StateError(
      'Temporary minimal consumer pulled forbidden dependencies: '
      '${[...violations, ...namedViolations]}',
    );
  }
  stdout.writeln('PASS: temporary consumer dependency boundary is minimal.');
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
