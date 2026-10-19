import 'dart:async';

import 'package:auth_ui/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'showcase_auth.dart';

final class ShowcaseSignInScreen extends StatefulWidget {
  const ShowcaseSignInScreen({required this.onSignedIn, super.key});

  final VoidCallback onSignedIn;

  @override
  State<ShowcaseSignInScreen> createState() => _ShowcaseSignInScreenState();
}

final class _ShowcaseSignInScreenState extends State<ShowcaseSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final SignInCubit<ShowcaseEmailPasswordCredential> _cubit;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted || _cubitInitialized) {
      return;
    }
    _cubitInitialized = true;
    _cubit = SignInCubit(ShowcaseAuthScope.of(context).signIn);
  }

  var _cubitInitialized = false;

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
                    SignInCubit<ShowcaseEmailPasswordCredential>,
                    SignInState
                  >(
                    builder: (context, state) => AuthSubmitButton(
                      label: 'Sign in',
                      isSubmitting: state is SignInSubmitting,
                      onPressed: () => unawaited(_submit()),
                    ),
                  ),
                  BlocListener<
                    SignInCubit<ShowcaseEmailPasswordCredential>,
                    SignInState
                  >(
                    listener: (context, state) {
                      if (state is SignInSucceeded) {
                        widget.onSignedIn();
                      }
                    },
                    child: const SizedBox.shrink(),
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
      ShowcaseEmailPasswordCredential(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}

final class ShowcaseAccountScreen extends StatelessWidget {
  const ShowcaseAccountScreen({required this.onSignOut, super.key});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Account')),
    body: Center(
      child: FilledButton(onPressed: onSignOut, child: const Text('Sign out')),
    ),
  );
}
