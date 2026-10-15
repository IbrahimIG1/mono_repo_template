import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/auth/email_password_credential.dart';

void main() {
  test('credential diagnostics never expose email or password', () {
    const email = 'secret.person@example.com';
    const password = 'never-log-this-password';
    const credential = EmailPasswordCredential(
      email: email,
      password: password,
    );

    expect(credential.toString(), isNot(contains(email)));
    expect(credential.toString(), isNot(contains(password)));
    expect(credential.toString(), contains('<redacted>'));
  });
}
