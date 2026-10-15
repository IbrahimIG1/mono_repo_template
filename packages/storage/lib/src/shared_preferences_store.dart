import 'package:platform_foundation/platform_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';
import 'storage_failure.dart';

final class SharedPreferencesStore implements KeyValueStore {
  const SharedPreferencesStore(this._preferences);

  factory SharedPreferencesStore.create() =>
      SharedPreferencesStore(SharedPreferencesAsync());

  final SharedPreferencesAsync _preferences;

  @override
  Future<Result<bool?>> readBool(String key) =>
      _read(key, () => _preferences.getBool(key));

  @override
  Future<Result<int?>> readInt(String key) =>
      _read(key, () => _preferences.getInt(key));

  @override
  Future<Result<String?>> readString(String key) =>
      _read(key, () => _preferences.getString(key));

  @override
  Future<Result<void>> remove(String key) =>
      _write(key, StorageOperation.remove, () => _preferences.remove(key));

  @override
  Future<Result<void>> writeBool(String key, bool value) => _write(
    key,
    StorageOperation.write,
    () => _preferences.setBool(key, value),
  );

  @override
  Future<Result<void>> writeInt(String key, int value) => _write(
    key,
    StorageOperation.write,
    () => _preferences.setInt(key, value),
  );

  @override
  Future<Result<void>> writeString(String key, String value) => _write(
    key,
    StorageOperation.write,
    () => _preferences.setString(key, value),
  );

  Future<Result<T?>> _read<T>(String key, Future<T?> Function() action) async {
    try {
      return Success(await action());
    } on Object catch (error, stackTrace) {
      return Failure(_failure(StorageOperation.read, key, error, stackTrace));
    }
  }

  Future<Result<void>> _write(
    String key,
    StorageOperation operation,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return const Success(null);
    } on Object catch (error, stackTrace) {
      return Failure(_failure(operation, key, error, stackTrace));
    }
  }

  StorageFailure _failure(
    StorageOperation operation,
    String key,
    Object error,
    StackTrace stackTrace,
  ) => StorageFailure(
    operation: operation,
    code: 'storage.preferences.${operation.name}',
    message: 'Preferences ${operation.name} failed for key "$key".',
    cause: error,
    stackTrace: stackTrace,
  );
}
