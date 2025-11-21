import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moinc/config/theme.dart';
import 'dart:io' show Platform;

import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white30)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(color: AppTheme.lightTextColor, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.white30)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (Platform.isAndroid) Expanded(child: _GoogleSignInButton()),

            if (!kIsWeb && Platform.isIOS) ...[
              const SizedBox(width: 16),
              // Expanded(child: _AppleSignInButton()),
              Expanded(child: _GoogleSignInButton()),
            ],
          ],
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.read<AuthBloc>().add(const SignInWithGoogleRequested());
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 11),
        side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/social-google.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.g_mobiledata,
                size: 24,
                color: Colors.red,
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Sign in with Google',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.read<AuthBloc>().add(const SignInWithAppleRequested());
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/social-apple.png',
            height: 24,
            width: 24,
            color: Colors.white,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.apple, size: 24, color: Colors.white);
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Sign up with Apple',
            style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
