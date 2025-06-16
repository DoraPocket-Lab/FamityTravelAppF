import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:family_travel_app/features/auth/presentation/auth_screen.dart';
import 'package:family_travel_app/features/auth/presentation/profile_setup_screen.dart';
import 'package:family_travel_app/features/auth/presentation/verify_email_screen.dart';
import 'package:family_travel_app/features/auth/controller/auth_controller.dart';
import 'package:family_travel_app/home_shell.dart';
import 'package:family_travel_app/features/plan/presentation/plan_board_screen.dart';
import 'package:family_travel_app/features/expense/presentation/expense_tab_screen.dart';
import 'package:family_travel_app/features/memory/presentation/memory_gallery_screen.dart';
import 'package:family_travel_app/features/memory/presentation/memory_viewer.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          // TODO: Implement deep link parsing for invite=fid
          final inviteId = state.uri.queryParameters['id'];
          if (authState.value == null) {
            return const AuthScreen();
          } else if (authState.value != null && !authState.value!.emailVerified) {
            return const VerifyEmailScreen();
          } else {
            return const HomeShell();
          }
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/plan/:planId',
        builder: (context, state) => PlanBoardScreen(planId: state.pathParameters['planId']!),
        routes: [
          GoRoute(
            path: 'expense',
            builder: (context, state) => ExpenseTabScreen(planId: state.pathParameters['planId']!),
          ),
          GoRoute(
            path: 'memory',
            builder: (context, state) => MemoryGalleryScreen(planId: state.pathParameters['planId']!),
            routes: [
              GoRoute(
                path: ':memoryId',
                builder: (context, state) => MemoryViewer(
                  planId: state.pathParameters['planId']!,
                  memoryId: state.pathParameters['memoryId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      // TODO: Add routes for Home, Profile
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isEmailVerified = authState.value?.emailVerified ?? false;
      final isProfileSetup = true; // TODO: Implement logic to check if profile is set up

      final goingToAuth = state.matchedLocation == '/auth';
      final goingToProfileSetup = state.matchedLocation == '/profile-setup';
      final goingToVerifyEmail = state.matchedLocation == '/verify-email';

      if (!isAuthenticated) {
        return goingToAuth ? null : '/auth';
      } else if (!isEmailVerified && !goingToVerifyEmail) {
        return '/verify-email';
      } else if (!isProfileSetup && !goingToProfileSetup) {
        return '/profile-setup';
      }

      if (goingToAuth || goingToVerifyEmail || goingToProfileSetup) {
        return '/';
      }

      return null;
    },
  );
});


