import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/workout/presentation/pages/workout_page.dart';
import '../../features/workout/presentation/pages/workout_active_page.dart';
import '../../features/workout/presentation/pages/workout_history_page.dart';
import '../../features/workout/presentation/pages/workout_detail_page.dart';
import '../../features/health/presentation/pages/health_dashboard_page.dart';
import '../../features/health/presentation/pages/add_health_metric_page.dart';
import '../../features/blog/presentation/pages/blog_page.dart';
import '../../features/blog/presentation/pages/article_detail_page.dart';
import '../../features/challenges/presentation/pages/challenges_page.dart';
import '../../features/challenges/presentation/pages/challenge_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../shared/providers/auth_provider.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String workout = '/workout';
  static const String workoutActive = '/workout/active';
  static const String workoutHistory = '/workout/history';
  static const String workoutDetail = '/workout/detail';
  static const String health = '/health';
  static const String addHealthMetric = '/health/add';
  static const String blog = '/blog';
  static const String articleDetail = '/blog/article';
  static const String challenges = '/challenges';
  static const String challengeDetail = '/challenges/detail';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: _redirect,
    routes: [
      // Auth Routes
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: home, builder: (context, state) => const HomePage()),
          GoRoute(
            path: workout,
            builder: (context, state) => const WorkoutPage(),
            routes: [
              GoRoute(
                path: 'active',
                builder: (context, state) => const WorkoutActivePage(),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const WorkoutHistoryPage(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) => WorkoutDetailPage(
                  sessionId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: health,
            builder: (context, state) => const HealthDashboardPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => AddHealthMetricPage(
                  metricType: state.uri.queryParameters['type'] ?? 'weight',
                ),
              ),
            ],
          ),
          GoRoute(
            path: blog,
            builder: (context, state) => const BlogPage(),
            routes: [
              GoRoute(
                path: 'article/:id',
                builder: (context, state) => ArticleDetailPage(
                  articleId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: challenges,
            builder: (context, state) => const ChallengesPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) => ChallengeDetailPage(
                  challengeId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final isAuthRoute =
        state.matchedLocation == login || state.matchedLocation == register;

    if (!isLoggedIn && !isAuthRoute) {
      return login;
    }

    if (isLoggedIn && isAuthRoute) {
      return home;
    }

    return null;
  }
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.directions_bike),
      label: 'Workout',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
    BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blog'),
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_events),
      label: 'Challenges',
    ),
  ];

  final List<String> _routes = [
    AppRouter.home,
    AppRouter.workout,
    AppRouter.health,
    AppRouter.blog,
    AppRouter.challenges,
  ];

  @override
  Widget build(BuildContext context) {
    // Update current index based on route
    final currentRoute = GoRouterState.of(context).matchedLocation;
    _updateCurrentIndex(currentRoute);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems,
        onTap: (index) {
          // Always navigate, even if same index to ensure proper navigation
          context.go(_routes[index]);
        },
      ),
    );
  }

  void _updateCurrentIndex(String route) {
    int newIndex = 0; // Default to home

    // Handle exact home route match
    if (route == '/') {
      newIndex = 0;
    } else {
      // Check other routes (skip home route to avoid conflicts)
      for (int i = 1; i < _routes.length; i++) {
        if (route.startsWith(_routes[i])) {
          newIndex = i;
          break;
        }
      }
    }

    if (_currentIndex != newIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }
}
