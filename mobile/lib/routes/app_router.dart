import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/trips/presentation/screens/home_screen.dart';
import '../features/trips/presentation/screens/trip_detail_screen.dart';
import '../features/trips/presentation/screens/my_trips_screen.dart';
import '../features/trips/presentation/screens/create_trip_screen.dart';
import '../features/chat/presentation/screens/chat_list_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../shared/widgets/main_shell.dart';

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
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Create trip (full screen, no bottom nav)
      GoRoute(
        path: '/create-trip',
        builder: (context, state) => const CreateTripScreen(),
      ),
      
      // Main app with bottom navigation (ShellRoute)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'trip/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TripDetailScreen(tripId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my-trips',
            builder: (context, state) => const MyTripsScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                builder: (context, state) {
                  final id = state.pathParameters['conversationId']!;
                  return ChatScreen(conversationId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
