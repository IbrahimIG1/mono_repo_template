import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'secure_string_store.dart';
import 'storage_failure.dart';

final class FlutterSecureStringStore implements SecureStringStore {
  const FlutterSecureStringStore(this._storage);

  factory FlutterSecureStringStore.create() =>
      const FlutterSecureStringStore(FlutterSecureStorage());

  final FlutterSecureStorage _storage;

  @override
  Future<Result<String?>> read(String key) async {
    try {
      return Success(await _storage.read(key: key));
    } on Object catch (error, stackTrace) {
      return Failure(_failure(StorageOperation.read, key, error, stackTrace));
    }
  }

  @override
  Future<Result<void>> remove(String key) async {
    try {
      await _storage.delete(key: key);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      return Failure(_failure(StorageOperation.remove, key, error, stackTrace));
    }
  }

  @override
  Future<Result<void>> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      return Failure(_failure(StorageOperation.write, key, error, stackTrace));
    }
  }

  StorageFailure _failure(
    StorageOperation operation,
    String key,
    Object error,
    StackTrace stackTrace,
  ) => StorageFailure(
    operation: operation,
    code: 'storage.secure.${operation.name}',
    message: 'Secure storage ${operation.name} failed for key "$key".',
    cause: error,
    stackTrace: stackTrace,
  );
}
