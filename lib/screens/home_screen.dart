import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.list),
                      label: Text('Problem Lists'),
                    ),
                  ],
                  selectedIndex: 0,
                  onDestinationSelected: (value) {
                    if (value == 0) context.go('/problem-lists');
                  },
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
                        child: IconButton(
                          onPressed: () {
                            context.read<ThemeProvider>().toggleTheme(); 
                          },
                          icon: Icon(Icons.brightness_6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
