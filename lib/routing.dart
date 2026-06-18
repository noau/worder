import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/page/add_word.dart';
import 'package:worder/page/dashboard_page.dart';
import 'package:worder/page/home.dart';
import 'package:worder/page/learn_review_finish_page.dart';
import 'package:worder/page/learn_review_page.dart';
import 'package:worder/page/library_page.dart';
import 'package:worder/page/settings_page.dart';
import 'package:worder/page/splash.dart';
import 'package:worder/page/word_detail_page.dart';

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
    AutoRoute(page: AddWordRoute.page, path: '/add-word'),
    AutoRoute(page: LearnReviewRoute.page, path: '/learn-review'),
    AutoRoute(page: LearnReviewFinishRoute.page, path: '/learn-review/finish'),
    AutoRoute(page: WordDetailRoute.page, path: '/word-detail'),
  ];
}
