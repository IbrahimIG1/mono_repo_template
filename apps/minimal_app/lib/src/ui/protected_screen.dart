import 'dart:async';

import 'package:auth_core/auth_core.dart';
import 'package:flutter/material.dart';

final class ProtectedScreen extends StatelessWidget {
  const ProtectedScreen({
    required this.itemId,
    required this.tab,
    required this.signOut,
    super.key,
  });

  final String itemId;
  final String? tab;
  final SignOut signOut;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Protected destination')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Protected item: $itemId'),
          Text('Selected tab: ${tab ?? 'none'}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => unawaited(signOut()),
            child: const Text('Sign out'),
          ),
        ],
      ),
    ),
  );
}
