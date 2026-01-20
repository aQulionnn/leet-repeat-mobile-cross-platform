import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/home_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/problem_list_problems_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/screens/problem_lists_screen.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/theme.dart';
import 'package:provider/provider.dart';

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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: 'LeetRepeat',
            theme: theme.themeData,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/problem-lists',
  routes: [
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
          path: '/problem-lists/:name',
          builder: (context, state) => ProblemListProblemsScreen(),
        ),
      ],
    ),
  ],
);
