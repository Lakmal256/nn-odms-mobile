import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:odms/app_config.dart';
import 'package:odms/util/storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';
import './validators.dart';

class LoginFormValue extends FormValue {
  String? uName;
  String? pwd;

  LoginFormValue({this.uName, this.pwd});
}

class LoginFormController extends FormController<LoginFormValue> {
  LoginFormController() : super(initialValue: LoginFormValue(pwd: "", uName: ""));

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? uName = value.uName;
    if (FormValidators.isEmpty(uName)) {
      value.errors.addAll({"uName": "Email is required"});
    } else {
      try {
        FormValidators.email(uName!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"uName": err.message});
      }
    }

    String? password = value.pwd;
    if (FormValidators.isEmpty(password)) {
      value.errors.addAll({"pwd": "Password is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class LoginForm extends StatefulFormWidget<LoginFormValue> {
  const LoginForm({
    Key? key,
    required LoginFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with FormMixin {
  TextEditingController uNameTextEditingController = TextEditingController();
  TextEditingController pWDTextEditingController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: uNameTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Email",
                errorText: formValue.getError("uName"),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..uName = value,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pWDTextEditingController,
              obscureText: _isObscure,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Password",
                errorText: formValue.getError("pwd"),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..pwd = value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class LoginFormViewResult {
  late String mobile;
  late LoginFormValue formValue;
  late bool changePasswordNextLogin;
  late bool isNewUser;
}

class LoginFormView extends StatefulWidget {
  const LoginFormView({
    Key? key,
    required this.onDone,
    this.shouldSendOtp = false,
    this.onResetPasswordPress,
  }) : super(key: key);

  final bool shouldSendOtp;
  final Function(LoginFormViewResult) onDone;
  final Function()? onResetPasswordPress;

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final LoginFormController controller = LoginFormController();
  TokenResponse? tokenResponse;
  bool recaptchaVerified = false;

  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();
  WebViewController webController = WebViewController();

  late Timer _timer;
  int _countdown = 59;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _countdown = 59;
          recaptchaVerified = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  handleLogin() async {
    if (await controller.validate()) {
      try {
        locate<LoadingIndicatorController>().show();
        LoginFormViewResult loginFormViewResult = LoginFormViewResult()..formValue = controller.value;

        AuthService? authService = locate<TokenProvider>().service;

        if (authService is StandardAuthService) {
          authService.credentials = StdLoginCredentials(
            userName: controller.value.uName!,
            password: controller.value.pwd!,
          );
        } else {
          throw Exception();
        }

        TokenProvider tokenProvider = locate<TokenProvider>();
        loginFormViewResult.isNewUser = await tokenProvider.localTokenHandler.readRefreshToken() == null;
        TokenResponse? loginResponse = await tokenProvider.login();

        loginFormViewResult.changePasswordNextLogin = loginResponse?.user?.changePasswordNextLogin ?? false;

        /// save the session in local storage
        await tokenProvider.saveSession();

        await locate<CloudMessagingHelperService>().requestPermission();
        await locate<CloudMessagingHelperService>().registerDeviceToken();

        RestService restService = locate<RestService>();
        final userResp = await restService.getUserByEmail(controller.value.uName!);

        if (userResp == null) throw Exception();

        Storage storage = Storage();
        storage.saveValue("email", userResp.email!);
        storage.saveValue("id", userResp.id.toString());
        storage.saveValue("internal", userResp.internal!.toString());
        UserService userService = locate<UserService>();
        userService.setUser(userService.value
          ..data = UserData(
            email: userResp.email!,
            mobile: userResp.mobileNo!,
          ));

        loginFormViewResult.mobile = userResp.mobileNo!;

        if (userResp.email != null && loginFormViewResult.isNewUser) {
          if (widget.shouldSendOtp) {
            await tokenProvider.clearSession();
            await restService.sendOtp(userResp.email!);
            locate<PopupController>().addItemFor(
              DismissiblePopup(
                title: "OTP has been sent",
                subtitle: "Please check your messages",
                color: Colors.green,
                onDismiss: (self) => locate<PopupController>().removeItem(self),
              ),
              const Duration(seconds: 5),
            );
          }
        }

        return widget.onDone(loginFormViewResult);
      } on UserNotFoundException catch (_) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "User not found",
            subtitle: "There is no user record corresponding to this Email address",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on UnauthorizedException catch (e) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: e.message == "Your profile is locked." ? e.message:  "Incorrect login credentials",
            subtitle:  e.message != "Your profile is locked." ? e.message : "Try again in 15 minutes.",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on BlockedUserException catch (_) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "User Deactivated",
            subtitle: "Your account has been deactivated",
            color: Colors.red,
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
  }

  handleADLogin() async {
    try {
      locate<LoadingIndicatorController>().show();
      // Login using Azure AD
      final userData = await AzureAuthService.login();
      if (userData != null || userData!.mail != null) {
        // Perform AD login
        AuthService? authService = locate<TokenProvider>().service;

        if (authService is StandardAuthService) {
          authService.adDetails = ADStdLoginDetails(
            adToken: userData.idToken!,
            adTenantId: locate<AppConfig>().tenantId!,
            email: userData.mail!,
          );
        } else {
          throw Exception();
        }
        // Perform AD tokenProvider operation
        TokenProvider tokenProvider = locate<TokenProvider>();
        await tokenProvider.adLogin();
        await tokenProvider.saveSession();

        await locate<CloudMessagingHelperService>().requestPermission();
        await locate<CloudMessagingHelperService>().registerDeviceToken();

        RestService restService = locate<RestService>();
        final userResp = await restService.getUserByEmail(userData.mail!);

        Storage storage = Storage();
        storage.saveValue("email", userResp?.email ?? "");
        storage.saveValue("id", userResp?.id.toString() ?? "");
        storage.saveValue("internal", userResp?.internal!.toString() ?? "");
        UserService userService = locate<UserService>();
        userService.setUser(userService.value
          ..data = UserData(
            email: userResp?.email ?? "",
            mobile: userResp?.mobileNo ?? "",
          ));

        if (context.mounted) GoRouter.of(context).go("/home");
      } else {
        throw Exception();
      }
    } on UserNotFoundException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "User not found",
          subtitle: "There is no user record corresponding to this Email address",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on UnauthorizedException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Invalid login credentials",
          subtitle: "You may have entered invalid username or password",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on BlockedUserException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "User Deactivated",
          subtitle: "Your account has been deactivated",
          color: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          AspectRatio(
            aspectRatio: 7,
            child: Image.asset(
              "assets/images/tm_001.png",
              fit: BoxFit.scaleDown,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Welcome!",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.red, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("Enter your credentials to login",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF000000))),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Distributor or B2B Customer Login",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: const Color(0xFF000000))),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: LoginForm(controller: controller),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FilledButton(
              onPressed: recaptchaVerified ? handleLogin : null,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
                backgroundColor: recaptchaVerified
                    ? MaterialStateProperty.all(AppColors.red)
                    : MaterialStateProperty.all(Colors.grey),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              child: const Text("LOGIN"),
            ),
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: widget.onResetPasswordPress != null,
            child: GestureDetector(
              onTap: widget.onResetPasswordPress,
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: AppColors.blue.withOpacity(0.05),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  "Forgot password?",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.blue,
                        // decoration: TextDecoration.underline,
                        // fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: RecaptchaV2(
              apiKey: dotenv.env['RECAPTCHA_API_KEY'] ?? 'RECAPTCHA_API_KEY not found',
              apiSecret: dotenv.env['RECAPTCHA_SECRET_KEY'] ?? 'RECAPTCHA_SECRET_KEY not found',
              controller: recaptchaV2Controller,
              onVerifiedError: (err) {
                setState(() {
                  recaptchaVerified = false;
                });
              },
              onVerifiedSuccessfully: (success) {
                setState(() {
                  if (success) {
                    recaptchaVerified = true;
                    _countdown = 59;
                  } else {
                    recaptchaVerified = false;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 1,
                  indent: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "OR",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xFF000000)),
                ),
              ),
              const Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 1,
                  endIndent: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Insee Staff User",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: const Color(0xFF000000))),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: AzureSignOnButton(onPressed: handleADLogin),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class AzureSignOnButton extends StatelessWidget {
  const AzureSignOnButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
      onPressed: onPressed,
      child: AspectRatio(
        aspectRatio: 6.2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              Image.asset("assets/images/microsoft_button.png"),
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: MediaQuery.of(context).size.width >= 360
                      ? 0.65 : 0.9,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "Sign in with Microsoft",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}
