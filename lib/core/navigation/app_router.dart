import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/vault/vault_screen.dart';
import '../../features/threats/threats_screen.dart';
import '../../features/contagion/contagion_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/landing/landing_screen.dart';
import 'app_shell.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  set isAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Use a ChangeNotifier to let GoRouter react to auth state transitions
  static final AuthNotifier authNotifier = AuthNotifier();

  static bool get isAuthenticated => authNotifier.isAuthenticated;
  static set isAuthenticated(bool value) =>
      authNotifier.isAuthenticated = value;

  static String currentAdminName = "Admin User";
  static String currentOrganizationId = "ORG-ID N/A";

  static void initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      // Keep router auth state fully synchronized with Firebase.
      isAuthenticated = user != null;
    });
  }

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final firebaseAuthenticated = FirebaseAuth.instance.currentUser != null;
      final authenticated = isAuthenticated || firebaseAuthenticated;
      if (isAuthenticated != authenticated) {
        isAuthenticated = authenticated;
      }

      final path = state.uri.path;
      final isPublic = path == '/' || path == '/login';
      if (!authenticated && !isPublic) return '/login';
      if (authenticated && path == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LandingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          GoRoute(
            path: '/vault',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const VaultScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          GoRoute(
            path: '/threats',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ThreatsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          GoRoute(
            path: '/contagion',
            pageBuilder: (context, state) {
              final selectedThreatId = state.uri.queryParameters['threatId'];
              return CustomTransitionPage(
                key: state.pageKey,
                child:
                    PropagationFlowScreen(selectedThreatId: selectedThreatId),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              );
            },
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
        ],
      ),
    ],
  );
}
