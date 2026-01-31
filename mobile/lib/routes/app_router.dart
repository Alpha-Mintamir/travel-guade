import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/trips/presentation/screens/home_screen.dart';
import '../features/trips/presentation/screens/trip_detail_screen.dart';
import '../features/trips/presentation/screens/my_trips_screen.dart';
import '../features/trips/presentation/screens/create_trip_screen.dart';
import '../features/trips/presentation/screens/edit_trip_screen.dart';
import '../shared/models/trip.dart';
import '../features/chat/presentation/screens/chat_list_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/requests/presentation/screens/requests_screen.dart';
import '../shared/widgets/main_shell.dart';

/// Custom page transition that uses fade through animation
CustomTransitionPage<void> fadeThrough<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}

/// Custom page transition that slides up from bottom (for modals/create screens)
CustomTransitionPage<void> slideUp<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ));
      
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

/// Custom page transition with shared axis (horizontal) for navigation
CustomTransitionPage<void> sharedAxisHorizontal<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

/// Fade transition with Hero support (for trip detail)
CustomTransitionPage<void> fadeWithHero<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      // Auth routes (fade through transition)
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) => fadeThrough(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/register',
        pageBuilder: (context, state) => fadeThrough(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (context, state) => fadeThrough(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/reset-password/:token',
        pageBuilder: (context, state) {
          final token = state.pathParameters['token']!;
          return fadeThrough(
            context: context,
            state: state,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: '/auth/verify-email/:token',
        pageBuilder: (context, state) {
          final token = state.pathParameters['token']!;
          return fadeThrough(
            context: context,
            state: state,
            child: EmailVerificationScreen(token: token),
          );
        },
      ),
      
      // Create trip (slides up from bottom like a modal)
      GoRoute(
        path: '/create-trip',
        pageBuilder: (context, state) => slideUp(
          context: context,
          state: state,
          child: const CreateTripScreen(),
        ),
      ),
      
      // Edit trip (slides up from bottom like a modal)
      GoRoute(
        path: '/edit-trip',
        pageBuilder: (context, state) {
          final trip = state.extra as Trip;
          return slideUp(
            context: context,
            state: state,
            child: EditTripScreen(trip: trip),
          );
        },
      ),
      
      // Edit profile (slides up from bottom like a modal)
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => slideUp(
          context: context,
          state: state,
          child: const EditProfileScreen(),
        ),
      ),
      
      // Notifications (slides from right)
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => sharedAxisHorizontal(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      
      // Trip requests (slides from right)
      GoRoute(
        path: '/requests',
        pageBuilder: (context, state) => sharedAxisHorizontal(
          context: context,
          state: state,
          child: const RequestsScreen(),
        ),
      ),
      
      // Main app with bottom navigation (ShellRoute)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => fadeThrough(
              context: context,
              state: state,
              child: const HomeScreen(),
            ),
            routes: [
              // Trip detail with fade transition to support Hero animation
              GoRoute(
                path: 'trip/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return fadeWithHero(
                    context: context,
                    state: state,
                    child: TripDetailScreen(tripId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my-trips',
            pageBuilder: (context, state) => fadeThrough(
              context: context,
              state: state,
              child: const MyTripsScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => fadeThrough(
              context: context,
              state: state,
              child: const ChatListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':conversationId',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['conversationId']!;
                  return sharedAxisHorizontal(
                    context: context,
                    state: state,
                    child: ChatScreen(conversationId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => fadeThrough(
              context: context,
              state: state,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
