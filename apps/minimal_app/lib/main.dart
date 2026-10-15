import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/app_composition.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MinimalApp(composition: AppComposition.create()));
}
