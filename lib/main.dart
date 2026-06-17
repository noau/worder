import 'dart:io';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worder/database.dart';
import 'package:worder/repository.dart';
import 'package:worder/routing.dart';
import 'package:worder/service/ai_service.dart';
import 'package:worder/theme.dart';

import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(400, 800),
      minimumSize: Size(400, 600),
      title: "What If?",
      center: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final preferencesRepository = PreferencesRepository();
  final schedulerRepository = SchedulerRepository();
  final appDatabase = AppDatabase();
  final aiService = AIService(preferencesRepository);
  runApp(
    WorderApp(
      savedThemeMode: savedThemeMode,
      preferencesRepository: preferencesRepository,
      schedulerRepository: schedulerRepository,
      appDatabase: appDatabase,
      aiService: aiService,
    ),
  );
}

class WorderApp extends StatelessWidget {
  WorderApp({
    super.key,
    required this.savedThemeMode,
    required this.preferencesRepository,
    required this.schedulerRepository,
    required this.appDatabase,
    required this.aiService,
  });

  final AdaptiveThemeMode? savedThemeMode;
  final PreferencesRepository preferencesRepository;
  final SchedulerRepository schedulerRepository;
  final AppDatabase appDatabase;
  final AIService aiService;
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final theme = WorderTheme(TextTheme());
    final botToastBuilder = BotToastInit();

    return MultiProvider(
      providers: [
        Provider.value(value: preferencesRepository),
        Provider.value(value: schedulerRepository),
        Provider.value(value: appDatabase),
        Provider.value(value: aiService),
      ],
      child: AdaptiveTheme(
        initial: savedThemeMode ?? AdaptiveThemeMode.system,
        light: theme.light(),
        dark: theme.dark(),
        builder: (lightTheme, darkTheme) => MaterialApp.router(
          debugShowCheckedModeBanner: !(kDebugMode && disableDebugLabel),
          title: 'Worder',
          theme: lightTheme,
          darkTheme: darkTheme,
          scrollBehavior: BothScrollBehavior(),
          routerConfig: appRouter.config(
            navigatorObservers: () => [BotToastNavigatorObserver()],
          ),
          builder: (context, child) {
            child = ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(
                  start: 801,
                  end: double.infinity,
                  name: DESKTOP,
                ),
              ],
            );
            child = botToastBuilder(context, child);
            return child;
          },
        ),
      ),
    );
  }
}

class BothScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
