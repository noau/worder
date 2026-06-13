import 'package:auto_route/auto_route.dart';
import 'package:worder/page/home.dart';
import 'package:worder/page/splash.dart';

part 'routing.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: "/splash", initial: true),
    CustomRoute(
      page: HomeRoute.page,
      path: "/home",
    ),
  ];
}
