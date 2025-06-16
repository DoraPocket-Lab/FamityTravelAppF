import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:family_travel_app/features/auth/controller/auth_controller.dart';
import 'package:family_travel_app/features/auth/data/auth_failure.dart';

class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);

    Future<void> _signIn() async {
      isLoading.value = true;
      try {
        await ref.read(authControllerProvider).signInWithEmailPwd(
              emailController.text,
              passwordController.text,
            );
      } on AuthFailure catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.runtimeType}')), // TODO: Map AuthFailure to user-friendly messages
        );
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> _signInWithGoogle() async {
      isLoading.value = true;
      try {
        await ref.read(authControllerProvider).signInWithGoogle();
      } on AuthFailure catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Failed: ${e.runtimeType}')), // TODO: Map AuthFailure to user-friendly messages
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')), // TODO: Add app title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // TODO: Navigate to forgot password screen or show dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forgot password functionality not yet implemented.')),
                );
              },
              child: const Text('Forgot password?'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}


