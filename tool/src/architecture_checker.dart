import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

final class ArchitecturePolicy {
  const ArchitecturePolicy({
    required this.workspaceMembers,
    required this.allowedLocalDependencies,
    required this.minimalApp,
    required this.sourceRoots,
    required this.presentationRoots,
    this.authCore,
  });

  static const production = ArchitecturePolicy(
    workspaceMembers: {
      'minimal_app',
      'auth_core',
      'auth_ui',
      'design_system',
      'networking',
      'platform_foundation',
      'storage',
    },
    allowedLocalDependencies: {
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
    },
    minimalApp: 'minimal_app',
    authCore: 'auth_core',
    sourceRoots: ['apps/minimal_app/lib', 'packages'],
    presentationRoots: ['packages/auth_ui/lib', 'apps/minimal_app/lib/src/ui'],
  );

  final Set<String> workspaceMembers;
  final Map<String, Set<String>> allowedLocalDependencies;
  final String minimalApp;
  final String? authCore;
  final List<String> sourceRoots;
  final List<String> presentationRoots;
}

final class ArchitectureChecker {
  const ArchitectureChecker({
    required this.root,
    required this.policy,
    this.packageConfigPath = '.dart_tool/package_config.json',
    this.lockFilePath = 'pubspec.lock',
  });

  final Directory root;
  final ArchitecturePolicy policy;
  final String packageConfigPath;
  final String lockFilePath;

  Future<List<String>> check() async {
    final violations = <String>[];
    final graph = await _loadGraph(violations);
    if (graph == null) {
      return violations;
    }
    _checkWorkspaceMembers(graph, violations);
    _checkAllowedEdges(graph, violations);
    _checkCycles(graph, violations);
    _checkMinimalRuntimeClosure(graph, violations);
    _checkAuthCoreClosure(graph, violations);
    await _checkSourceRules(violations);
    return violations;
  }

  Future<Map<String, _Package>?> _loadGraph(List<String> violations) async {
    final packageConfig = _file(packageConfigPath);
    final lockFile = _file(lockFilePath);
    if (!packageConfig.existsSync()) {
      violations.add('Missing $packageConfigPath; run pub get first.');
      return null;
    }
    if (!lockFile.existsSync()) {
      violations.add('Missing $lockFilePath; locked resolution is required.');
      return null;
    }

    late final Map<String, Object?> config;
    late final Set<String> lockedPackages;
    try {
      config =
          jsonDecode(await packageConfig.readAsString())
              as Map<String, Object?>;
      final lock = loadYaml(await lockFile.readAsString());
      lockedPackages = _mappingKeys(_mappingValue(lock, 'packages'));
    } on Object catch (error) {
      violations.add('Unable to parse package_config/lock: $error');
      return null;
    }

    final entries = config['packages'];
    if (entries is! List<Object?>) {
      violations.add('package_config.json has no packages list.');
      return null;
    }

    final graph = <String, _Package>{};
    for (final value in entries) {
      if (value is! Map<String, Object?>) {
        continue;
      }
      final name = value['name'];
      final rootUri = value['rootUri'];
      if (name is! String || rootUri is! String) {
        continue;
      }
      final packageRoot = Directory.fromUri(
        packageConfig.absolute.uri.resolve(rootUri),
      );
      final pubspec = File(
        '${packageRoot.path}${Platform.pathSeparator}pubspec.yaml',
      );
      final dependencies = pubspec.existsSync()
          ? _runtimeDependencies(await pubspec.readAsString())
          : <String>{};
      graph[name] = _Package(
        name: name,
        root: packageRoot,
        runtimeDependencies: dependencies,
      );
    }

    final rootName = _pubspecName(_file('pubspec.yaml'));
    for (final package in graph.values) {
      if (package.name == rootName ||
          policy.workspaceMembers.contains(package.name)) {
        continue;
      }
      if (!lockedPackages.contains(package.name)) {
        violations.add(
          '${package.name} is resolved in package_config but absent from pubspec.lock.',
        );
      }
    }
    for (final package in graph.values) {
      for (final dependency in package.runtimeDependencies) {
        if (!graph.containsKey(dependency)) {
          violations.add(
            '${package.name} depends on unresolved package $dependency.',
          );
        }
      }
    }
    return graph;
  }

  void _checkWorkspaceMembers(
    Map<String, _Package> graph,
    List<String> violations,
  ) {
    final rootPubspec = loadYaml(_file('pubspec.yaml').readAsStringSync());
    final workspacePaths = _listValue(rootPubspec, 'workspace');
    final actual = <String>{};
    for (final path in workspacePaths) {
      final pubspec = File(
        '${root.path}${Platform.pathSeparator}$path${Platform.pathSeparator}pubspec.yaml',
      );
      if (!pubspec.existsSync()) {
        violations.add('Workspace path has no pubspec: $path');
        continue;
      }
      actual.add(_pubspecName(pubspec));
    }
    if (!_sameSet(actual, policy.workspaceMembers)) {
      violations.add(
        'Unexpected workspace members: $actual; expected ${policy.workspaceMembers}.',
      );
    }
    final missingFromResolution = policy.workspaceMembers.difference(
      graph.keys.toSet(),
    );
    if (missingFromResolution.isNotEmpty) {
      violations.add(
        'Workspace members absent from package_config: $missingFromResolution.',
      );
    }
  }

  void _checkAllowedEdges(
    Map<String, _Package> graph,
    List<String> violations,
  ) {
    for (final entry in policy.allowedLocalDependencies.entries) {
      final package = graph[entry.key];
      if (package == null) {
        continue;
      }
      final localDependencies = package.runtimeDependencies
          .where(policy.workspaceMembers.contains)
          .toSet();
      if (!_sameSet(localDependencies, entry.value)) {
        violations.add(
          '${entry.key} has local dependencies $localDependencies; '
          'expected ${entry.value}.',
        );
      }
    }
  }

  void _checkCycles(Map<String, _Package> graph, List<String> violations) {
    final visiting = <String>{};
    final visited = <String>{};
    var foundCycle = false;

    void visit(String name, List<String> path) {
      if (foundCycle) {
        return;
      }
      if (visiting.contains(name)) {
        violations.add(
          'Local dependency cycle: ${[...path, name].join(' -> ')}',
        );
        foundCycle = true;
        return;
      }
      if (!visited.add(name)) {
        return;
      }
      visiting.add(name);
      for (final dependency in graph[name]?.runtimeDependencies ?? <String>{}) {
        if (policy.workspaceMembers.contains(dependency)) {
          visit(dependency, [...path, name]);
        }
      }
      visiting.remove(name);
    }

    for (final package in policy.workspaceMembers) {
      visit(package, const []);
    }
  }

  void _checkMinimalRuntimeClosure(
    Map<String, _Package> graph,
    List<String> violations,
  ) {
    final closure = _runtimeClosure(policy.minimalApp, graph);
    final forbidden = closure.where(_isForbiddenDependency).toList()..sort();
    if (forbidden.isNotEmpty) {
      violations.add(
        '${policy.minimalApp} pulls forbidden dependencies: $forbidden',
      );
    }
  }

  void _checkAuthCoreClosure(
    Map<String, _Package> graph,
    List<String> violations,
  ) {
    final authCore = policy.authCore;
    if (authCore == null || !graph.containsKey(authCore)) {
      return;
    }
    final closure = _runtimeClosure(authCore, graph);
    const forbidden = {
      'dio',
      'flutter',
      'flutter_bloc',
      'flutter_secure_storage',
      'go_router',
      'shared_preferences',
    };
    final found = closure.intersection(forbidden).toList()..sort();
    if (found.isNotEmpty) {
      violations.add('$authCore pulls forbidden dependencies: $found');
    }
  }

  Future<void> _checkSourceRules(List<String> violations) async {
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
    for (final path in policy.sourceRoots) {
      final directory = _directory(path);
      if (!directory.existsSync()) {
        continue;
      }
      await for (final entity in directory.list(recursive: true)) {
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
    await _checkPresentationHasNoGateway(violations);
  }

  Future<void> _checkPresentationHasNoGateway(List<String> violations) async {
    final gatewayPattern = RegExp(
      r'\b(?:AuthGateway|SessionGateway)\b|auth_gateway\.dart|session_gateway\.dart',
    );
    for (final path in policy.presentationRoots) {
      final directory = _directory(path);
      if (!directory.existsSync()) {
        continue;
      }
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File &&
            (entity.path.endsWith('.dart') ||
                entity.path.endsWith('.dart.fixture'))) {
          final content = await entity.readAsString();
          if (gatewayPattern.hasMatch(content)) {
            violations.add('${entity.path}: presentation references a gateway');
          }
        }
      }
    }
  }

  File _file(String path) => File('${root.path}${Platform.pathSeparator}$path');

  Directory _directory(String path) =>
      Directory('${root.path}${Platform.pathSeparator}$path');
}

Set<String> _runtimeClosure(String start, Map<String, _Package> graph) {
  final closure = <String>{};
  void collect(String name) {
    if (!closure.add(name)) {
      return;
    }
    for (final dependency in graph[name]?.runtimeDependencies ?? <String>{}) {
      collect(dependency);
    }
  }

  collect(start);
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

Set<String> _runtimeDependencies(String pubspecSource) {
  final document = loadYaml(pubspecSource);
  return _mappingKeys(_mappingValue(document, 'dependencies'));
}

String _pubspecName(File pubspec) {
  final document = loadYaml(pubspec.readAsStringSync());
  final name = _mappingValue(document, 'name');
  if (name is! String) {
    throw FormatException('${pubspec.path} has no package name.');
  }
  return name;
}

Object? _mappingValue(Object? value, String key) =>
    value is Map<Object?, Object?> ? value[key] : null;

Set<String> _mappingKeys(Object? value) => value is Map<Object?, Object?>
    ? value.keys.whereType<String>().toSet()
    : <String>{};

List<String> _listValue(Object? value, String key) {
  final list = _mappingValue(value, key);
  return list is List<Object?> ? list.whereType<String>().toList() : <String>[];
}

bool _sameSet(Set<String> left, Set<String> right) =>
    left.length == right.length && left.containsAll(right);

final class _Package {
  const _Package({
    required this.name,
    required this.root,
    required this.runtimeDependencies,
  });

  final String name;
  final Directory root;
  final Set<String> runtimeDependencies;
}
