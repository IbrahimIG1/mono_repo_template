import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:auth_ui/auth_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_foundation/platform_foundation.dart';

void main() {
  test('Cubit depends on typed SignIn and publishes success', () async {
    final signIn = _FakeSignIn((_) async => Success(_session));
    final cubit = SignInCubit<_Credential>(signIn);
    final states = <SignInState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.submit(const _Credential('person@example.com'));
    await Future<void>.delayed(Duration.zero);

    expect(signIn.callCount, 1);
    expect(states[0], isA<SignInSubmitting>());
    expect((states[1] as SignInSucceeded).session, _session);
    await subscription.cancel();
    await cubit.close();
  });

  test('Cubit ignores completion after close', () async {
    final completer = Completer<Result<AuthSession>>();
    final cubit = SignInCubit<_Credential>(
      _FakeSignIn((_) => completer.future),
    );

    final submission = cubit.submit(const _Credential('person@example.com'));
    await cubit.close();
    completer.complete(Success(_session));
    await submission;

    expect(cubit.state, isA<SignInSubmitting>());
  });

  test(
    'Cubit publishes typed failure and blocks duplicate submission',
    () async {
      final completer = Completer<Result<AuthSession>>();
      final signIn = _FakeSignIn((_) => completer.future);
      final cubit = SignInCubit<_Credential>(signIn);

      final first = cubit.submit(const _Credential('person@example.com'));
      await cubit.submit(const _Credential('duplicate@example.com'));
      completer.complete(
        const Failure(
          AuthFailure(
            kind: AuthFailureKind.invalidCredentials,
            code: 'auth.invalid_credentials',
            message: 'Invalid credentials.',
          ),
        ),
      );
      await first;

      expect(signIn.callCount, 1);
      expect(
        (cubit.state as SignInFailed).failure.code,
        'auth.invalid_credentials',
      );
      await cubit.close();
    },
  );

  test('validators reject malformed values', () {
    expect(AuthValidators.email('missing-at'), isNotNull);
    expect(AuthValidators.email('person@example.com'), isNull);
    expect(AuthValidators.password('short'), isNotNull);
    expect(AuthValidators.password('long-enough'), isNull);
  });
}

final class _Credential implements AuthCredential {
  const _Credential(this.email);

  final String email;
}

final class _FakeSignIn implements SignIn<_Credential> {
  _FakeSignIn(this._handler);

  final Future<Result<AuthSession>> Function(_Credential) _handler;
  var callCount = 0;

  @override
  Future<Result<AuthSession>> call(_Credential credential) {
    callCount++;
    return _handler(credential);
  }
}

final _session = AuthSession(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  subjectId: 'user-1',
  expiresAt: DateTime.utc(2026, 10, 15, 13),
);
