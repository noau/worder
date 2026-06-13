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
      floatingActionButtonBuilder: (context, tabsRouter) =>
          !tabsRouter.currentPath.endsWith("settings")
          ? FloatingActionButton(
              onPressed: () => context.pushRoute(AddWordRoute()),
              tooltip: "New Word",
              child: Icon(Icons.add),
            )
          : null,
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
