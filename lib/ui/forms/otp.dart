import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';

class OtpViewResult {
  String authorizationCode;
  String? mobile;

  OtpViewResult({required this.authorizationCode, this.mobile});
}

class OtpView extends StatefulWidget {
  const OtpView({
    Key? key,
    this.mobile,
    this.email,
    this.obfuscateMobile = true,
    required this.onDone,
    required this.onCancel,
    required this.onResend,
    required this.controller,
  }) : super(key: key);

  final String? mobile;
  final String? email;
  final bool obfuscateMobile;
  final Function(OtpViewResult) onDone;
  final Function() onResend;
  final Function() onCancel;
  final TextEditingController controller;

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  FocusNode focusNode = FocusNode();
  String? error;
  String? token;

  @override
  void initState() {
    focusNode.requestFocus();
    loadTokenFromLocal();
    super.initState();
  }

  handleResendOTP() async {
    try {
      locate<LoadingIndicatorController>().show();
      widget.controller.text = "";
      RestService restService = locate<RestService>();
      await restService.sendOtp(widget.email!);
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "OTP has been sent",
          subtitle: "Please check your messages",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  String? validate() {
    if (widget.controller.text.trim().isEmpty || widget.controller.text.length < 6) {
      return "Please enter 6 digits OTP";
    }
    return null;
  }

  void loadTokenFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('refreshToken');
    });
  }

  handleOtp() async {
    String? error = validate();
    setState(() => this.error = error);
    if (error == null) {
      locate<LoadingIndicatorController>().show();
      String code = widget.controller.text;
      String email = widget.email!;
      String mobile = widget.mobile!;

      try {
        RestService restService = locate<RestService>();
        TokenProvider tokenProvider = locate<TokenProvider>();
        await locate<TokenProvider>().getToken(token!);
        await tokenProvider.saveSession();
        final authorizationCode = await restService.verifyOtp(email, code);
        return widget.onDone(OtpViewResult(authorizationCode: authorizationCode,mobile: mobile));
      } catch (err) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "OTP is invalid",
            subtitle: "Please try resending new OTP",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } finally {
        locate<LoadingIndicatorController>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 25),
            AspectRatio(
              aspectRatio: 7,
              child: Image.asset(
                "assets/images/tm_001.png",
                fit: BoxFit.scaleDown,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Please enter the 6-digit OTP sent to your\n mobile, "
                "${widget.obfuscateMobile ? obfuscateMobile(widget.mobile!) : widget.mobile}",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: InputDecorator(
                decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, errorText: error),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Pinput(
                    length: 6,
                    controller: widget.controller,
                    focusNode: focusNode,
                    defaultPinTheme: PinTheme(
                      height: 50,
                      width: 50,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(30, 60, 87, 1),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0x20000000),
                        ),
                      ),
                    ),
                    // showCursor: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FilledButton(
                onPressed: handleOtp,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
                  backgroundColor: MaterialStateProperty.all(AppColors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                child: const Text("CONFIRM"),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FilledButton(
                onPressed: widget.onCancel,
                style: ButtonStyle(
                  visualDensity: VisualDensity.standard,
                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
                  backgroundColor: MaterialStateProperty.all(AppColors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                child: const Text("CANCEL"),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive OTP?",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.blue),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: handleResendOTP,
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: AppColors.blue.withOpacity(0.05),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      "Resend OTP",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String obfuscateMobile(String value, [int count = 4]) {
  return "${value.substring(0, value.length - count).replaceAll(RegExp(r'(\d)'), "X")}"
      "${value.substring(value.length - count)}";
}
TextEditingController otpController = TextEditingController();
showOtpDialog(
  BuildContext context, {
  required String email,
  required String mobile,
}) =>
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (context) {
        return Material(
          child: SafeArea(
            child: OtpView(
              email: email,
              mobile: mobile,
              controller: otpController,
              onCancel: Navigator.of(context).pop,
              onResend: () async {
                try {
                  RestService restService = locate<RestService>();
                  await restService.sendOtp(email);

                  locate<PopupController>().addItemFor(
                    DismissiblePopup(
                      title: "OTP has been sent",
                      subtitle: "Please check your messages",
                      color: Colors.green,
                      onDismiss: (self) => locate<PopupController>().removeItem(self),
                    ),
                    const Duration(seconds: 5),
                  );
                } catch (err) {
                  locate<PopupController>().addItemFor(
                    DismissiblePopup(
                      title: "Something went wrong",
                      subtitle: "Sorry, something went wrong here",
                      color: Colors.red,
                      onDismiss: (self) => locate<PopupController>().removeItem(self),
                    ),
                    const Duration(seconds: 5),
                  );
                }
              },
              onDone: (value) async {
                try {
                  RestService restService = locate<RestService>();
                  final authorizationCode = await restService.verifyOtp(email, otpController.text);
                  if (context.mounted) Navigator.of(context).pop(authorizationCode);
                } catch (err) {
                  locate<PopupController>().addItemFor(
                    DismissiblePopup(
                      title: "OTP is not valid",
                      subtitle: "Please resend and try again",
                      color: Colors.red,
                      onDismiss: (self) => locate<PopupController>().removeItem(self),
                    ),
                    const Duration(seconds: 5),
                  );
                }
              },
            ),
          ),
        );
      },
    );
