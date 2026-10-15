import 'package:platform_foundation/platform_foundation.dart';

import 'auth_session.dart';

abstract interface class AuthCredential {}

abstract interface class AuthGateway<C extends AuthCredential> {
  Future<Result<AuthSession>> authenticate(C credential);
}

abstract interface class SessionGateway {
  Future<Result<AuthSession>> refresh(String refreshToken);

  Future<Result<void>> revoke(String refreshToken);
}

abstract interface class SessionStore {
  Future<Result<AuthSession?>> read();

  Future<Result<void>> write(AuthSession session);

  Future<Result<void>> clear();
}
