import 'package:auto_route/auto_route.dart';
import 'package:worder/page/dashboard_page.dart';
import 'package:worder/page/home.dart';
import 'package:worder/page/library_page.dart';
import 'package:worder/page/settings_page.dart';
import 'package:worder/page/splash.dart';

part 'routing.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),
    AutoRoute(
      page: HomeRoute.page,
      path: '/home',
      children: [
        AutoRoute(page: DashboardRoute.page, path: 'dashboard'),
        AutoRoute(page: LibraryRoute.page, path: 'library'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
  ];
}
