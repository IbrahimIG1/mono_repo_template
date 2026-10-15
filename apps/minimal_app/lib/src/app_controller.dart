import 'package:flutter/foundation.dart';
import 'package:platform_foundation/platform_foundation.dart';

import 'launch_counter_repository.dart';

sealed class AppLoadState {
  const AppLoadState();
}

final class AppLoading extends AppLoadState {
  const AppLoading();
}

final class AppReady extends AppLoadState {
  const AppReady(this.launchCount);

  final int launchCount;
}

final class AppLoadFailed extends AppLoadState {
  const AppLoadFailed(this.failure);

  final AppFailure failure;
}

final class AppController extends ChangeNotifier {
  AppController(this._launchCounterRepository);

  final LaunchCounterRepository _launchCounterRepository;
  AppLoadState _state = const AppLoading();
  bool _disposed = false;

  AppLoadState get state => _state;

  Future<void> load() async {
    final result = await _launchCounterRepository.increment();
    if (_disposed) {
      return;
    }
    _state = switch (result) {
      Success<int>(:final value) => AppReady(value),
      Failure<int>(:final failure) => AppLoadFailed(failure),
    };
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
