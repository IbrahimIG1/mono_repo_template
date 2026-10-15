import 'package:platform_foundation/platform_foundation.dart';

import 'network_models.dart';

abstract interface class NetworkClient {
  Future<Result<NetworkResponse>> send(NetworkRequest request);

  void close();
}
