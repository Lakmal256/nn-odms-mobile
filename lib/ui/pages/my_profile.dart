import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../../util/storage.dart';
import '../forms/validators.dart';
import '../ui.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.onDone});
  final Function(OtpView) onDone;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final controller = ProfileFormController(
    initialValue: ProfileFormValue.empty(),
  );
  late Future<UserResponseDto?> action;
  late UserResponseDto? unTouchedData;
  String? number;

  @override
  void initState() {
    fetchUser();
    refreshUser();
    super.initState();
  }

  fetchUser() {
    setState(() {
      action = () async {
        Storage storage = Storage();
        String? email = await storage.readValue("email");
        final data = await locate<RestService>().getUserByEmail(email!);
        number = data?.mobileNo ?? "";
        unTouchedData = data?..mobileNo = number;

        String countryCode = "";
        String mobileNumber = "";

        if (number!.startsWith(RegExp(r'^[17]'))) {
          mobileNumber = number!.substring(1);
          countryCode = number!.substring(0, 1);
        } else if (number!.startsWith(RegExp(r'^[1-9][0-9]'))) {
          mobileNumber = number!.substring(2);
          countryCode = number!.substring(0, 2);
        } else if (number!.startsWith(RegExp(r'^[1-9][0-9]{2,}'))) {
          mobileNumber = number!.substring(3);
          countryCode = number!.substring(0, 3);
        }

        controller.setValue(controller.value.copyWith(
          firstName: data?.firstName,
          lastName: data?.lastName,
          roleName: data?.roles?.first.roleName,
          email: data?.email,
          mobileNumberWithCountryCode: number,
          mobileNumber: mobileNumber,
          countryCode: countryCode,
          sapEmployeeCode: data?.sapEmployeeCode,
          soldToCode: data?.customers?.first.soldToCode,
          internal: data?.internal,
          customers: data?.customers,
        ));
        return data;
      }.call();
    });
  }

  Future<void> refreshUser() async {
    Storage storage = Storage();
    String? email = await storage.readValue("email");
    final data = await locate<RestService>().getUserByEmail(email!);
    setState(() {
      unTouchedData = data;
    });
  }

  updateProfile() async {
    if (await controller.validate()) {
      String mobileNumber = "";

      if (number!.startsWith(RegExp(r'^[17]'))) {
        mobileNumber = number!.substring(1);
      } else if (number!.startsWith(RegExp(r'^[1-9][0-9]'))) {
        mobileNumber = number!.substring(2);
      } else if (number!.startsWith(RegExp(r'^[1-9][0-9]{2,}'))) {
        mobileNumber = number!.substring(3);
      }
      try {
        /// Handle mobile change is there is any
        if (isMobileNumberTouched) {
          locate<LoadingIndicatorController>().show();
          await locate<RestService>().initUpdateMobile(mobileNumber);
          locate<LoadingIndicatorController>().hide();

          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "OTP has been sent",
              subtitle: "Please check your messages",
              color: Colors.green,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );

          if (context.mounted) {
            final authorizationCode = await showOtpDialog(
              context,
              email: controller.value.email!,
              mobile: number!,
            );

            if (authorizationCode == null) return;
            await locate<RestService>()
                .completeUpdateMobile(controller.value.mobileNumberWithCountryCode!, authorizationCode);
          }
        }

        locate<LoadingIndicatorController>().show();
        Storage storage = Storage();
        String idString = await storage.readValue("id") ?? "";
        int id = int.parse(idString);
        await locate<RestService>().updateUser(
          id: id,
          firstName: controller.value.firstName,
          lastName: controller.value.lastName,
        );

        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Success",
            subtitle: "Profile updated successfully",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        refreshUser();
      } on ConflictedUserException {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "The mobile number already exists",
            subtitle: "Sorry, Please enter a different number",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } catch (_) {
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

  handleSendOtp() async {
    try {
      locate<LoadingIndicatorController>().show();
      if (controller.value.email != null) {
        await locate<RestService>().sendOtp(controller.value.email!);
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "OTP has been sent",
            subtitle: "Please check your messages",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpView(
              email: controller.value.email!,
              mobile: controller.value.mobileNumberWithCountryCode!,
              controller: TextEditingController(),
              onCancel: () => Navigator.of(context).pop(),
              onResend: handleSendOtp,
              onDone: (value) {
                GoRouter.of(context).go("/password-reset/new-password/${value.authorizationCode}");
              },
            ),
          ),
        );
      }
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
    return Material(
      child: FutureBuilder(
        future: action,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const AppBarWithTM(),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: BackButton(
                        onPressed: () => GoRouter.of(context).go("/home"),
                      ),
                    ),
                    Text(
                      "My Profile",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    children: [
                      ProfileViewHeader(
                        avatarUrl: "https://ui-avatars.com/api/?background=random&name=${controller.value.firstName}+"
                            "${controller.value.lastName}",
                        firstName: controller.value.firstName,
                        lastName: controller.value.lastName,
                        roleName: controller.value.roleName,
                        sapEmployeeCode: controller.value.sapEmployeeCode,
                        internalUser: controller.value.internal,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ProfileForm(controller: controller),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (controller.value.internal == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22.0),
                          child: GestureDetector(
                            onTap: handleSendOtp,
                            child: Row(
                              children: [
                                Text(
                                  "Reset Password",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.red),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.red,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 200, right: 15, bottom: 15),
                        child: FilledButton(
                          onPressed: updateProfile,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.standard,
                            textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
                            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                            backgroundColor: MaterialStateProperty.all(AppColors.red),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: const Text("Save"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool get isMobileNumberTouched => unTouchedData?.mobileNo != controller.value.mobileNumberWithCountryCode;
}

class ProfileViewHeader extends StatelessWidget {
  final String? avatarUrl;
  final String? firstName;
  final String? lastName;
  final String? roleName;
  final String? sapEmployeeCode;
  final bool? internalUser;
  const ProfileViewHeader({
    Key? key,
    required this.avatarUrl,
    required this.firstName,
    required this.lastName,
    required this.roleName,
    required this.sapEmployeeCode,
    required this.internalUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Container(
            margin: const EdgeInsets.only(top: 80),
            height: MediaQuery.of(context).size.height / (MediaQuery.of(context).size.shortestSide < 380 ? 4 : 5),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              image: DecorationImage(
                image: const AssetImage('assets/images/img.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: sapEmployeeCode == null ? MainAxisAlignment.center : MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 8, right: 8),
                    child: FittedBox(
                      child: Text(
                        "$firstName $lastName",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      "$roleName",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: sapEmployeeCode == null ? 0 : 15,
                  ),
                  if (sapEmployeeCode != null)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                        child: FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SAP Employee Code",
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "$sapEmployeeCode",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            children: [
              Container(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 55.0,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileFormValue {
  String? firstName;
  String? lastName;
  String? roleName;
  String? email;
  String? mobileNumber;
  String? mobileNumberWithCountryCode;
  String? countryCode;
  String? sapEmployeeCode;
  bool? internal;
  List<CustomerDto>? customers;
  List<ShipToListDto>? shipToLists;
  String? soldToCode;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  ProfileFormValue.empty();

  ProfileFormValue copyWith({
    String? firstName,
    String? lastName,
    String? roleName,
    String? email,
    String? mobileNumber,
    String? mobileNumberWithCountryCode,
    String? countryCode,
    String? sapEmployeeCode,
    bool? internal,
    List<CustomerDto>? customers,
    List<ShipToListDto>? shipToLists,
    String? soldToCode,
    Map<String, String>? errors,
  }) {
    return ProfileFormValue.empty()
      ..firstName = firstName ?? this.firstName
      ..lastName = lastName ?? this.lastName
      ..roleName = roleName ?? this.roleName
      ..email = email ?? this.email
      ..internal = internal ?? this.internal
      ..mobileNumber = mobileNumber ?? this.mobileNumber
      ..mobileNumberWithCountryCode = mobileNumberWithCountryCode ?? this.mobileNumberWithCountryCode
      ..countryCode = countryCode ?? this.countryCode
      ..customers = customers ?? this.customers
      ..shipToLists = shipToLists ?? this.shipToLists
      ..soldToCode = soldToCode ?? this.soldToCode
      ..sapEmployeeCode = sapEmployeeCode ?? this.sapEmployeeCode
      ..errors = errors ?? this.errors;
  }
}

class ProfileFormController extends FormController<ProfileFormValue> {
  ProfileFormController({required super.initialValue});

  clear() {
    value = ProfileFormValue.empty();
  }

  @override
  Future<bool> validate() async {
    value.errors.clear();

    /// First Name Validations
    String? firstName = value.firstName;
    if (FormValidators.isEmpty(firstName)) {
      value.errors.addAll({"firstName": "First name is required"});
    } else {
      try {
        if (firstName!.length > 20) {
          value.errors.addAll({"firstName": "You have exceeded the maximum number of 20 characters"});
        }
        FormValidators.isPure(firstName);
      } on ArgumentError catch (err) {
        value.errors.addAll({"firstName": err.message});
      }
    }

    /// Last Name Validations
    String? lastName = value.lastName;
    if (FormValidators.isEmpty(lastName)) {
      value.errors.addAll({"lastName": "Last name is required"});
    } else {
      try {
        if (lastName!.length > 20) {
          value.errors.addAll({"lastName": "You have exceeded the maximum number of 20 characters"});
        }
        FormValidators.isPure(lastName);
      } on ArgumentError catch (err) {
        value.errors.addAll({"lastName": err.message});
      }
    }

    /// Mobile Validations
    String? mobile = value.mobileNumberWithCountryCode;
    if (FormValidators.isEmpty(mobile)) {
      value.errors.addAll({"mobileNumber": "Mobile number is required"});
    } else {
      try {
        /// Validating with the +94 prefix
        FormValidators.mobile(mobile!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"mobileNumber": err.message});
      }
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class CustomerData {
  String soldToCode;
  List<ShipToListDto?>? shipToList;

  CustomerData({
    required this.soldToCode,
    required this.shipToList,
  });
}

class ProfileForm extends StatefulFormWidget<ProfileFormValue> {
  const ProfileForm({super.key, required super.controller});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> with FormMixin {
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController contactNumberTextEditingController = TextEditingController();
  TextEditingController soldToCodeTextEditingController = TextEditingController();
  String? selectedSoldToCode;
  List<String>? shipToList;

  @override
  void init() {
    handleFormControllerEvent();
    currentSoldToCode = widget.controller.value.soldToCode ?? "";
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    try {
      final value = widget.controller.value;

      final firstName = value.firstName ?? "";
      firstNameTextEditingController.value = firstNameTextEditingController.value.copyWith(
        text: firstName,
      );

      final lastName = value.lastName ?? "";
      lastNameTextEditingController.value = lastNameTextEditingController.value.copyWith(
        text: lastName,
      );

      final mobile = value.mobileNumber;
      contactNumberTextEditingController.value = contactNumberTextEditingController.value.copyWith(
        text: mobile,
      );

      final soldToCode = value.soldToCode ?? "";
      soldToCodeTextEditingController.value = soldToCodeTextEditingController.value.copyWith(
        text: soldToCode,
      );
    } on Error catch (_) {
      super.handleFormControllerEvent();
    }
  }

  String? currentSoldToCode;

  Future<List<String>> fetchShipToList() async {
    final shipToCodeListService = locate<ShipToCodeListService>();
    await shipToCodeListService.fetchShipToList(soldToCode: currentSoldToCode!);
    return shipToCodeListService.value.shipToCodeList.map((e) => e.shipToCode!).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchShipToList().then((list) {
      setState(() {
        shipToList = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "First Name",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: formValue.getError("firstName") != null ? Colors.red : const Color(0xFFD7D7D7),
                  ),
                ),
                child: TextField(
                  controller: firstNameTextEditingController,
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    hintText: 'First Name',
                  ),
                  onChanged: (value) {
                    widget.controller.setValue(
                      widget.controller.value..firstName = value,
                    );
                  },
                ),
              ),
            ),
            if (formValue.getError("firstName") != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  formValue.getError("firstName")!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFFF0000)),
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Last Name",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: formValue.getError("lastName") != null ? Colors.red : const Color(0xFFD7D7D7),
                  ),
                ),
                child: TextField(
                  controller: lastNameTextEditingController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    hintText: 'Last Name',
                  ),
                  onChanged: (value) {
                    widget.controller.setValue(
                      widget.controller.value..lastName = value,
                    );
                  },
                ),
              ),
            ),
            if (formValue.getError("lastName") != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  formValue.getError("lastName")!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFFF0000)),
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Mobile Number",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: formValue.getError("mobileNumber") != null ? Colors.red : const Color(0xFFD7D7D7),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CountryCodePicker(
                      onChanged: (CountryCode? code) {
                        widget.controller.setValue(
                          widget.controller.value..countryCode = code!.dialCode,
                        );
                      },
                      initialSelection: 'LK', // Set initial country code
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF000000)),
                    ),
                    Flexible(
                      child: TextField(
                        controller: contactNumberTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Mobile Number',
                        ),
                        onChanged: (value) {
                          widget.controller.setValue(
                            widget.controller.value..mobileNumber = value,
                          );
                          if (widget.controller.value.countryCode != null && value != null) {
                            widget.controller.setValue(
                              widget.controller.value
                                ..mobileNumberWithCountryCode = widget.controller.value.countryCode! + value,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (formValue.getError("mobileNumber") != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  formValue.getError("mobileNumber")!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFFF0000)),
                ),
              ),
            const SizedBox(height: 15),
            if (widget.controller.value.roleName == "Call Center User" ||
                widget.controller.value.roleName == "Retail Sales User" ||
                widget.controller.value.roleName == "B2B Sales User/AM" ||
                widget.controller.value.roleName == "Customer Admin" ||
                widget.controller.value.roleName == "Customer User" ||
                widget.controller.value.roleName == "Commercial User")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: widget.controller.value.internal == true
                    ? Text(
                        "Sold-To-Codes",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.bold),
                      )
                    : Text(
                        "Sold-To-Code",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.bold),
                      ),
              ),
            const SizedBox(height: 10),
            if (widget.controller.value.roleName == "Call Center User" ||
                widget.controller.value.roleName == "Retail Sales User" ||
                widget.controller.value.roleName == "B2B Sales User/AM" ||
                widget.controller.value.roleName == "Customer Admin" ||
                widget.controller.value.roleName == "Customer User" ||
                widget.controller.value.roleName == "Commercial User")
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child:
                      // widget.controller.value.internal == false ?
                      Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFFD7D7D7)),
                    ),
                    child: DropdownButton(
                      hint: const Text("Sold-To-Codes"),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      value: widget.controller.value.soldToCode,
                      items: widget.controller.value.customers!
                          .map((customers) => DropdownMenuItem(
                                value: customers.soldToCode,
                                child: Text(customers.soldToCode!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSoldToCode = value!;
                        });
                        widget.controller.setValue(
                          widget.controller.value..soldToCode = value,
                        );
                        currentSoldToCode = value;
                        fetchShipToList().then((list) {
                          setState(() {
                            shipToList = list;
                          });
                        });
                      },
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF000000)),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                    ),
                  )),
            const SizedBox(height: 10),
            if (widget.controller.value.roleName == "Call Center User" ||
                widget.controller.value.roleName == "Retail Sales User" ||
                widget.controller.value.roleName == "B2B Sales User/AM" ||
                widget.controller.value.roleName == "Customer Admin" ||
                widget.controller.value.roleName == "Customer User" ||
                widget.controller.value.roleName == "Commercial User")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Ship-To-Codes",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),
            if (widget.controller.value.roleName == "Call Center User" ||
                widget.controller.value.roleName == "Retail Sales User" ||
                widget.controller.value.roleName == "B2B Sales User/AM" ||
                widget.controller.value.roleName == "Customer Admin" ||
                widget.controller.value.roleName == "Customer User" ||
                widget.controller.value.roleName == "Commercial User")
              ValueListenableBuilder(
                valueListenable: locate<ShipToCodeListService>(),
                builder: (context, snapshot, _) {
                  if (snapshot.shipToCodeList.isEmpty) {
                    return const Center(
                      child: FittedBox(child: Text("N/A")),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.shipToCodeList
                          .map(
                            (shipToCodeList) => Text(
                              "${shipToCodeList.shipToCode}\n${shipToCodeList.shipToName}\n ",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF000000)),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
