import 'package:go_router/go_router.dart';

import '../feature/sleep_monitor/persentation/screens/home_screen.dart';
import '../feature/sleep_monitor/persentation/screens/permission_screen.dart';
import '../feature/sleep_monitor/persentation/screens/settings_screen.dart';
import '../feature/sleep_monitor/persentation/screens/sleep_summary_screen.dart';
import '../feature/sleep_monitor/persentation/screens/sleep_tracking_screen.dart';
import '../feature/sleep_monitor/persentation/screens/splash_screen.dart';



class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, _) => const SplashScreen()),
      GoRoute(path: '/home', builder: (context, _) => const HomeScreen()),
      GoRoute(path: '/permissions', builder: (context, _) => const PermissionScreen()),
      GoRoute(path: '/tracking', builder: (context, _) => const SleepTrackingScreen()),
      GoRoute(path: '/summary', builder: (context, _) => const SleepSummaryScreen()),
      GoRoute(path: '/settings', builder: (context, _) => const SettingsScreen()),
    ],
  );
}
