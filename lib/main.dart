import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/due_for_review_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/home_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/login_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/problem_list_problem_details_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/problem_list_problems_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/problem_lists_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/profile_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/settings_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/statistics_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/theme.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => UserProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: 'LeetRepeat',
            theme: theme.themeData,
            scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/problem-lists',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final isLogin = state.matchedLocation == '/login';

    if (username == null && !isLogin) return '/login';
    if (username != null && isLogin) return '/problem-lists';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/problem-lists',
          builder: (context, state) => ProblemListsScreen(),
        ),
        GoRoute(
          path: '/problem-lists/:id',
          builder: (context, state) => ProblemListProblemsScreen(
            problemListId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/problem-lists/:listId/problems/:problemId',
          builder: (context, state) => ProblemListProblemDetailsScreen(
            problemListId: int.parse(state.pathParameters['listId']!),
            probleId: int.parse(state.pathParameters['problemId']!),
          ),
        ),
        GoRoute(
          path: '/due-for-review',
          builder: (context, state) => DueForReviewScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    ),
  ],
);
