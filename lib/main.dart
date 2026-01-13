import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
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
          return MaterialApp(
            title: 'LeetRepeat',
            theme: theme.themeData,
            home: Scaffold(body: Center(child: Text('LeetRepeat'))),
          );
        },
      ),
    );
  }
}