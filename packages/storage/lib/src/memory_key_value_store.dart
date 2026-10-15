import 'package:platform_foundation/platform_foundation.dart';

import 'key_value_store.dart';

final class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore({Map<String, Object>? initialValues})
    : _values = {...?initialValues};

  final Map<String, Object> _values;

  @override
  Future<Result<bool?>> readBool(String key) async =>
      Success(_values[key] as bool?);

  @override
  Future<Result<int?>> readInt(String key) async =>
      Success(_values[key] as int?);

  @override
  Future<Result<String?>> readString(String key) async =>
      Success(_values[key] as String?);

  @override
  Future<Result<void>> remove(String key) async {
    _values.remove(key);
    return const Success(null);
  }

  @override
  Future<Result<void>> writeBool(String key, bool value) async {
    _values[key] = value;
    return const Success(null);
  }

  @override
  Future<Result<void>> writeInt(String key, int value) async {
    _values[key] = value;
    return const Success(null);
  }

  @override
  Future<Result<void>> writeString(String key, String value) async {
    _values[key] = value;
    return const Success(null);
  }
}
