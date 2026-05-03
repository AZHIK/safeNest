import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_state.dart';

import '../../features/auth/presentation/screens/phone_entry_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/permission_request_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/home/home_screen.dart';
import '../../features/sos/sos_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/reporting/reporting_screen.dart';
import '../../features/training/training_screen.dart';
import '../../features/training/lesson_list_screen.dart';
import '../../features/training/lesson_detail_screen.dart';
import '../../features/messaging/chat_list_screen.dart';
import '../../features/messaging/chat_detail_screen.dart';
import '../../features/contacts/contacts_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shared/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: _RouterRefreshListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth =
          authState.status == AuthStatus.authenticated ||
          authState.status == AuthStatus.anonymous;

      final isLoggingIn =
          state.matchedLocation == '/phone-entry' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/profile-setup' ||
          state.matchedLocation == '/permissions';

      if (!isAuth && !isLoggingIn) {
        return '/phone-entry';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/phone-entry',
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(path: '/otp', builder: (context, state) => const OTPScreen()),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionRequestScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/report',
                builder: (context, state) => const ReportingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const ChatListScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) => const ChatDetailScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/training',
                builder: (context, state) => const TrainingScreen(),
                routes: [
                  GoRoute(
                    path: 'lessons',
                    builder: (context, state) {
                      final categoryId =
                          state.uri.queryParameters['categoryId'];
                      return LessonListScreen(categoryId: categoryId);
                    },
                  ),
                  GoRoute(
                    path: 'lesson-detail',
                    builder: (context, state) {
                      final lessonId = state.uri.queryParameters['id'];
                      return LessonDetailScreen(lessonId: lessonId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/sos', builder: (context, state) => const SosScreen()),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const TrustedContactsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    _subscription = ref.listen(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
