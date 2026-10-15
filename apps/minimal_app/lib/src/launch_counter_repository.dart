import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/storage.dart';

final class LaunchCounterRepository {
  const LaunchCounterRepository(this._store);

  static const _key = 'minimal_app.launch_count';

  final KeyValueStore _store;

  Future<Result<int>> increment() async {
    final readResult = await _store.readInt(_key);
    switch (readResult) {
      case Failure<int?>(:final failure):
        return Failure(failure);
      case Success<int?>(:final value):
        final nextValue = (value ?? 0) + 1;
        final writeResult = await _store.writeInt(_key, nextValue);
        return switch (writeResult) {
          Failure<void>(:final failure) => Failure(failure),
          Success<void>() => Success(nextValue),
        };
    }
  }
}
