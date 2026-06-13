import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:worder/routing.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      childWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Text("Worder", style: Theme.of(context).textTheme.displayLarge),
          SizedBox(height: 48),
        ],
      ),
      useImmersiveMode: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      asyncNavigationCallback: () async {
        // Initializations
        await Future.delayed(const Duration(seconds: 3));
      },
      onEnd: () async {
        context.router.replace(const HomeRoute());
      },
    );
  }
}
