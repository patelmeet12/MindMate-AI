import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/providers.dart';
import '../presentation/screens/profile_setup_screen.dart';
import '../presentation/screens/shell_scaffold.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/journal_screen.dart';
import '../presentation/screens/mindfulness_screen.dart';
import '../presentation/screens/chat_screen.dart';
import '../presentation/screens/insights_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final profileState = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final hasProfile = profileState != null && profileState.name.trim().isNotEmpty;
      final isSettingUp = state.matchedLocation == '/profile-setup';

      if (!hasProfile && !isSettingUp) {
        return '/profile-setup';
      }
      if (hasProfile && isSettingUp) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => const JournalScreen(),
          ),
          GoRoute(
            path: '/mindfulness',
            builder: (context, state) => const MindfulnessScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
        ],
      ),
    ],
  );
});
