import 'package:auth_core/auth_core.dart';

final class EmailPasswordCredential implements AuthCredential {
  const EmailPasswordCredential({required this.email, required this.password});

  final String email;
  final String password;
}
