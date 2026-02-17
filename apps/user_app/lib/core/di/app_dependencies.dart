import 'package:sandwich_app/core/di/setup_for_cubits.dart';
import 'package:sandwich_app/core/di/setup_for_repos.dart';
import 'package:sandwich_app/core/di/setup_for_services.dart';

Future<void> setupAllDependencies() async {
  await SetupForServices.setupForServices();
  SetupForRepos.setupForRepos();
  SetupForCubits.setUpForCubits();
}
