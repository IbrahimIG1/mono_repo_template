import 'package:platform_foundation/platform_foundation.dart';

abstract interface class AccessTokenProvider {
  Future<String?> accessToken();
}

abstract interface class UnauthorizedRecovery {
  Future<Result<String>> recoverAccessToken({
    required String? failedAccessToken,
  });
}
