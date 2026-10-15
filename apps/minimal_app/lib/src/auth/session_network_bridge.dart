import 'package:auth_core/auth_core.dart';
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';

final class SessionAccessTokenProvider implements AccessTokenProvider {
  const SessionAccessTokenProvider(this.sessionManager);

  final SessionManager sessionManager;

  @override
  Future<String?> accessToken() async => sessionManager.currentAccessToken;
}

final class SessionUnauthorizedRecovery implements UnauthorizedRecovery {
  const SessionUnauthorizedRecovery(this.sessionManager);

  final SessionManager sessionManager;

  @override
  Future<Result<String>> recoverAccessToken({
    required String? failedAccessToken,
  }) => sessionManager.recoverAccessToken(failedAccessToken: failedAccessToken);
}
