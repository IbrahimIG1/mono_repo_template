import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:auth_ui/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/email_password_credential.dart';

final class SignInScreen extends StatefulWidget {
  const SignInScreen({
    required this.signIn,
    required this.intendedDestination,
    super.key,
  });

  final SignIn<EmailPasswordCredential> signIn;
  final String? intendedDestination;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

final class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final SignInCubit<EmailPasswordCredential> _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SignInCubit(widget.signIn);
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.intendedDestination != null)
                    Text('Continue to ${widget.intendedDestination}'),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: AuthValidators.password,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<
                    SignInCubit<EmailPasswordCredential>,
                    SignInState
                  >(
                    builder: (context, state) => Column(
                      children: [
                        if (state case SignInFailed(:final failure))
                          Text(
                            failure.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        AuthSubmitButton(
                          label: 'Sign in',
                          isSubmitting: state is SignInSubmitting,
                          onPressed: () => unawaited(_submit()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await _cubit.submit(
      EmailPasswordCredential(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}
