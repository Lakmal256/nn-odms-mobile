library flutter_recaptcha_v2_compat_compat;

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaV2 extends StatefulWidget {
  final String apiKey;
  final String apiSecret;
  final String pluginURL = "https://recaptcha-flutter-plugin.firebaseapp.com/";
  final RecaptchaV2Controller controller;

  final ValueChanged<bool>? onVerifiedSuccessfully;
  final ValueChanged<String>? onVerifiedError;

  final EdgeInsetsGeometry? padding;

  const RecaptchaV2({Key? key,
    required this.apiKey,
    required this.apiSecret,
    required this.controller,
    this.onVerifiedSuccessfully,
    this.onVerifiedError,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecaptchaV2State();
}

class _RecaptchaV2State extends State<RecaptchaV2> with TickerProviderStateMixin {
  late RecaptchaV2Controller controller;
  late WebViewController webViewController;

  bool isShowing = false;
  bool isVerified = false;
  bool isGestureDetectorVisible = true;
  late Timer timer;

  void verifyToken(String token) async {
    String url = "https://www.google.com/recaptcha/api/siteverify";
    http.Response response = await http.post(Uri.parse(url), body: {
      "secret": widget.apiSecret,
      "response": token,
    });

    // print("Response status: ${response.statusCode}");
    // print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      if (json['success']) {
        widget.onVerifiedSuccessfully?.call(true);
        isVerified = true;
      } else {
        widget.onVerifiedSuccessfully?.call(false);
        widget.onVerifiedError?.call(json['error-codes'].toString());
        isVerified = false;
      }
    }
    // hide captcha
    _hide();
  }

  void _show() {
    setState(() {
      isShowing = true;
      isGestureDetectorVisible = false;
    });
  }

  void _hide() {
    setState(() {
      isShowing = false;
      isGestureDetectorVisible = true;
    });
  }

  void _reload() {
    if (!isVerified) {
      webViewController.clearCache();
      webViewController.reload();
      _hide();
    }
  }

  void _startTimer() {
    timer = Timer(const Duration(seconds: 60), () {
      setState(() {
        isVerified = false;
      });
    });
  }

  @override
  void initState() {
    controller = widget.controller;
    controller.onReload = _reload;
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'RecaptchaFlutterChannel',
        onMessageReceived: (JavaScriptMessage receiver) {
          String token = receiver.message;
          if (token.contains("verify")) {
            token = token.substring(7);
          }
          verifyToken(token);
        },
      )
      ..loadRequest(Uri.parse("${widget.pluginURL}?api_key=${widget.apiKey}"));
    _startTimer();
  }

  @override
  void didUpdateWidget(RecaptchaV2 oldWidget) {
    if (widget.controller != oldWidget.controller) {
      controller = widget.controller;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    timer.cancel();
    controller.onReload = null;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 100),
      child: Container(
        padding: widget.padding,
        height: isShowing ? 500 : 90,
        child: Stack(
          children: [
            WebViewWidget(controller: webViewController),
            if(isGestureDetectorVisible)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (_) {
                if (!isVerified) _show();
              },
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class RecaptchaV2Controller extends ChangeNotifier {
  bool isDisposed = false;
  VoidCallback? onReload;

  void reload() {
    if (!isDisposed) onReload?.call();
  }

  @override
  void dispose() {
    isDisposed = true;
    onReload = null;
    super.dispose();
  }
}
