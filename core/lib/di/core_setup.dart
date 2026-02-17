import 'package:core/di/di.dart';
import 'package:core/local/secure_storage_helper.dart';
import 'package:core/local/shared_prefrence.dart';
import 'package:core/network/api_sevices/dio_factory.dart';

Future<void> setupCoreDependencies() async {
  getIt.registerLazySingleton<DioFactory>(() => DioFactory());

  await SharedPreferencesHelper.init();
  getIt.registerSingleton<SharedPreferencesHelper>(SharedPreferencesHelper());
  getIt.registerSingleton<AppSecureStorageHelper>(AppSecureStorageHelper());
}
