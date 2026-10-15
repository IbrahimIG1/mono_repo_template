import 'package:platform_foundation/platform_foundation.dart';

import '../auth_gateway.dart';
import '../auth_session.dart';

typedef AuthenticateHandler<C extends AuthCredential> =
    Future<Result<AuthSession>> Function(C credential);
typedef RefreshHandler =
    Future<Result<AuthSession>> Function(String refreshToken);
typedef RevokeHandler = Future<Result<void>> Function(String refreshToken);

final class FakeAuthGateway<C extends AuthCredential>
    implements AuthGateway<C> {
  FakeAuthGateway(this._handler);

  final AuthenticateHandler<C> _handler;
  var callCount = 0;

  @override
  Future<Result<AuthSession>> authenticate(C credential) {
    callCount++;
    return _handler(credential);
  }
}

final class FakeSessionGateway implements SessionGateway {
  FakeSessionGateway({required this.refreshHandler, RevokeHandler? revoke})
    : revokeHandler = revoke ?? ((_) async => const Success(null));

  final RefreshHandler refreshHandler;
  final RevokeHandler revokeHandler;
  var refreshCallCount = 0;
  var revokeCallCount = 0;

  @override
  Future<Result<AuthSession>> refresh(String refreshToken) {
    refreshCallCount++;
    return refreshHandler(refreshToken);
  }

  @override
  Future<Result<void>> revoke(String refreshToken) {
    revokeCallCount++;
    return revokeHandler(refreshToken);
  }
}

final class MemorySessionStore implements SessionStore {
  MemorySessionStore({AuthSession? initialSession}) : session = initialSession;

  AuthSession? session;
  var readCount = 0;
  var writeCount = 0;
  var clearCount = 0;

  @override
  Future<Result<void>> clear() async {
    clearCount++;
    session = null;
    return const Success(null);
  }

  @override
  Future<Result<AuthSession?>> read() async {
    readCount++;
    return Success(session);
  }

  @override
  Future<Result<void>> write(AuthSession session) async {
    writeCount++;
    this.session = session;
    return const Success(null);
  }
}
