import 'package:auth_core/auth_core.dart';
import 'package:flutter/widgets.dart';

import 'app_composition.dart';
import 'auth/email_password_credential.dart';

final class AppScope extends InheritedWidget {
  const AppScope({required this.composition, required super.child, super.key});

  final AppComposition composition;

  static AppComposition of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this route.');
    return scope!.composition;
  }

  SignIn<EmailPasswordCredential> get signIn => composition.signIn;
  SignOut get signOut => composition.signOut;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      !identical(composition, oldWidget.composition);
}
