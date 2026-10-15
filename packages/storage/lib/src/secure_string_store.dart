import 'package:platform_foundation/platform_foundation.dart';

abstract interface class SecureStringStore {
  Future<Result<String?>> read(String key);

  Future<Result<void>> write(String key, String value);

  Future<Result<void>> remove(String key);
}
