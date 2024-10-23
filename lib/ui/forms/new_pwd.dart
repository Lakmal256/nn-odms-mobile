import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';
import 'validators.dart';

class NewPasswordFormValue extends FormValue {
  String? password;
  String? confirmation;

  NewPasswordFormValue({this.password, this.confirmation});
}

class NewPasswordFormController extends FormController<NewPasswordFormValue> {
  NewPasswordFormController() : super(initialValue: NewPasswordFormValue());

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? password = value.password;
    String? cPassword = value.confirmation;

    if (FormValidators.isEmpty(password)) {
      value.errors.addAll({"password": "Password is required"});
    } else {
      try {
        FormValidators.password(password!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"password": err.message});
      }

      if (password != cPassword) {
        value.errors.addAll({"cPassword": "Confirmation do not match"});
      }
    }

    if (FormValidators.isEmpty(cPassword)) {
      value.errors.addAll({"cPassword": "Password confirmation is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class NewPasswordForm extends StatefulFormWidget<NewPasswordFormValue> {
  const NewPasswordForm({super.key, required super.controller});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> with FormMixin {
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmationTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: passwordTextEditingController,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "New Password",
                errorText: formValue.getError("password"),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..password = value,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmationTextEditingController,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                errorText: formValue.getError("cPassword"),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..confirmation = value,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum PasswordResetMethod { std, withAuthorizationCode }

class NewPasswordFormView extends StatefulWidget {
  const NewPasswordFormView({
    Key? key,
    required this.onDone,
    this.authorizationCode,
    this.method = PasswordResetMethod.std,
  }) : super(key: key);

  final PasswordResetMethod method;
  final String? authorizationCode;

  final Function() onDone;

  @override
  State<NewPasswordFormView> createState() => _NewPasswordFormViewState();
}

class _NewPasswordFormViewState extends State<NewPasswordFormView> {
  NewPasswordFormController controller = NewPasswordFormController();

  handleConfirmation() async {
    if (await controller.validate()) {
      locate<LoadingIndicatorController>().show();
      try {
        switch (widget.method) {
          case PasswordResetMethod.std:
            // TODO: Handle this case.
            break;
          case PasswordResetMethod.withAuthorizationCode:
            if (widget.authorizationCode != null) {
              RestService restService = locate<RestService>();
              String password = controller.value.password!;
              await restService.resetPasswordWithAuthorizationCode(
                widget.authorizationCode!,
                password: password,
              );
              locate<PopupController>().addItemFor(
                DismissiblePopup(
                  title: "Password changed",
                  subtitle: "The password has been changed successfully",
                  color: Colors.green,
                  onDismiss: (self) => locate<PopupController>().removeItem(self),
                ),
                const Duration(seconds: 5),
              );
              return widget.onDone();
            }
            break;
        }
      } on PasswordResetException catch (e) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: e.message,
            subtitle:  "Try again with a new password",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      }
      catch (err) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Recently used or invalid password",
            subtitle: "Try again with a new password",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      }
      finally {
        locate<LoadingIndicatorController>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 7,
          child: Image.asset(
            "assets/images/tm_001.png",
            fit: BoxFit.scaleDown,
          ),
        ),
        const SizedBox(height: 50),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Change your password",
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: NewPasswordForm(
            controller: controller,
          ),
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FilledButton(
            onPressed: handleConfirmation,
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
            child: const Text("CONFIRM"),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FilledButton(
            onPressed: () {
              GoRouter.of(context).go("/login/credentials");
            },
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
      ],
    );
  }
}
