
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:family_travel_app/features/auth/data/auth_repository.dart';
import 'package:family_travel_app/features/auth/data/auth_failure.dart';
import 'package:family_travel_app/core/logger.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  Future<void> signInWithEmailPwd(String email, String password) async {
    try {
      await _ref.read(authRepositoryProvider).signInWithEmailPwd(email, password);
      FirebaseAnalytics.instance.logLogin(loginMethod: 'email_password');
    } on AuthFailure catch (e, st) {
      AppLogger.error('Sign in with email/password failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Sign in with email/password failed');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _ref.read(authRepositoryProvider).signInWithGoogle();
      FirebaseAnalytics.instance.logLogin(loginMethod: 'google');
    } on AuthFailure catch (e, st) {
      AppLogger.error('Sign in with Google failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Sign in with Google failed');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _ref.read(authRepositoryProvider).signOut();
    } catch (e, st) {
      AppLogger.error('Sign out failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Sign out failed');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    } on AuthFailure catch (e, st) {
      AppLogger.error('Send password reset failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Send password reset failed');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _ref.read(authRepositoryProvider).sendEmailVerification();
    } on AuthFailure catch (e, st) {
      AppLogger.error('Send email verification failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Send email verification failed');
      rethrow;
    }
  }

  Future<void> signUpWithEmailPwd(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseAnalytics.instance.logSignUp(signUpMethod: 'email_password');
    } on FirebaseAuthException catch (e, st) {
      AppLogger.error('Sign up with email/password failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Sign up with email/password failed');
      throw _ref.read(authRepositoryProvider)._mapFirebaseAuthExceptionToAuthFailure(e);
    } catch (e, st) {
      AppLogger.error('Sign up with email/password failed', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Sign up with email/password failed');
      rethrow;
    }
  }
}


