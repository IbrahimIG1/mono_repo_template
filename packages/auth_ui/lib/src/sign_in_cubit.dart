import 'package:auth_core/auth_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:platform_foundation/platform_foundation.dart';

sealed class SignInState {
  const SignInState();
}

final class SignInIdle extends SignInState {
  const SignInIdle();
}

final class SignInSubmitting extends SignInState {
  const SignInSubmitting();
}

final class SignInSucceeded extends SignInState {
  const SignInSucceeded(this.session);

  final AuthSession session;
}

final class SignInFailed extends SignInState {
  const SignInFailed(this.failure);

  final AppFailure failure;
}

final class SignInCubit<C extends AuthCredential> extends Cubit<SignInState> {
  SignInCubit(this.signIn) : super(const SignInIdle());

  final SignIn<C> signIn;
  var _submission = 0;

  Future<void> submit(C credential) async {
    if (state is SignInSubmitting) {
      return;
    }
    final submission = ++_submission;
    emit(const SignInSubmitting());
    final result = await signIn(credential);
    if (isClosed || submission != _submission) {
      return;
    }
    emit(switch (result) {
      Success<AuthSession>(:final value) => SignInSucceeded(value),
      Failure<AuthSession>(:final failure) => SignInFailed(failure),
    });
  }

  @override
  Future<void> close() {
    _submission++;
    return super.close();
  }
}
