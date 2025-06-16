
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:family_travel_app/features/auth/data/auth_failure.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailPwd(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthExceptionToAuthFailure(e);
    } catch (e) {
      throw AuthFailureUnknown(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailureGoogleSignInCancelled();
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthExceptionToAuthFailure(e);
    } catch (e) {
      throw AuthFailureUnknown(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthExceptionToAuthFailure(e);
    } catch (e) {
      throw AuthFailureUnknown(e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthExceptionToAuthFailure(e);
    } catch (e) {
      throw AuthFailureUnknown(e.toString());
    }
  }

  AuthFailure _mapFirebaseAuthExceptionToAuthFailure(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthFailureEmailAlreadyInUse();
      case 'weak-password':
        return const AuthFailureWeakPassword();
      case 'user-not-found':
        return const AuthFailureUserNotFound();
      case 'wrong-password':
        return const AuthFailureWrongPassword();
      case 'invalid-email':
        return const AuthFailureInvalidEmail();
      case 'operation-not-allowed':
        return const AuthFailureOperationNotAllowed();
      case 'user-disabled':
        return const AuthFailureUserDisabled();
      case 'too-many-requests':
        return const AuthFailureTooManyRequests();
      default:
        return AuthFailureUnknown(e.message ?? 'An unknown error occurred.');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());


