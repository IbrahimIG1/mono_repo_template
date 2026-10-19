import 'package:auth_core/auth_core.dart';
import 'package:flutter/widgets.dart';
import 'package:platform_foundation/platform_foundation.dart';

final class ShowcaseEmailPasswordCredential implements AuthCredential {
  const ShowcaseEmailPasswordCredential({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  String toString() => 'ShowcaseEmailPasswordCredential(<redacted>)';
}

final class ShowcaseAuthComposition {
  ShowcaseAuthComposition._(this.sessionManager, this.signIn, this.signOut);

  factory ShowcaseAuthComposition.create({
    AppLogger logger = const NullLogger(),
  }) {
    final store = _MemorySessionStore();
    final gateway = _ShowcaseAuthGateway();
    final sessionManager = SessionManager(
      store: store,
      gateway: gateway,
      logger: logger,
    );
    return ShowcaseAuthComposition._(
      sessionManager,
      BoundSignIn<ShowcaseEmailPasswordCredential>(
        gateway: gateway,
        sessionManager: sessionManager,
      ),
      SessionSignOut(sessionManager),
    );
  }

  final SessionManager sessionManager;
  final SignIn<ShowcaseEmailPasswordCredential> signIn;
  final SignOut signOut;

  Future<Result<void>> restore() => sessionManager.restore();

  Future<void> dispose() => sessionManager.dispose();
}

final class ShowcaseAuthScope extends InheritedWidget {
  const ShowcaseAuthScope({
    required this.auth,
    required super.child,
    super.key,
  });

  final ShowcaseAuthComposition auth;

  static ShowcaseAuthComposition of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShowcaseAuthScope>()!.auth;

  @override
  bool updateShouldNotify(ShowcaseAuthScope oldWidget) =>
      !identical(auth, oldWidget.auth);
}

final class SessionSignOut implements SignOut {
  const SessionSignOut(this._manager);

  final SessionManager _manager;

  @override
  Future<void> call() => _manager.signOut();
}

final class _ShowcaseAuthGateway
    implements AuthGateway<ShowcaseEmailPasswordCredential>, SessionGateway {
  @override
  Future<Result<AuthSession>> authenticate(
    ShowcaseEmailPasswordCredential credential,
  ) async => Success(_sessionFor(credential.email));

  @override
  Future<Result<AuthSession>> refresh(String refreshToken) async =>
      Success(_sessionFor('restored@example.com'));

  @override
  Future<Result<void>> revoke(String refreshToken) async => const Success(null);

  AuthSession _sessionFor(String subject) => AuthSession(
    accessToken: 'showcase-access-$subject',
    refreshToken: 'showcase-refresh-$subject',
    subjectId: subject,
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
  );
}

final class _MemorySessionStore implements SessionStore {
  AuthSession? _session;

  @override
  Future<Result<AuthSession?>> read() async => Success(_session);

  @override
  Future<Result<void>> write(AuthSession session) async {
    _session = session;
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    _session = null;
    return const Success(null);
  }
}
