import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_recipe/providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("AuthPage"),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await authNotifier.signInWithGoogle();
          },
          icon: Icon(Icons.login),
          label: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
