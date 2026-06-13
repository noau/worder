import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../routing.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [DashboardRoute(), LibraryRoute(), SettingsRoute()],
      appBarBuilder: (_, tabsRouter) => AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Worder'),
      ),
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}
