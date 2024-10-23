import 'package:flutter/material.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../../util/storage.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key, required this.onDone}) : super(key: key);

  final Function(bool hasSession) onDone;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    handleSplash();
    super.initState();
  }

  Future handleSplash() async {
    try {
      TokenProvider tokenProvider = locate<TokenProvider>();
      if (tokenProvider.service is StandardAuthService) {
        Storage storage = Storage();
        String? email = await storage.readValue("email");
        (tokenProvider.service as StandardAuthService).credentials =
            StdLoginCredentials(userName: email ?? "", password: "");
      }

      await locate<TokenProvider>().getToken('');
      final bool hasSession = locate<TokenProvider>().hasSession;
      widget.onDone(hasSession);
    } catch (error) {
      widget.onDone(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
