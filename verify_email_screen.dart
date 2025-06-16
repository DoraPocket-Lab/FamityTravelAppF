import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:family_travel_app/features/auth/controller/auth_controller.dart';

class VerifyEmailScreen extends HookConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    Future<void> _sendVerificationEmail() async {
      isLoading.value = true;
      try {
        await ref.read(authControllerProvider).sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')), // TODO: Add proper message
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send verification email: $e')), // TODO: Add proper message
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')), // TODO: Add app title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification link has been sent to your email address. Please verify your email to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 24.0),
            isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendVerificationEmail,
                    child: const Text('Resend Verification Email'),
                  ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // TODO: Allow user to go back to sign in or check status
                context.go('/');
              },
              child: const Text('I have verified my email'),
            ),
          ],
        ),
      ),
    );
  }
}


