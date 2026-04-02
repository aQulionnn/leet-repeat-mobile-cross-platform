import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

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
                    NavigationRailDestination(
                      icon: Icon(Icons.today),
                      label: Text('Due for review'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      label: Text('Profile'),
                    ),
                  ],
                  selectedIndex: _selectedIndex(location),
                  onDestinationSelected: (value) {
                    if (value == 0) {
                      context.push('/problem-lists');
                    } else if (value == 1) {
                      context.push('/due-for-review');
                    } else if (value == 2) {
                      context.push('/settings');
                    } else if (value == 3) {
                      context.push('/profile');
                    }
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

int _selectedIndex(String location) {
  if (location.startsWith('/problem-lists')) return 0;
  if (location.startsWith('/due-for-review')) return 1;
  if (location.startsWith('/settings')) return 2;
  if (location.startsWith('/profile')) return 3;
  return 0;
}
