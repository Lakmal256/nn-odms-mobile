import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:odms/app_config.dart';
import 'router.dart';
import 'ui/ui.dart';
import 'locator.dart';
import 'l10n.dart';

Future<Widget> initializeApp(AppConfig appConfig) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator(appConfig);
  HttpOverrides.global = MyHttpOverrides();
  return (App(appConfig));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class App extends StatefulWidget {
  final AppConfig appConfig;
  const App(this.appConfig, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: event.notification?.title ?? "",
          subtitle: event.notification?.body ?? "",
          color: Colors.black,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) => AnimatedBuilder(
        animation: listenable,
        child: child,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            if (child != null) child,

            /// Overlay elements
            if (locate<LoadingIndicatorController>().value) const LoadingIndicatorPopup(),
            ConnectivityIndicator(),
            Align(
              alignment: Alignment.topLeft,
              child: PopupContainer(
                children: locate<PopupController>().value,
              ),
            )
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locate<AppLocaleNotifier>().value,
      theme: AppTheme.light,
      routerConfig: baseRouter,
    );
  }

  Listenable get listenable => Listenable.merge([
        locate<AppLocaleNotifier>(),
        locate<PopupController>(),
        locate<LoadingIndicatorController>(),
      ]);
}
