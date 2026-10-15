import 'dart:convert';
import 'dart:io';

const _workspaceMembers = {
  'minimal_app',
  'auth_core',
  'auth_ui',
  'design_system',
  'networking',
  'platform_foundation',
  'storage',
};

const _allowedLocalDependencies = {
  'minimal_app': {
    'auth_core',
    'auth_ui',
    'design_system',
    'networking',
    'platform_foundation',
    'storage',
  },
  'auth_core': {'platform_foundation'},
  'auth_ui': {'auth_core', 'platform_foundation'},
  'design_system': <String>{},
  'networking': {'platform_foundation'},
  'platform_foundation': <String>{},
  'storage': {'platform_foundation'},
};

Future<void> main() async {
  final packages = await _dependencyGraph();
  _checkWorkspaceMembers(packages);
  _checkAllowedEdges(packages);
  _checkCycles(packages);
  _checkMinimalRuntimeClosure(packages);
  _checkAuthCoreClosure(packages);
  await _checkSourceRules();
  stdout.writeln(
    'PASS: workspace dependencies and source boundaries are valid.',
  );
}

Future<Map<String, _Package>> _dependencyGraph() async {
  final result = await Process.run('dart', const ['pub', 'deps', '--json']);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw StateError('Unable to inspect the dependency graph.');
  }
  final document = jsonDecode(result.stdout as String) as Map<String, Object?>;
  final entries = document['packages']! as List<Object?>;
  return {
    for (final entry in entries.cast<Map<String, Object?>>())
      entry['name']! as String: _Package.fromJson(entry),
  };
}

void _checkWorkspaceMembers(Map<String, _Package> packages) {
  final actual = packages.values
      .where((package) => package.source == 'root')
      .map((package) => package.name)
      .where((name) => name != 'flutter_platform_workspace')
      .toSet();
  if (!_sameSet(actual, _workspaceMembers)) {
    throw StateError('Unexpected workspace members: $actual');
  }
}

void _checkAllowedEdges(Map<String, _Package> packages) {
  for (final entry in _allowedLocalDependencies.entries) {
    final package = packages[entry.key]!;
    final localDependencies = package.runtimeDependencies
        .where(_workspaceMembers.contains)
        .toSet();
    if (!_sameSet(localDependencies, entry.value)) {
      throw StateError(
        '${entry.key} has local dependencies $localDependencies; '
        'expected ${entry.value}.',
      );
    }
  }
}

void _checkCycles(Map<String, _Package> packages) {
  final visiting = <String>{};
  final visited = <String>{};

  void visit(String name, List<String> path) {
    if (visiting.contains(name)) {
      throw StateError(
        'Local dependency cycle: ${[...path, name].join(' -> ')}',
      );
    }
    if (!visited.add(name)) {
      return;
    }
    visiting.add(name);
    for (final dependency in packages[name]!.runtimeDependencies) {
      if (_workspaceMembers.contains(dependency)) {
        visit(dependency, [...path, name]);
      }
    }
    visiting.remove(name);
  }

  for (final package in _workspaceMembers) {
    visit(package, const []);
  }
}

void _checkMinimalRuntimeClosure(Map<String, _Package> packages) {
  final closure = <String>{};

  void collect(String name) {
    if (!closure.add(name)) {
      return;
    }
    for (final dependency
        in packages[name]?.runtimeDependencies ?? const <String>{}) {
      collect(dependency);
    }
  }

  collect('minimal_app');
  final forbidden = closure.where(_isForbiddenDependency).toList()..sort();
  if (forbidden.isNotEmpty) {
    throw StateError('minimal_app pulls forbidden dependencies: $forbidden');
  }
}

void _checkAuthCoreClosure(Map<String, _Package> packages) {
  final closure = _runtimeClosure('auth_core', packages);
  const forbidden = {
    'dio',
    'flutter',
    'flutter_bloc',
    'flutter_secure_storage',
    'go_router',
    'shared_preferences',
  };
  final violations = closure.intersection(forbidden).toList()..sort();
  if (violations.isNotEmpty) {
    throw StateError('auth_core pulls forbidden dependencies: $violations');
  }
}

Set<String> _runtimeClosure(String root, Map<String, _Package> packages) {
  final closure = <String>{};

  void collect(String name) {
    if (!closure.add(name)) {
      return;
    }
    for (final dependency
        in packages[name]?.runtimeDependencies ?? const <String>{}) {
      collect(dependency);
    }
  }

  collect(root);
  return closure;
}

bool _isForbiddenDependency(String name) {
  final normalized = name.toLowerCase();
  return normalized == 'core' ||
      normalized == 'shared' ||
      normalized.contains('firebase') ||
      normalized.contains('chat') ||
      normalized.contains('realtime') ||
      normalized.contains('socket_io') ||
      normalized.contains('web_socket');
}

Future<void> _checkSourceRules() async {
  final roots = [Directory('apps/minimal_app/lib'), Directory('packages')];
  final violations = <String>[];
  final rules = <({RegExp pattern, String reason})>[
    (
      pattern: RegExp(r"package:(?:get_it|core|shared)/"),
      reason: 'forbidden service-locator or legacy import',
    ),
    (
      pattern: RegExp(r'GetIt\.instance|getIt\s*<'),
      reason: 'service-locator access outside an app composition root',
    ),
    (
      pattern: RegExp(
        r'static\s+(?:final\s+)?(?:Dio|FlutterSecureStorage|SharedPreferences)\??',
      ),
      reason: 'global client or storage instance',
    ),
  ];

  for (final root in roots) {
    await for (final entity in root.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final content = await entity.readAsString();
      for (final rule in rules) {
        if (rule.pattern.hasMatch(content)) {
          violations.add('${entity.path}: ${rule.reason}');
        }
      }
    }
  }
  if (violations.isNotEmpty) {
    throw StateError(violations.join('\n'));
  }

  await _checkPresentationHasNoGateway();
}

Future<void> _checkPresentationHasNoGateway() async {
  final roots = [
    Directory('packages/auth_ui/lib'),
    Directory('apps/minimal_app/lib/src/ui'),
  ];
  final violations = <String>[];
  final gatewayPattern = RegExp(r'\b(?:AuthGateway|SessionGateway)\b');
  for (final root in roots) {
    await for (final entity in root.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        if (gatewayPattern.hasMatch(content)) {
          violations.add('${entity.path}: presentation references a gateway');
        }
      }
    }
  }
  if (violations.isNotEmpty) {
    throw StateError(violations.join('\n'));
  }
}

bool _sameSet(Set<String> left, Set<String> right) =>
    left.length == right.length && left.containsAll(right);

final class _Package {
  const _Package({
    required this.name,
    required this.source,
    required this.runtimeDependencies,
  });

  factory _Package.fromJson(Map<String, Object?> json) {
    final direct = (json['directDependencies'] as List<Object?>? ?? const [])
        .cast<String>();
    final development = (json['devDependencies'] as List<Object?>? ?? const [])
        .cast<String>()
        .toSet();
    return _Package(
      name: json['name']! as String,
      source: json['source']! as String,
      runtimeDependencies: direct
          .where((name) => !development.contains(name))
          .toSet(),
    );
  }

  final String name;
  final String source;
  final Set<String> runtimeDependencies;
}
