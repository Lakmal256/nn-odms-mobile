import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';
import 'validators.dart';

class UserIdentityFormValue extends FormValue {
  String? identifier;

  UserIdentityFormValue({this.identifier});
}

class UserIdentityFormController extends FormController<UserIdentityFormValue> {
  UserIdentityFormController() : super(initialValue: UserIdentityFormValue(identifier: ""));

  @override
  Future<bool> validate() async {
    value.errors.clear();

    if (FormValidators.isEmpty(value.identifier)) {
      value.errors.addAll({"id": "Email is required"});
    } else {
      try {
        FormValidators.email(value.identifier!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"id": err.message});
      }
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class UserIdentityForm extends StatefulFormWidget<UserIdentityFormValue> {
  const UserIdentityForm({
    Key? key,
    required UserIdentityFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<UserIdentityForm> createState() => _UserIdentityFormState();
}

class _UserIdentityFormState extends State<UserIdentityForm> with FormMixin {
  TextEditingController identifierTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: identifierTextEditingController,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Email",
                errorText: formValue.getError("id"),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              onChanged: (value) => widget.controller.setValue(
                widget.controller.value..identifier = value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class UserIdentityFormViewResult {
  String? mobile;
  String? email;

  UserIdentityFormViewResult({this.mobile, this.email});
}

class UserIdentityFormView extends StatefulWidget {
  const UserIdentityFormView({Key? key, required this.onDone}) : super(key: key);

  final Function(UserIdentityFormViewResult) onDone;

  @override
  State<UserIdentityFormView> createState() => _UserIdentityFormViewState();
}

class _UserIdentityFormViewState extends State<UserIdentityFormView> {
  UserIdentityFormController controller = UserIdentityFormController();

  handleSendOtp() async {
    if (await controller.validate()) {
      RestService restService = locate<RestService>();
      try {
        locate<LoadingIndicatorController>().show();
        final userResp = await restService.userExist(controller.value.identifier!);

        if (userResp == true) {
         final getMobile = await restService.sendOtp(controller.value.identifier!.toLowerCase());
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "OTP has been sent",
              subtitle: "Please check your messages",
              color: Colors.green,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
          return widget.onDone(UserIdentityFormViewResult(
            mobile: getMobile,
            email: controller.value.identifier!.toLowerCase(),
          ));
        } else {
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "User not found",
              subtitle: "There is no user record corresponding to this Email address",
              color: Colors.red,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
                "Please enter your email address to\n receive a verification code",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: UserIdentityForm(
                controller: controller,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FilledButton(
                onPressed: handleSendOtp,
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
                child: const Text("SEND OTP"),
              ),
            ),
          ],
        ),
        BackButton(
          onPressed:  () => GoRouter.of(context).go("/login/credentials")),
      ],
    );
  }
}
