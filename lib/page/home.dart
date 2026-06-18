import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import '../util/context_l10n.dart';

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
              tooltip: context.l10n.navNewWordTooltip,
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: context.l10n.navDashboard,
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: context.l10n.navLibrary,
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: context.l10n.navSettings,
            ),
          ],
        );
      },
    );
  }
}
