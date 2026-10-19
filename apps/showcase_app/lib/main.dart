import 'package:flutter/widgets.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'showcase_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = ShowcaseConfig.fromEnvironment();
  runApp(ShowcaseApp(config: config, logger: const NullLogger()));
}
