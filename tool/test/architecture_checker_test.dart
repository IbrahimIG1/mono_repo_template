import 'dart:io';

import 'package:test/test.dart';

import '../src/architecture_checker.dart';

void main() {
  group('offline architecture fixtures', () {
    test('rejects a local dependency cycle', () async {
      final violations = await _checkFixture(
        'dependency_cycle',
        const ArchitecturePolicy(
          workspaceMembers: {'a', 'b'},
          allowedLocalDependencies: {
            'a': {'b'},
            'b': {'a'},
          },
          minimalApp: 'a',
          sourceRoots: [],
          presentationRoots: [],
        ),
      );

      expect(violations, contains(contains('Local dependency cycle:')));
    });

    test('rejects a forbidden transitive dependency', () async {
      final violations = await _checkFixture(
        'forbidden_transitive',
        const ArchitecturePolicy(
          workspaceMembers: {'minimal_app', 'bridge'},
          allowedLocalDependencies: {
            'minimal_app': {'bridge'},
            'bridge': <String>{},
          },
          minimalApp: 'minimal_app',
          sourceRoots: [],
          presentationRoots: [],
        ),
      );

      expect(
        violations,
        contains(
          contains('minimal_app pulls forbidden dependencies: [firebase_core]'),
        ),
      );
    });

    test('rejects a presentation class importing a gateway', () async {
      final violations = await _checkFixture(
        'presentation_gateway',
        const ArchitecturePolicy(
          workspaceMembers: {'app'},
          allowedLocalDependencies: {'app': <String>{}},
          minimalApp: 'app',
          sourceRoots: ['packages/app/lib'],
          presentationRoots: ['packages/app/lib/presentation'],
        ),
      );

      expect(
        violations,
        contains(contains('presentation references a gateway')),
      );
    });

    test(
      'rejects platform dependencies and imports in capability cores',
      () async {
        final violations = await _checkFixture(
          'capability_core_platform_leak',
          const ArchitecturePolicy(
            workspaceMembers: {'realtime_core'},
            allowedLocalDependencies: {'realtime_core': <String>{}},
            minimalApp: 'realtime_core',
            sourceRoots: [],
            presentationRoots: [],
            pureCapabilityCores: {'realtime_core'},
          ),
        );

        expect(
          violations,
          contains(
            contains(
              'realtime_core pulls platform dependencies: [firebase_core]',
            ),
          ),
        );
        expect(
          violations,
          contains(
            contains('pure capability core imports a platform dependency'),
          ),
        );
      },
    );
  });
}

Future<List<String>> _checkFixture(String name, ArchitecturePolicy policy) =>
    ArchitectureChecker(
      root: Directory('tool/test/fixtures/$name'),
      policy: policy,
      packageConfigPath: 'package_config.json',
    ).check();
