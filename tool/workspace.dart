import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final task = arguments.firstOrNull ?? 'verify';
  final packages = await _workspacePackages();

  if (task == 'list') {
    for (final package in packages) {
      stdout.writeln('${package.name}\t${package.kind}\t${package.path}');
    }
    return;
  }

  final tasks = task == 'verify'
      ? const ['format', 'analyze', 'test', 'routes']
      : [task];
  for (final currentTask in tasks) {
    for (final package in packages) {
      await _runTask(currentTask, package);
    }
  }
}

Future<List<_WorkspacePackage>> _workspacePackages() async {
  final result = await Process.run('dart', const [
    'pub',
    'workspace',
    'list',
    '--json',
  ], runInShell: Platform.isWindows);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw StateError('Unable to list Pub Workspace members.');
  }

  final root = _normalized(Directory.current.absolute.path);
  final document = jsonDecode(result.stdout as String) as Map<String, Object?>;
  final entries = document['packages']! as List<Object?>;
  final packages = <_WorkspacePackage>[];

  for (final entry in entries.cast<Map<String, Object?>>()) {
    final path = entry['path']! as String;
    if (_normalized(path) == root) {
      continue;
    }
    final pubspec = File('$path${Platform.pathSeparator}pubspec.yaml');
    final content = await pubspec.readAsString();
    packages.add(
      _WorkspacePackage(
        name: entry['name']! as String,
        path: path,
        usesFlutter: content.contains(
          RegExp(r'^\s+sdk:\s+flutter\s*$', multiLine: true),
        ),
        generatesRoutes: content.contains(
          RegExp(r'^\s+go_router_builder:', multiLine: true),
        ),
      ),
    );
  }

  return packages;
}

Future<void> _runTask(String task, _WorkspacePackage package) async {
  stdout.writeln('\n[$task] ${package.name}');
  switch (task) {
    case 'format':
      final paths = const ['lib', 'test', 'integration_test', 'test_driver']
          .where(
            (path) => Directory(
              '${package.path}${Platform.pathSeparator}$path',
            ).existsSync(),
          )
          .toList();
      if (paths.isEmpty) {
        stdout.writeln('SKIP: no Dart source directories');
        return;
      }
      await _run('dart', [
        'format',
        '--output=none',
        '--set-exit-if-changed',
        ...paths,
      ], package.path);
    case 'analyze':
      await _run(
        package.usesFlutter ? 'flutter' : 'dart',
        package.usesFlutter ? const ['analyze', '--no-pub'] : const ['analyze'],
        package.path,
      );
    case 'test':
      final testDirectory = Directory(
        '${package.path}${Platform.pathSeparator}test',
      );
      if (!testDirectory.existsSync()) {
        stdout.writeln('SKIP: no test directory');
        return;
      }
      await _run(
        package.usesFlutter ? 'flutter' : 'dart',
        package.usesFlutter ? const ['test', '--no-pub'] : const ['test'],
        package.path,
      );
    case 'routes':
      if (!package.generatesRoutes) {
        stdout.writeln('SKIP: no go_router_builder dependency');
        return;
      }
      final committed = await _generatedSnapshot(package.path);
      await _run('dart', const ['run', 'build_runner', 'build'], package.path);
      final first = await _generatedSnapshot(package.path);
      if (!_sameSnapshot(committed, first)) {
        throw StateError(
          '${package.name} generated files were not up to date before the '
          'route gate. Run generation and commit the result.',
        );
      }
      await _run('dart', const ['run', 'build_runner', 'build'], package.path);
      final second = await _generatedSnapshot(package.path);
      if (!_sameSnapshot(first, second)) {
        throw StateError(
          '${package.name} generation changed on its second run.',
        );
      }
      stdout.writeln('PASS: generated files are stable on the second run');
    default:
      throw ArgumentError.value(task, 'task', 'Unsupported workspace task');
  }
}

Future<void> _run(
  String executable,
  List<String> arguments,
  String path,
) async {
  stdout.writeln('> $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: path,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(executable, arguments, 'Task failed', exitCode);
  }
}

Future<Map<String, String>> _generatedSnapshot(String packagePath) async {
  final lib = Directory('$packagePath${Platform.pathSeparator}lib');
  final result = <String, String>{};
  await for (final entity in lib.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.g.dart')) {
      result[_normalized(entity.path)] = (await entity.readAsString())
          .replaceAll('\r\n', '\n');
    }
  }
  return result;
}

bool _sameSnapshot(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length || !left.keys.every(right.containsKey)) {
    return false;
  }
  for (final key in left.keys) {
    if (left[key] != right[key]) {
      return false;
    }
  }
  return true;
}

String _normalized(String path) {
  final normalized = Directory(path).absolute.path.replaceAll('\\', '/');
  return Platform.isWindows ? normalized.toLowerCase() : normalized;
}

final class _WorkspacePackage {
  const _WorkspacePackage({
    required this.name,
    required this.path,
    required this.usesFlutter,
    required this.generatesRoutes,
  });

  final String name;
  final String path;
  final bool usesFlutter;
  final bool generatesRoutes;

  String get kind => usesFlutter ? 'flutter' : 'dart';
}
