import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:family_travel_app/features/auth/controller/auth_controller.dart';
import 'package:family_travel_app/features/auth/data/auth_repository.dart';
import 'package:family_travel_app/features/auth/data/auth_failure.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

void main() {
  group('AuthController', () {
    late ProviderContainer container;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late AuthRepository authRepository;

    setUp(() async {
      // Initialize Firebase for tests if not already initialized
      // This is a common workaround for Firebase tests
      try {
        await Firebase.initializeApp();
      } catch (e) {
        // Firebase already initialized
      }

      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      authRepository = AuthRepository(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('signInWithEmailPwd success', () async {
      final mockUser = MockUser();
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => MockUserCredential());
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await container.read(authControllerProvider).signInWithEmailPwd(
        'test@example.com',
        'password123',
      );

      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('signInWithEmailPwd failure - weak-password', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        () => container.read(authControllerProvider).signInWithEmailPwd(
          'test@example.com',
          'weak',
        ),
        throwsA(isA<AuthFailureWeakPassword>()),
      );
    });

    test('signInWithGoogle success', () async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      final mockUser = MockUser();

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.accessToken).thenReturn('mock_access_token');
      when(mockGoogleSignInAuthentication.idToken).thenReturn('mock_id_token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => MockUserCredential());
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await container.read(authControllerProvider).signInWithGoogle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
    });

    test('signInWithGoogle failure - cancelled', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      expect(
        () => container.read(authControllerProvider).signInWithGoogle(),
        throwsA(isA<AuthFailureGoogleSignInCancelled>()),
      );
    });

    test('signOut success', () async {
      await container.read(authControllerProvider).signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });
}


