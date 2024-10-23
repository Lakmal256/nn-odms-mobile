import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../form.dart';
import '../../forms/validators.dart';
import '../../widgets.dart';

class DeliveryOrderCreateFormValue extends FormValue {
  String? shipTo;
  String? shippingUnit;
  String? shippingCondition;
  String? plant;
  String? division;
  String? organization;
  String? customer;

  DeliveryOrderCreateFormValue({
    this.shipTo,
    this.shippingUnit,
    this.shippingCondition,
    this.plant,
    this.division,
    this.organization,
    this.customer,
  });
}

class DeliveryOrderCreateFormController extends FormController<DeliveryOrderCreateFormValue> {
  DeliveryOrderCreateFormController()
      : super(
            initialValue: DeliveryOrderCreateFormValue(
                shipTo: "",
                shippingUnit: "",
                shippingCondition: "",
                plant: "",
                division: "",
                organization: "",
                customer: ""));

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? shipTo = value.shipTo;
    if (FormValidators.isEmpty(shipTo)) {
      value.errors.addAll({"shipTo": "Ship To is required"});
    }

    String? orderType = value.shippingUnit;
    if (FormValidators.isEmpty(orderType)) {
      value.errors.addAll({"orderType": "Order Type is required"});
    }

    String? shippingCondition = value.shippingCondition;
    if (FormValidators.isEmpty(shippingCondition)) {
      value.errors.addAll({"shippingCondition": "Shipping Condition is required"});
    }

    String? plant = value.plant;
    if (FormValidators.isEmpty(plant)) {
      value.errors.addAll({"plant": "Plant is required"});
    }

    String? division = value.plant;
    if (FormValidators.isEmpty(division)) {
      value.errors.addAll({"division": "Division is required"});
    }

    String? organization = value.organization;
    if (FormValidators.isEmpty(organization)) {
      value.errors.addAll({"organization": "Organization is required"});
    }

    String? customer = value.customer;
    if (FormValidators.isEmpty(customer)) {
      value.errors.addAll({"customer": "Customer is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class DeliveryOrderCreationDeliveredView extends StatelessWidget {
  DeliveryOrderCreationDeliveredView({
    Key? key,
  }) : super(key: key);
  final DeliveryOrderCreateFormController controller = DeliveryOrderCreateFormController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithTM(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 100.0),
                child: StepProgressIndicator(
                  totalSteps: 3,
                  currentStep: 0,
                  padding: 4,
                  selectedColor: Color(0xFF4A7A36),
                  roundedEdges: Radius.circular(15),
                  unselectedColor: Color(0xFFD9D9D9),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DODeliveredDivisionCard(controller: controller),
                    DODeliveredOrganizationCard(controller: controller),
                    DODeliveredCustomerCard(controller: controller),
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return DODeliveredBottomSheet(
                                onClose: Navigator.of(context).pop,
                                name: 'Sorting & Filtering',
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.tune_outlined,
                          color: Color(0xFF000000),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              DODeliveredDropdownBox(controller: controller),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FilledButton(
                  onPressed: () => GoRouter.of(context).go("/delivery-order-view"),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.standard,
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  child: const Text("NEXT"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DODeliveredDivisionCard extends StatefulFormWidget<DeliveryOrderCreateFormValue> {
  const DODeliveredDivisionCard({
    Key? key,
    required DeliveryOrderCreateFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<DODeliveredDivisionCard> createState() => _RetailCreditDivisionCardState();
}

class _RetailCreditDivisionCardState extends State<DODeliveredDivisionCard> {
  String selectedDivision = "";
  @override
  Widget build(BuildContext context) {
    final List<String> divisionTypes = ["CM1", "CM2"];
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 1,
              child: Container(
                color: Colors.white,
                height: 40,
                width: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              child: Text(
                                "Division",
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 40),
                              child: FittedBox(
                                child: Text(
                                  selectedDivision.isNotEmpty ? selectedDivision : "Select a Division",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: selectedDivision.isNotEmpty ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (value) {
                                widget.controller.setValue(
                                  widget.controller.value..division = value,
                                );
                                setState(() {
                                  selectedDivision = value;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return divisionTypes.map((type) {
                                  return PopupMenuItem<String>(
                                    value: type,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class DODeliveredOrganizationCard extends StatefulFormWidget<DeliveryOrderCreateFormValue> {
  const DODeliveredOrganizationCard({
    Key? key,
    required DeliveryOrderCreateFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<DODeliveredOrganizationCard> createState() => _RetailCreditOrganizationCardState();
}

class _RetailCreditOrganizationCardState extends State<DODeliveredOrganizationCard> {
  String selectedOrganization = "";
  @override
  Widget build(BuildContext context) {
    final List<String> organizationTypes = ["SCCL Domesic Sales", "MCCL Domesic Sales"];
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 1,
              child: Container(
                color: Colors.white,
                height: 40,
                width: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              child: Text(
                                "Sales Organization",
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 40),
                              child: FittedBox(
                                child: Text(
                                  selectedOrganization.isNotEmpty ? selectedOrganization : "Select a Organization",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: selectedOrganization.isNotEmpty ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (value) {
                                widget.controller.setValue(
                                  widget.controller.value..organization = value,
                                );
                                setState(() {
                                  selectedOrganization = value;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return organizationTypes.map((type) {
                                  return PopupMenuItem<String>(
                                    value: type,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class DODeliveredCustomerCard extends StatefulFormWidget<DeliveryOrderCreateFormValue> {
  const DODeliveredCustomerCard({
    Key? key,
    required DeliveryOrderCreateFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<DODeliveredCustomerCard> createState() => _RetailCreditCustomerCardState();
}

class _RetailCreditCustomerCardState extends State<DODeliveredCustomerCard> {
  String selectedCustomer = "";
  @override
  Widget build(BuildContext context) {
    final List<String> customerTypes = ["76565432", "76543211"];
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 1,
              child: Container(
                color: Colors.white,
                height: 40,
                width: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              child: Text(
                                "Customer",
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 40),
                              child: FittedBox(
                                child: Text(
                                  selectedCustomer.isNotEmpty ? selectedCustomer : "Select a Customer",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: selectedCustomer.isNotEmpty ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (value) {
                                widget.controller.setValue(
                                  widget.controller.value..customer = value,
                                );
                                setState(() {
                                  selectedCustomer = value;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return customerTypes.map((type) {
                                  return PopupMenuItem<String>(
                                    value: type,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class DODeliveredBottomSheet extends StatefulWidget {
  const DODeliveredBottomSheet({
    Key? key,
    required this.name,
    required this.onClose,
  }) : super(key: key);

  final String name;
  final VoidCallback onClose;

  @override
  State<DODeliveredBottomSheet> createState() => _DODeliveredBottomSheetState();
}

class _DODeliveredBottomSheetState extends State<DODeliveredBottomSheet> {
  List<DODeliveredRadioOption> divisionOptions = [
    DODeliveredRadioOption(title: "Cement 1", value: 0),
    DODeliveredRadioOption(title: "Cement 2", value: 1),
  ];

  List<DODeliveredRadioOption> salesOrganizationOptions = [
    DODeliveredRadioOption(title: "Sales 1", value: 0),
    DODeliveredRadioOption(title: "Sales 2", value: 1),
    DODeliveredRadioOption(title: "Sales 3", value: 2),
  ];

  List<DODeliveredRadioOption> salesCustomerOptions = [
    DODeliveredRadioOption(title: "765645567", value: 0),
    DODeliveredRadioOption(title: "S76554343", value: 1),
    DODeliveredRadioOption(title: "766545437", value: 2),
  ];
  int? selectedDivision;
  int? selectedSalesOrganization;
  int? selectedSalesCustomer;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.0),
          topRight: Radius.circular(6.0),
        ),
      ),
      height: MediaQuery.of(context).size.height / 2,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 40, color: Colors.grey),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: FittedBox(
                        child: Text(
                          widget.name,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF000000),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Sort by Division",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF868687),
                          ),
                    ),
                    for (var option in divisionOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedDivision == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedDivision,
                          onChanged: (value) {
                            setState(() {
                              selectedDivision = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                    const Divider(
                      thickness: 2,
                    ),
                    Text(
                      "Sort by Sales Organization",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF868687),
                          ),
                    ),
                    for (var option in salesOrganizationOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedSalesOrganization == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedSalesOrganization,
                          onChanged: (value) {
                            setState(() {
                              selectedSalesOrganization = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                    const Divider(thickness: 2),
                    Text(
                      "Sort by Sales Organization",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF868687),
                          ),
                    ),
                    for (var option in salesCustomerOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedSalesCustomer == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedSalesCustomer,
                          onChanged: (value) {
                            setState(() {
                              selectedSalesCustomer = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DODeliveredRadioOption {
  final String title;
  final int value;

  DODeliveredRadioOption({required this.title, required this.value});
}

class DODeliveredDropdownBox extends StatefulFormWidget<DeliveryOrderCreateFormValue> {
  const DODeliveredDropdownBox({
    Key? key,
    required DeliveryOrderCreateFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<DODeliveredDropdownBox> createState() => _RetailCreditDropdownBoxState();
}

class _RetailCreditDropdownBoxState extends State<DODeliveredDropdownBox> with FormMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  SingleValueDropDownController shipToDropDownController = SingleValueDropDownController();
  SingleValueDropDownController shippingUnitDropDownController = SingleValueDropDownController();
  SingleValueDropDownController shippingDropDownController = SingleValueDropDownController();
  SingleValueDropDownController plantDropDownController = SingleValueDropDownController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropDownTextField(
                    textFieldDecoration: const InputDecoration(
                      hintText: "Shipping Conditions",
                    ),
                    controller: shippingDropDownController,
                    clearOption: true,
                    validator: (value) {
                      if (value == null) {
                        return "Required field";
                      } else {
                        return value;
                      }
                    },
                    dropDownItemCount: 4,
                    dropDownList: const [
                      DropDownValueModel(name: 'name1', value: "value1"),
                      DropDownValueModel(name: 'name2', value: "value2"),
                      DropDownValueModel(name: 'name3', value: "value3"),
                      DropDownValueModel(name: 'name4', value: "value4"),
                    ],
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..shippingCondition = value?.value,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropDownTextField(
                    textFieldDecoration: const InputDecoration(
                      hintText: "Shipping Unit",
                    ),
                    controller: shippingUnitDropDownController,
                    clearOption: true,
                    validator: (value) {
                      if (value == null) {
                        return "Required field";
                      } else {
                        return value;
                      }
                    },
                    dropDownItemCount: 4,
                    dropDownList: const [
                      DropDownValueModel(name: 'name1', value: "value1"),
                      DropDownValueModel(name: 'name2', value: "value2"),
                    ],
                    onChanged: (value) {
                      widget.controller.setValue(
                        widget.controller.value..shippingUnit = value?.value, // or the appropriate field
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropDownTextField(
                    textFieldDecoration: const InputDecoration(
                      hintText: "Plant",
                    ),
                    controller: plantDropDownController,
                    clearOption: true,
                    validator: (value) {
                      if (value == null) {
                        return "Required field";
                      } else {
                        return value;
                      }
                    },
                    dropDownItemCount: 4,
                    dropDownList: const [
                      DropDownValueModel(name: 'name1', value: "value1"),
                      DropDownValueModel(name: 'name2', value: "value2"),
                    ],
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..plant = value?.value,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropDownTextField(
                    textFieldDecoration: const InputDecoration(
                      hintText: "Ship To",
                    ),
                    controller: shipToDropDownController,
                    clearOption: true,
                    validator: (value) {
                      if (value == null) {
                        return "Required field";
                      } else {
                        return value;
                      }
                    },
                    dropDownItemCount: 4,
                    dropDownList: const [
                      DropDownValueModel(name: 'name1', value: "value1"),
                      DropDownValueModel(name: 'name2', value: "value2"),
                      DropDownValueModel(name: 'name3', value: "value3"),
                      DropDownValueModel(name: 'name4', value: "value4"),
                    ],
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..shipTo = value?.value,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
