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
    await _run('flutter', const ['analyze'], appDirectory.path);
    await _run('flutter', const [
      'build',
      'apk',
      '--debug',
      '--no-pub',
    ], appDirectory.path);
    stdout.writeln(
      'PASS: a temporary third app consumed all four foundation packages.',
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
  for (final name in const [
    'design_system',
    'networking',
    'platform_foundation',
    'storage',
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
name: consumer_workspace
publish_to: none
environment:
  sdk: ">=3.12.1 <3.13.0"
workspace:
  - apps/consumer_app
  - packages/design_system
  - packages/networking
  - packages/platform_foundation
  - packages/storage
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
  networking: ^0.1.0
  platform_foundation: ^0.1.0
  storage: ^0.1.0
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
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

void main() {
  const Result<String> result = Success('ready');
  final NetworkConfiguration network = NetworkConfiguration(
    baseUri: Uri.parse('https://example.invalid'),
  );
  final KeyValueStore store = MemoryKeyValueStore();
  runApp(MaterialApp(
    theme: PlatformTheme.light(seedColor: Colors.blue),
    home: Scaffold(
      body: Text('${result.runtimeType} ${network.baseUri.host} ${store.runtimeType}'),
    ),
  ));
}
''');
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
