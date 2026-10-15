import 'package:platform_foundation/platform_foundation.dart';

abstract interface class KeyValueStore {
  Future<Result<String?>> readString(String key);

  Future<Result<int?>> readInt(String key);

  Future<Result<bool?>> readBool(String key);

  Future<Result<void>> writeString(String key, String value);

  Future<Result<void>> writeInt(String key, int value);

  Future<Result<void>> writeBool(String key, bool value);

  Future<Result<void>> remove(String key);
}
