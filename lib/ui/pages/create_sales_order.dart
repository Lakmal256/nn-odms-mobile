import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../app_config.dart';
import '../../locator.dart';
import 'package:path/path.dart' show extension;
import '../../service/service.dart';
import '../../util/util.dart';
import '../ui.dart';

class OrderCreateFormValue {
  String? userRole;
  String? customerType;
  String? shipTo;
  String? shipToName;
  String? soldToCode;
  String? soldToName;
  String? channelCode;
  String? orderType;
  String? shippingCondition;
  List<DetailDto>? divisionCodeList;
  List<DetailDto>? salesOrgCodeList;
  List<SoldToCodeSummaryDto>? salesOrderFormValueList;
  List<SoldToCodeSummaryDto>? shipToCodeList;
  List<SoldToCodeSummaryDto>? orderTypeList;
  List<SoldToCodeSummaryDto>? shippingConditionList;
  CustomerDetailsDto? bankList;
  ChequeDto? chequeList;
  List<PlantListDto>? plantList;
  List<AssignmentNoDto>? assignmentNoList;
  List<ProductDto>? productList = [];
  String? productType;
  String? bank;
  String? chequeNumber;
  String? assignmentNumber;
  List<String>? tempAssignmentNumberList;
  String? poNumber;
  String? poQuantity;
  String? plantCode;
  String? plantName;
  String? divisionCode;
  String? salesOrganizationCode;
  String? salesOrganizationName;
  String? creditLimitUsedAmount;
  String? creditLimitAvailable;
  String? poDocument;
  String? totalAmountDocCurrency;
  CustomerDetailsDto? existingPoDetails;
  String? salesOrderNumber;
  String? existingPoNumber;
  String? poFileName;
  String? poFileImagePath;
  bool? isExistingRadioSelected;
  String? poQty;
  String? remainingQty;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  OrderCreateFormValue.empty();

  OrderCreateFormValue copyWith({
    String? userRole,
    String? customerType,
    String? shipTo,
    String? shipToName,
    String? soldToCode,
    String? soldToName,
    String? channelCode,
    String? orderType,
    String? shippingCondition,
    String? bank,
    String? chequeNumber,
    String? assignmentNumber,
    List<String>? tempAssignmentNumberList,
    String? poNumber,
    String? poQuantity,
    String? plantCode,
    String? plantName,
    List<DetailDto>? divisionCodeList,
    List<DetailDto>? salesOrgCodeList,
    List<SoldToCodeSummaryDto>? salesOrderFormValueList,
    List<SoldToCodeSummaryDto>? shipToCodeList,
    List<SoldToCodeSummaryDto>? orderTypeList,
    List<SoldToCodeSummaryDto>? shippingConditionList,
    CustomerDetailsDto? bankList,
    ChequeDto? chequeList,
    List<PlantListDto>? plantList,
    List<AssignmentNoDto>? assignmentNoList,
    List<ProductDto?>? productList,
    String? productType,
    String? divisionCode,
    String? salesOrganizationCode,
    String? salesOrganizationName,
    String? creditLimitUsedAmount,
    String? creditLimitAvailable,
    String? poDocument,
    String? totalAmountDocCurrency,
    CustomerDetailsDto? existingPoDetails,
    String? salesOrderNumber,
    String? existingPoNumber,
    String? poFileName,
    String? poFileImagePath,
    bool? isExistingRadioSelected,
    String? poQty,
    String? remainingQty,
    Map<String, String>? errors,
  }) {
    return OrderCreateFormValue.empty()
      ..userRole = userRole ?? this.userRole
      ..customerType = customerType ?? this.customerType
      ..shipTo = shipTo ?? this.shipTo
      ..shipToName = shipToName ?? this.shipToName
      ..soldToCode = soldToCode ?? this.soldToCode
      ..soldToName = soldToName ?? this.soldToName
      ..channelCode = channelCode ?? this.channelCode
      ..orderType = orderType ?? this.orderType
      ..shippingCondition = shippingCondition ?? this.shippingCondition
      ..bank = bank ?? this.bank
      ..chequeNumber = chequeNumber ?? this.chequeNumber
      ..assignmentNumber = assignmentNumber ?? this.assignmentNumber
      ..tempAssignmentNumberList = tempAssignmentNumberList ?? this.tempAssignmentNumberList
      ..poNumber = poNumber ?? this.poNumber
      ..poQuantity = poQuantity ?? this.poQuantity
      ..plantCode = plantCode ?? this.plantCode
      ..plantName = plantName ?? this.plantName
      ..divisionCode = divisionCode ?? this.divisionCode
      ..divisionCodeList = divisionCodeList ?? this.divisionCodeList
      ..salesOrgCodeList = salesOrgCodeList ?? this.salesOrgCodeList
      ..salesOrganizationCode = salesOrganizationCode ?? this.salesOrganizationCode
      ..salesOrganizationName = salesOrganizationName ?? this.salesOrganizationName
      ..creditLimitUsedAmount = creditLimitUsedAmount ?? this.creditLimitUsedAmount
      ..creditLimitAvailable = creditLimitAvailable ?? this.creditLimitAvailable
      ..salesOrderFormValueList = salesOrderFormValueList ?? this.salesOrderFormValueList
      ..shipToCodeList = shipToCodeList ?? this.shipToCodeList
      ..orderTypeList = orderTypeList ?? this.orderTypeList
      ..shippingConditionList = shippingConditionList ?? this.shippingConditionList
      ..bankList = bankList ?? this.bankList
      ..chequeList = chequeList ?? this.chequeList
      ..plantList = plantList ?? this.plantList
      ..assignmentNoList = assignmentNoList ?? this.assignmentNoList
      ..productList = (productList ?? this.productList)?.cast<ProductDto>()
      ..productType = productType ?? this.productType
      ..poDocument = poDocument ?? this.poDocument
      ..totalAmountDocCurrency = totalAmountDocCurrency ?? this.totalAmountDocCurrency
      ..existingPoDetails = existingPoDetails ?? this.existingPoDetails
      ..salesOrderNumber = salesOrderNumber ?? this.salesOrderNumber
      ..existingPoNumber = existingPoNumber ?? this.existingPoNumber
      ..poFileName = poFileName ?? this.poFileName
      ..poFileImagePath = poFileImagePath ?? this.poFileImagePath
      ..isExistingRadioSelected = isExistingRadioSelected ?? this.isExistingRadioSelected
      ..poQty = poQty ?? this.poQty
      ..remainingQty = remainingQty ?? this.remainingQty
      ..errors = errors ?? this.errors;
  }
}

class OrderCreateFormController extends FormController<OrderCreateFormValue> {
  OrderCreateFormController() : super(initialValue: OrderCreateFormValue.empty());

  clear() {
    value = OrderCreateFormValue.empty();
  }

  Future<void> getDivisionCode(String? selectedSoldToCode) async {
    if (selectedSoldToCode != null) {
      CustomerDetailsDto? customerType =
          await locate<RestService>().fetchCustomerDetails(soldToCode: selectedSoldToCode);

      if (customerType != null) {
        value.customerType = customerType.type;
        notifyListeners();
      }
      List<DetailDto>? codeList =
          await locate<RestService>().getCustomerDetailsBySoldToCode(soldToCode: selectedSoldToCode);
      if (codeList != null && codeList.isEmpty == false) {
        value.divisionCodeList = codeList;
        value.salesOrgCodeList = codeList;
        value.divisionCode = codeList.first.divisionCode;
        value.salesOrganizationCode = codeList.first.salesOrgCode;
        value.salesOrganizationName = codeList.first.salesOrgName;
        notifyListeners();
      }
    }
  }

  Future<void> getBankListBySoldToCode(String? selectedSoldToCode) async {
    if (selectedSoldToCode != null) {
      CustomerDetailsDto? bankList = await locate<RestService>().fetchCustomerDetails(soldToCode: selectedSoldToCode);
      if (bankList != null) {
        value.bankList = bankList;
      }
    }
  }

  Future<void> getCustomerDetails(String? selectedSoldToCode) async {
    if (selectedSoldToCode != null) {
      CustomerDetailsDto? existingPo = await locate<RestService>().fetchCustomerDetails(soldToCode: selectedSoldToCode);
      if (existingPo != null) {
        value.existingPoDetails = existingPo;
        value.customerType = existingPo.type;
      }
    }
  }

  Future<void> getChequeByBank() async {
    final String? soldToCode = value.soldToCode;
    final String? bankKey = value.bank;
    final String? bankCountry;
    late int currentChequeNumber; // Declare as int
    late int nextChequeNumber; // Declare as int

    if (bankKey != null && bankKey.length >= 2) {
      bankCountry = bankKey.substring(0, 2);
    } else {
      // Handle the case when bankKey is null or doesn't have at least 2 characters.
      // You can set a default value or handle it in your own way.
      bankCountry = 'LK'; // Change 'Default' to your desired default value.
    }

    ChequeDto? chequeList = await locate<RestService>()
        .getCheque(bankCountry: bankCountry, customerCode: soldToCode!, bankNumber: bankKey!);
    if (chequeList != null) {
      value.chequeList = chequeList;

      // Handle the case when lastChequeNumber is a string
      if (chequeList!.lastChequeNumber is String) {
        currentChequeNumber = int.tryParse(chequeList.lastChequeNumber) ?? 0;
      } else {
        // Handle the case when lastChequeNumber is an int
        currentChequeNumber = chequeList.lastChequeNumber ?? 0;
      }

      nextChequeNumber = currentChequeNumber + 1;
      value.chequeNumber = "00${nextChequeNumber.toString()}";
    }
  }

  Future<void> fetchQueryCreditAvailabilityReport() async {
    final String? soldToCode = value.soldToCode;
    final String? companyCode = value.salesOrganizationCode;
    final data = await locate<RestService>().getQueryCreditAvailabilityReport(
      customerCode: soldToCode!,
      companyCode: companyCode!,
    );
    if (data != null && data?.isEmpty == false) {
      setValue(value.copyWith(
        creditLimitUsedAmount: data?.first.creditLimitUsedAmount.toString() ?? "0.00",
        creditLimitAvailable: data?.first.CreditLimitAvailable.toString() ?? "0.00",
      ));
      value.creditLimitUsedAmount = data?.first.creditLimitUsedAmount.toString() ?? "0.00";
      value.creditLimitAvailable = data?.first.CreditLimitAvailable.toString() ?? "0.00";
      notifyListeners();
    }
  }

  Future<void> fetchSalesOrderFormValueList() async {
    final String? soldToCode = value.soldToCode;
    final String? salesOrgCode = value.salesOrganizationCode;
    final String? divisionCode = value.divisionCode;
    List<String> filteredShippingTypeList = [];
    final data = await locate<RestService>()
        .getSoldToCodeSummary(soldToCode: soldToCode!, divisionCode: divisionCode!, salesOrgCode: salesOrgCode!);
    if (data != null && data?.isEmpty == false) {
      value.shipToCodeList = data;
      value.orderTypeList = data;
      value.shippingConditionList = data;
      if (value.orderTypeList != null) {
        final orderTypeList = value.orderTypeList!.expand((orderType) => orderType.orderTypes!).toSet().toList();
        if (value.shippingConditionList != null) {
          final shippingTypeList =
              value.shippingConditionList!.expand((shippingType) => shippingType.shippingConditions!).toSet().toList();
          if (shippingTypeList != null && shippingTypeList?.isEmpty == false) {
            filteredShippingTypeList = shippingTypeList
                .where((type) => type.trim().isNotEmpty && (type == "PICKUP" || type == "DELIVERED"))
                .toList();
          }
          setValue(value.copyWith(
            shipTo: value.shipToCodeList!.first.shipToCode,
            shipToName: value.shipToCodeList!.first.shipToName,
            channelCode: value.shipToCodeList!.first.channelCode,
            orderType: orderTypeList.first,
            shippingCondition: filteredShippingTypeList.isNotEmpty ? filteredShippingTypeList.first : null,
          ));

          final plantData = await locate<RestService>().getAvailablePlants(
            divisionCode: divisionCode,
            salesOrgCode: salesOrgCode,
            shippingCondition: filteredShippingTypeList.isNotEmpty ? filteredShippingTypeList.first : "",
            distributionChannelCode: value.shipToCodeList?.first.channelCode ?? "",
            shipToCode: value.shipToCodeList?.first.shipToCode ?? "",
          );
          if (plantData != null || plantData?.isEmpty == false) {
            value.plantList = plantData;
          }
          notifyListeners();
        }
      }
    }
  }

  Future<void> getPlantBySelectedValues() async {
    final String? shipToCode = value.shipTo;
    final String? salesOrgCode = value.salesOrganizationCode;
    final String? divisionCode = value.divisionCode;
    final String? shippingCondition = value.shippingCondition;
    final String? distributionChannelCode = value.channelCode;

    final data = await locate<RestService>().getAvailablePlants(
        divisionCode: divisionCode ?? "",
        salesOrgCode: salesOrgCode ?? "",
        shippingCondition: shippingCondition ?? "",
        distributionChannelCode: distributionChannelCode ?? "",
        shipToCode: shipToCode ?? "");
    if (data != null || data?.isEmpty == false) {
      value.plantList = data;
    }
  }

  Future<void> fetchAssignmentNumberList() async {
    final String? soldToCode = value.soldToCode;
    final String? salesOrgCode = value.salesOrganizationCode;
    final String openAtKeydays = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final data = await locate<RestService>()
        .getAssignmentNoList(customerCode: soldToCode!, companyCode: salesOrgCode!, openatKeydays: openAtKeydays);
    if (data != null || data?.isEmpty == false) {
      value.assignmentNoList = data;
    }
  }

  Future<void> fetchProductByPlant() async {
    final String? shipToCode = value.shipTo;
    final String? salesOrgCode = value.salesOrganizationCode;
    final String? divisionCode = value.divisionCode;
    final String? shippingCondition = value.shippingCondition;
    final String? distributionChannelCode = value.channelCode;
    final String? plantCode = value.plantCode;

    final data = await locate<RestService>().getProductsByPlant(
        plantCode: plantCode ?? "",
        divisionCode: divisionCode ?? '',
        salesOrgCode: salesOrgCode ?? '',
        shippingCondition: shippingCondition ?? '',
        distributionChannelCode: distributionChannelCode ?? '',
        shipToCode: shipToCode ?? '');
    if (data != null || data?.isEmpty == false) {
      value.productList = data;
    }
  }
}

class OrderCreateRetailCreditView extends StatefulWidget {
  final OrderCreateFormController controller;
  const OrderCreateRetailCreditView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<OrderCreateRetailCreditView> createState() => _OrderCreateRetailCreditViewState();
}

class _OrderCreateRetailCreditViewState extends State<OrderCreateRetailCreditView> {
  late Future<UserResponseDto?> action;
  String? creditLimitUsedAmount;
  String? creditLimitAvailable;
  List<SoldToCodeSummaryDto>? shipToCodeList;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() {
    setState(() {
      action = () async {
        try {
          Storage storage = Storage();
          String? email = await storage.readValue("email");
          final data = await locate<RestService>().getUserByEmail(email!);
          widget.controller.setValue(widget.controller.value.copyWith(
            userRole: data?.roles?.first.roleName,
            soldToCode: data?.customers?.first.soldToCode,
          ));

          CustomerDetailsDto? customerType =
              await locate<RestService>().fetchCustomerDetails(soldToCode: data!.customers?.first.soldToCode! ?? "");

          if (customerType != null) {
            widget.controller.setValue(widget.controller.value.copyWith(
              customerType: customerType.type,
              existingPoDetails: customerType
            ));
          }
          List<DetailDto>? codeList =
              await locate<RestService>().getCustomerDetailsBySoldToCode(soldToCode: data!.customers?.first.soldToCode! ?? "");
          if (codeList != null && codeList.isNotEmpty) {
            widget.controller.setValue(widget.controller.value.copyWith(
              divisionCodeList: codeList.isNotEmpty ? codeList : null,
              salesOrgCodeList: codeList.isNotEmpty ? codeList : null,
            ));

            final queryData = await locate<RestService>().getQueryCreditAvailabilityReport(
              customerCode: data.customers?.first.soldToCode ?? "",
              companyCode: codeList.first.salesOrgCode?.isNotEmpty == true ? codeList.first.salesOrgCode ?? "" : "",
            );

            if (queryData != null && queryData.isNotEmpty) {
              creditLimitUsedAmount = queryData.first.creditLimitUsedAmount.toString();
              creditLimitAvailable = queryData.first.CreditLimitAvailable.toString();
            }
          }

          final formFieldData = await locate<RestService>().getSoldToCodeSummary(
            soldToCode: data.customers?.first.soldToCode ?? "",
            divisionCode: codeList?.first.divisionCode?.isNotEmpty == true ? codeList?.first.divisionCode ?? "" : "",
            salesOrgCode: codeList?.first.divisionCode?.isNotEmpty == true ? codeList?.first.salesOrgCode ?? "" : "",
          );

          if (formFieldData != null && formFieldData.isNotEmpty) {
            shipToCodeList = formFieldData.isNotEmpty ? formFieldData : null;
            widget.controller.setValue(widget.controller.value.copyWith(
              shipToCodeList: formFieldData.isNotEmpty ? formFieldData : null,
              orderTypeList: formFieldData.isNotEmpty ? formFieldData : null,
              shippingConditionList: formFieldData.isNotEmpty ? formFieldData : null,
            ));
          }

          CustomerDetailsDto? bankList =
              await locate<RestService>().fetchCustomerDetails(soldToCode: data.customers?.first.soldToCode! ?? "");

          if (bankList != null) {
            widget.controller.setValue(widget.controller.value.copyWith(
              bankList: bankList,
            ));
          }

          final shippingTypeList = widget.controller.value.shippingConditionList
                  ?.expand((shippingType) => shippingType.shippingConditions!)
                  .toSet()
                  .toList() ??
              [];

          final filteredShippingTypeList = shippingTypeList
                  ?.where((type) => type.trim().isNotEmpty && (type == "PICKUP" || type == "DELIVERED"))
                  .toList() ??
              [];

          final assignmentNoData = await locate<RestService>().getAssignmentNoList(
              customerCode: data.customers?.first.soldToCode ?? "",
              companyCode: codeList!.first.salesOrgCode?.isNotEmpty == true ? codeList!.first.salesOrgCode ?? "" : "",
              openatKeydays: DateFormat('yyyy-MM-dd').format(DateTime.now()));

          if (assignmentNoData != null && assignmentNoData.isNotEmpty) {
            widget.controller.setValue(widget.controller.value.copyWith(
              assignmentNoList: assignmentNoData.isNotEmpty ? assignmentNoData : null,
            ));
          }

          final orderTypeList =
              widget.controller.value.orderTypeList?.expand((orderType) => orderType.orderTypes!).toSet().toList();

          final plantData = await locate<RestService>().getAvailablePlants(
              divisionCode: codeList?.first.divisionCode?.isNotEmpty == true ? codeList?.first.divisionCode ?? "" : "",
              salesOrgCode: codeList?.first.salesOrgCode?.isNotEmpty == true ? codeList?.first.salesOrgCode ?? "" : "",
              shippingCondition: filteredShippingTypeList.isNotEmpty ? filteredShippingTypeList.first : "",
              distributionChannelCode: shipToCodeList?.first.channelCode ?? "",
              shipToCode: shipToCodeList?.first.shipToCode ?? "");
          if (plantData != null && plantData.isNotEmpty) {
            widget.controller.setValue(widget.controller.value.copyWith(
              plantList: plantData,
            ));
          }
          widget.controller.setValue(widget.controller.value.copyWith(
            soldToCode: data.customers?.first.soldToCode?.isNotEmpty ?? false ? data.customers?.first.soldToCode : null,
            channelCode: codeList?.first.channelCode?.isNotEmpty ?? false ? codeList?.first.channelCode : null,
            salesOrganizationCode:
                codeList?.first.salesOrgCode?.isNotEmpty ?? false ? codeList?.first.salesOrgCode : null,
            divisionCode: codeList?.first.divisionCode?.isNotEmpty ?? false ? codeList?.first.divisionCode : null,
            creditLimitUsedAmount: creditLimitUsedAmount?.isNotEmpty ?? false ? creditLimitUsedAmount : null,
            creditLimitAvailable: creditLimitAvailable?.isNotEmpty ?? false ? creditLimitAvailable : null,
            shipTo: shipToCodeList?.first.shipToCode?.isNotEmpty ?? false ? shipToCodeList?.first.shipToCode : null,
            shipToName: shipToCodeList?.first.shipToName?.isNotEmpty ?? false ? shipToCodeList?.first.shipToName : null,
            orderType: orderTypeList?.first.isNotEmpty ?? false ? orderTypeList?.first : null,
            shippingCondition: filteredShippingTypeList.isNotEmpty ? filteredShippingTypeList.first : null,
          ));
        } catch (e) {
          return null;
        }
      }.call();
    });
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithTM(),
      body: FutureBuilder(
          future: action,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, formValue, _) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 0.7,
                                    child: BackButton(
                                      onPressed: () => GoRouter.of(context).go("/home"),
                                    ),
                                  ),
                                  Text(
                                    "Create Order",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
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
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RetailCreditDivisionCard(controller: widget.controller),
                              RetailCreditOrganizationCard(controller: widget.controller),
                              RetailCreditCustomerCard(controller: widget.controller),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RetailDetailCard(
                                name: "Current Outstanding",
                                size: formValue.creditLimitUsedAmount?.isNotEmpty == true
                                    ? formValue.creditLimitUsedAmount ?? "0.00"
                                    : "0.00",
                                color: const Color(0xFFDB4633),
                              ),
                              RetailDetailCard(
                                name: "Available Credit Balance",
                                size: formValue.creditLimitAvailable?.isNotEmpty == true
                                    ? (formValue.creditLimitAvailable!.startsWith('-')
                                        ? formValue.creditLimitAvailable ?? "0.00"
                                        : "-${formValue.creditLimitAvailable!.substring(0, formValue.creditLimitAvailable!.length - 1)}")
                                    : "0.00",
                                color: const Color(0xFF4A7A36),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (formValue.orderType == "CASH")
                          TotalAssignmentNoCard(
                              name: "Total Assignment Number Value",
                              size: formatAmount(widget.controller.value.totalAmountDocCurrency ?? "0.00"),
                              color: const Color(0xFF3E4954).withOpacity(0.25)),
                        const SizedBox(
                          height: 10,
                        ),
                        RetailCreditDropdownBox(controller: widget.controller),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FilledButton(
                            onPressed: () {
                              if (formValue.customerType == null) {
                                if ((formValue.channelCode == 'AG' ||
                                        formValue.channelCode == 'OT' ||
                                        formValue.channelCode == 'DC') &&
                                    (formValue.poNumber == null && formValue.orderType == "CREDIT")) {
                                  locate<PopupController>().addItemFor(
                                    DismissiblePopup(
                                      title: "All fields are required",
                                      subtitle: "Please fill all the fields",
                                      color: Colors.red,
                                      onDismiss: (self) => locate<PopupController>().removeItem(self),
                                    ),
                                    const Duration(seconds: 5),
                                  );
                                  return;
                                }
                              }

                              if ((formValue.shippingCondition != null &&
                                          formValue.orderType != null &&
                                          formValue.plantCode != null &&
                                          formValue.soldToCode != null &&
                                          formValue.divisionCode != null &&
                                          formValue.salesOrganizationCode != null &&
                                          formValue.shipTo != null) &&
                                      ((formValue.channelCode == 'AG' ||
                                              formValue.channelCode == 'OT' ||
                                              formValue.channelCode == 'DC') &&
                                          (formValue.customerType == 'DIRECT_DEBIT' ||
                                              formValue.customerType == null &&
                                                  (formValue.bank != null ||
                                                      formValue.tempAssignmentNumberList != null))) ||
                                  ((formValue.channelCode == 'CO' ||
                                              formValue.channelCode == 'CP' ||
                                              formValue.channelCode == "DI" ||
                                              formValue.channelCode == "SM") &&
                                          (formValue.poFileName != null && formValue.poNumber != null &&
                                              formValue.plantCode != null) ||
                                      (formValue.channelCode == 'CO' ||
                                              formValue.channelCode == 'CP' ||
                                              formValue.channelCode == "DI" ||
                                              formValue.channelCode == "SM") &&
                                          (formValue.poFileName != null && formValue.existingPoNumber != null &&
                                              formValue.plantCode != null) ||
                                      (formValue.channelCode == 'CO' ||
                                              formValue.channelCode == 'CP' ||
                                              formValue.channelCode == "DI" ||
                                              formValue.channelCode == "SM") &&
                                          (formValue.tempAssignmentNumberList != null &&
                                              formValue.poFileName != null &&
                                              formValue.plantCode != null))) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AvailableProduct(controller: widget.controller),
                                  ),
                                );
                              } else {
                                locate<PopupController>().addItemFor(
                                  DismissiblePopup(
                                    title: "All fields are required",
                                    subtitle: "Please fill all the fields",
                                    color: Colors.red,
                                    onDismiss: (self) => locate<PopupController>().removeItem(self),
                                  ),
                                  const Duration(seconds: 5),
                                );
                              }
                            },
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
                    );
                  }),
            );
          }),
    );
  }
}

class RetailCreditCustomerCard extends StatefulWidget {
  final OrderCreateFormController controller;
  const RetailCreditCustomerCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RetailCreditCustomerCard> createState() => _RetailCreditCustomerCardState();
}

class _RetailCreditCustomerCardState extends State<RetailCreditCustomerCard> {
  late Future<UserResponseDto?> action;
  UserResponseDto? customerList;
  UserResponseDto? user;

  @override
  void initState() {
    fetchCustomer();
    super.initState();
  }

  fetchCustomer() {
    setState(() {
      action = () async {
        Storage storage = Storage();
        String? email = await storage.readValue("email");
        final data = await locate<RestService>().getUserByEmail(email!);
        customerList = data;
        user = data;
      }.call();
    });
  }

  void showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, formValue, child) {
              return AlertDialog(
                title: Text(
                  "Search Customer",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                content: SizedBox(
                  height: 120,
                  child: Column(
                    children: [
                      CustomerSearchCard(controller: widget.controller),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                height: (formValue.userRole == "Customer Admin" ||
                        formValue.userRole == "Customer User" ||
                        formValue.userRole == "B2B Sales User/AM")
                    ? 40
                    : 70,
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
                            if (formValue.userRole == "Call Center User" ||
                                formValue.userRole == "Retail Sales User" ||
                                formValue.userRole == "Business Administrator" ||
                                formValue.userRole == "Commercial User" ||
                                formValue.userRole == "Logistics Other" ||
                                formValue.userRole == "DPMC User" ||
                                formValue.userRole == "IT Administrator" ||
                                formValue.userRole == "Super Admin")
                              GestureDetector(
                                onTap: () {
                                  showSelectionDialog(context);
                                },
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    formValue.soldToCode != null ? formValue.soldToCode! : "Select a Customer",
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                      color: formValue.soldToCode != null ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            if (formValue.userRole == "Customer Admin" ||
                                formValue.userRole == "Customer User" ||
                                formValue.userRole == "B2B Sales User/AM")
                              PopupMenuButton<String>(
                                offset: const Offset(0, 30),
                                child: FittedBox(
                                  child: Text(
                                    formValue.soldToCode != null ? formValue.soldToCode! : "Select a Customer",
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                      color: formValue.soldToCode != null ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                                onSelected: (value) async {
                                  widget.controller.setValue(
                                    widget.controller.value..soldToCode = value,
                                  );
                                  locate<LoadingIndicatorController>().show();
                                  if (formValue.soldToCode != null) {
                                    await widget.controller.getDivisionCode(value);
                                    await widget.controller.getBankListBySoldToCode(value);
                                    await widget.controller.getCustomerDetails(value);
                                  }
                                  if (formValue.divisionCode != null &&
                                      formValue.soldToCode != null &&
                                      formValue.salesOrganizationCode != null) {
                                    clearSelectedData();
                                    await widget.controller.fetchQueryCreditAvailabilityReport();
                                    await widget.controller.fetchSalesOrderFormValueList();
                                    await widget.controller.fetchAssignmentNumberList();
                                  }
                                  if (formValue.divisionCode != null &&
                                      formValue.salesOrganizationCode != null &&
                                      formValue.shipTo != null &&
                                      formValue.channelCode != null &&
                                      formValue.shippingCondition != null) {
                                    await widget.controller.getPlantBySelectedValues();
                                  }
                                  locate<LoadingIndicatorController>().hide();
                                },
                                itemBuilder: (BuildContext context) {
                                  if (customerList?.customers?.isEmpty ?? false || customerList?.customers == null) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: null,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                          child: Text(
                                            'No available Customers',
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                  color: Colors.black54,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ];
                                  } else {
                                    return customerList!.customers?.map((customerList) {
                                      return PopupMenuItem<String>(
                                        value: customerList.soldToCode!,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                          child: Text(
                                            "${customerList.soldToCode!} "
                                            "${customerList.name!} ",
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList() ?? [];
                                  }
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

  // Clear selected customer data
  void clearSelectedData() {
    widget.controller.setValue(widget.controller.value
      ..shipTo = null
      ..shipToName = null
      ..channelCode = null
      ..orderType = null
      ..shippingCondition = null
      ..bank = null
      ..salesOrderFormValueList = null
      ..bank = null
      ..chequeNumber = null
      ..poNumber = null
      ..assignmentNoList = null
      ..assignmentNumber = null
      ..tempAssignmentNumberList = null
      ..plantCode = null
      ..plantName = null
      ..creditLimitAvailable = null
      ..creditLimitUsedAmount = null
      ..salesOrderNumber = null
      ..totalAmountDocCurrency = null
      ..poDocument = null
      ..poFileImagePath = null
      ..poFileName = null);
  }
}

class RetailCreditDivisionCard extends StatefulWidget {
  final OrderCreateFormController controller;
  const RetailCreditDivisionCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RetailCreditDivisionCard> createState() => _RetailCreditDivisionCardState();
}

class _RetailCreditDivisionCardState extends State<RetailCreditDivisionCard> {
  Set<String> uniqueDivisionCodes = {};
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerValueChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerValueChange);
    super.dispose();
  }

  void _handleControllerValueChange() {
    uniqueDivisionCodes.clear();
  }

  @override
  Widget build(BuildContext context) {
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
                height: (formValue.userRole == "Customer Admin" ||
                        formValue.userRole == "Customer User" ||
                        formValue.userRole == "B2B Sales User/AM")
                    ? 40
                    : 70,
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
                              offset: const Offset(0, 30),
                              child: FittedBox(
                                child: Text(
                                  formValue.divisionCode != null ? formValue.divisionCode! : "Select a Division",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: formValue.divisionCode != null ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (value) async {
                                widget.controller.setValue(
                                  widget.controller.value..divisionCode = value,
                                );
                                locate<LoadingIndicatorController>().show();
                                if (formValue.divisionCode != null &&
                                    formValue.soldToCode != null &&
                                    formValue.salesOrganizationCode != null) {
                                  clearSelectedData();
                                  await widget.controller.fetchQueryCreditAvailabilityReport();
                                  await widget.controller.fetchSalesOrderFormValueList();
                                  await widget.controller.fetchAssignmentNumberList();
                                }
                                if (formValue.divisionCode != null &&
                                    formValue.salesOrganizationCode != null &&
                                    formValue.shipTo != null &&
                                    formValue.channelCode != null &&
                                    formValue.shippingCondition != null) {
                                  await widget.controller.getPlantBySelectedValues();
                                }
                                locate<LoadingIndicatorController>().hide();
                              },
                              itemBuilder: (BuildContext context) {
                                List<DetailDto>? divisionList = formValue.divisionCodeList;
                                if (divisionList != null) {
                                  divisionList = divisionList.where((dto) {
                                    bool isUnique = uniqueDivisionCodes.add(dto.divisionCode!);
                                    return isUnique;
                                  }).toList();
                                }
                                if (divisionList?.isEmpty ?? false || divisionList == null) {
                                  return [
                                    PopupMenuItem<String>(
                                      value: null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                        child: Text(
                                          'No available Divisions',
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                color: Colors.black54,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ];
                                } else {
                                  return (divisionList ?? []).map((detailsList) {
                                    return PopupMenuItem<String>(
                                      value: detailsList.divisionName,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: Text(
                                          detailsList.divisionName!,
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                }
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

  // Clear selected customer data
  void clearSelectedData() {
    widget.controller.setValue(widget.controller.value
      ..shipTo = null
      ..shipToName = null
      ..channelCode = null
      ..orderType = null
      ..shippingCondition = null
      ..bank = null
      ..salesOrderFormValueList = null
      ..bank = null
      ..chequeNumber = null
      ..poNumber = null
      ..assignmentNoList = null
      ..assignmentNumber = null
      ..tempAssignmentNumberList = null
      ..plantCode = null
      ..plantName = null
      ..creditLimitAvailable = null
      ..creditLimitUsedAmount = null
      ..salesOrderNumber = null
      ..totalAmountDocCurrency = null
      ..poDocument = null
      ..poFileImagePath = null
      ..poFileName = null);
  }
}

class RetailCreditOrganizationCard extends StatefulWidget {
  final OrderCreateFormController controller;
  const RetailCreditOrganizationCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RetailCreditOrganizationCard> createState() => _RetailCreditOrganizationCardState();
}

class _RetailCreditOrganizationCardState extends State<RetailCreditOrganizationCard> {
  Set<String> uniqueSalesOrgCodes = {};
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerValueChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerValueChange);
    super.dispose();
  }

  void _handleControllerValueChange() {
    uniqueSalesOrgCodes.clear();
  }

  @override
  Widget build(BuildContext context) {
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
                height: (formValue.userRole == "Customer Admin" ||
                        formValue.userRole == "Customer User" ||
                        formValue.userRole == "B2B Sales User/AM")
                    ? 40
                    : 70,
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
                              offset: const Offset(0, 30),
                              child: FittedBox(
                                child: Text(
                                  formValue.salesOrganizationCode != null
                                      ? formValue.salesOrganizationCode!
                                      : "Select a Organization",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: formValue.salesOrganizationCode != null ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (value) async {
                                widget.controller.setValue(
                                  widget.controller.value..salesOrganizationCode = value,
                                );
                                locate<LoadingIndicatorController>().show();
                                if (formValue.divisionCode != null &&
                                    formValue.soldToCode != null &&
                                    formValue.salesOrganizationCode != null) {
                                  clearSelectedData();
                                  await widget.controller.fetchQueryCreditAvailabilityReport();
                                  await widget.controller.fetchSalesOrderFormValueList();
                                  await widget.controller.fetchAssignmentNumberList();
                                }
                                if (formValue.divisionCode != null &&
                                    formValue.shipTo != null &&
                                    formValue.salesOrganizationCode != null &&
                                    formValue.channelCode != null &&
                                    formValue.shippingCondition != null) {
                                  await widget.controller.getPlantBySelectedValues();
                                }
                                locate<LoadingIndicatorController>().hide();
                              },
                              itemBuilder: (BuildContext context) {
                                List<DetailDto>? salesOrgCodeList = formValue.salesOrgCodeList;
                                if (salesOrgCodeList != null) {
                                  salesOrgCodeList = salesOrgCodeList.where((dto) {
                                    bool isUnique = uniqueSalesOrgCodes.add(dto.salesOrgCode!);
                                    return isUnique;
                                  }).toList();
                                }
                                if (salesOrgCodeList?.isEmpty ?? false || salesOrgCodeList == null) {
                                  return [
                                    PopupMenuItem<String>(
                                      value: null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                        child: Text(
                                          'No available Organizations',
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                color: Colors.black54,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ];
                                } else {
                                  return (salesOrgCodeList ?? []).map((detailsList) {
                                    return PopupMenuItem<String>(
                                      value: detailsList.salesOrgCode,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: Text(
                                          ("${detailsList.salesOrgCode!} ${detailsList.salesOrgName!}"),
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                }
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

  // Clear selected customer data
  void clearSelectedData() {
    widget.controller.setValue(widget.controller.value
      ..shipTo = null
      ..shipToName = null
      ..channelCode = null
      ..orderType = null
      ..shippingCondition = null
      ..bank = null
      ..salesOrderFormValueList = null
      ..bank = null
      ..chequeNumber = null
      ..poNumber = null
      ..assignmentNoList = null
      ..assignmentNumber = null
      ..tempAssignmentNumberList = null
      ..plantCode = null
      ..plantName = null
      ..creditLimitAvailable = null
      ..creditLimitUsedAmount = null
      ..salesOrderNumber = null
      ..totalAmountDocCurrency = null
      ..poDocument = null
      ..poFileImagePath = null
      ..poFileName = null);
  }
}

class RetailDetailCard extends StatelessWidget {
  const RetailDetailCard({
    Key? key,
    required this.name,
    required this.size,
    required this.color,
  }) : super(key: key);

  final String name;
  final String size;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
        // color: widget.color,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 3,
        child: Container(
          height: 60.0,
          width: 140,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (name == "Current Outstanding")
                  const Icon(
                    Icons.stacked_line_chart,
                    color: Colors.white,
                    size: 24,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "$size LKR",
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (name == "Available Credit Balance")
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFFFFFFF),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TotalAssignmentNoCard extends StatelessWidget {
  const TotalAssignmentNoCard({
    Key? key,
    required this.name,
    required this.size,
    required this.color,
  }) : super(key: key);

  final String name;
  final String size;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
        // color: widget.color,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 3,
        child: Container(
          height: 60.0,
          width: 300,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.asset(
                      "assets/images/dashboard/bill.png",
                      color: Colors.black,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "$size LKR",
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RetailCreditDropdownBox extends StatefulWidget {
  final OrderCreateFormController controller;
  const RetailCreditDropdownBox({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<RetailCreditDropdownBox> createState() => _RetailCreditDropdownBoxState();
}

class _RetailCreditDropdownBoxState extends State<RetailCreditDropdownBox> {
  TextEditingController chequeNumberController = TextEditingController();
  TextEditingController poNumberController = TextEditingController();
  TextEditingController salesOrderNumberController = TextEditingController();

  late List<AssignmentNoDto>? assignmentNoList = [];
  List<String> selectedAssignmentsList = [];
  Set<String> uniqueOrderTypes = {};
  Set<String> uniqueShippingConditions = {};
  List<String> extensions = ["jpg", "jpeg", "png", "pdf"];
  String selectedOption = 'new';
  bool isExistingRadioSelected = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerValueChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerValueChange);
    super.dispose();
  }

  void _handleControllerValueChange() {
    setState(() {});
    uniqueOrderTypes.clear();
    uniqueShippingConditions.clear();
  }

  void _showSelectionDialog(BuildContext context) {
    if (widget.controller.value.assignmentNoList == null || widget.controller.value.assignmentNoList!.isEmpty) {
      // Handle the case where assignmentNoList is null or empty
      // You can show an appropriate message or take other actions
      return;
    }
    widget.controller.value.tempAssignmentNumberList = List.from(selectedAssignmentsList);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Assignment Number'),
              content: SingleChildScrollView(
                child: Column(
                  children: widget.controller.value.assignmentNoList!.map((assignment) {
                    final isSelected =
                        widget.controller.value.tempAssignmentNumberList?.contains(assignment.assignment) ?? false;
                    if (widget.controller.value.assignmentNoList!.isEmpty) {
                      return const Text("No Assignment Numbers");
                    } else {
                      return CheckboxListTile(
                        title: Text("${assignment.assignment} - ${assignment.amountDocCurrency}"),
                        checkColor: Colors.white,
                        activeColor: Colors.red,
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              widget.controller.value.tempAssignmentNumberList ??= [];
                              if (value) {
                                if (!widget.controller.value.tempAssignmentNumberList!
                                    .contains(assignment.assignment!)) {
                                  widget.controller.value.tempAssignmentNumberList!.add(assignment.assignment!);
                                }
                              } else {
                                widget.controller.value.tempAssignmentNumberList!.remove(assignment.assignment!);
                              }

                              if (widget.controller.value.tempAssignmentNumberList!.isEmpty) {
                                widget.controller.value.tempAssignmentNumberList = null;
                              }
                            }
                            widget.controller.getPlantBySelectedValues();
                          });
                        },
                      );
                    }
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedAssignmentsList =
                          List.from(widget.controller.value.tempAssignmentNumberList?.toList() ?? []);
                      // Calculate the total amount for selected values in tempAssignmentNumberList
                      double totalAmount = 0.0;
                      for (var assignment in widget.controller.value.assignmentNoList ?? []) {
                        if (widget.controller.value.tempAssignmentNumberList?.contains(assignment.assignment) ??
                            false) {
                          // Remove trailing hyphen and attempt to parse the amountDocCurrency as a double
                          String cleanAmountString = assignment.amountDocCurrency!.replaceAll('-', '');
                          double amount = double.parse(cleanAmountString);

                          // Check if the original amountDocCurrency had a trailing hyphen and adjust the sign
                          if (assignment.amountDocCurrency!.endsWith('-')) {
                            amount *= -1;
                          }

                          totalAmount += amount;
                        }
                      }
                      totalAmount = totalAmount.abs();
                      // Update the form value
                      widget.controller.value = widget.controller.value.copyWith(
                        totalAmountDocCurrency: totalAmount.toString(),
                      );
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  handleUpload(Source source) async {
    late File? file;
    try {
      locate<LoadingIndicatorController>().show();

      file = await pickFile(source, extensions: extensions);
      if (file == null) return null;

      String fileExtension = extension(file.path);
      if (!extensions.any((ext) => ext == fileExtension.substring(1))) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Extension is not supported",
            subtitle: "Extension: $fileExtension is not supported",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      if (file.lengthSync() > 5e+6) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "File is too large",
            subtitle: "File size is larger than 5MB",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      final result = await locate<RestService>().fileUpload(await fileToBase64(file));
      if (result == null) throw Exception();

      /// Get full image url from file name
      String path = await locate<RestService>().getFullFilePath(result);
      widget.controller.setValue(widget.controller.value.copyWith(
        poFileImagePath: path,
        poDocument: result,
        poFileName: result,
      ));
    } catch (error) {
      rethrow;
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  void removeFile() {
    setState(() {
      widget.controller.value.poFileImagePath = null;
      widget.controller.value.poFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                if (selectedOption == "existing")
                  TextField(
                    controller: salesOrderNumberController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "Sales Order Number",
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..salesOrderNumber = value,
                    ),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                if (selectedOption == "existing")
                  const SizedBox(
                    height: 25,
                  ),
                PopupMenuButton<ShipToData>(
                  offset: const Offset(0, 20),
                  enabled: !isExistingRadioSelected,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formValue.shipTo != null
                                ? (() {
                                    final fullText =
                                        "${formValue.channelCode!} ${formValue.shipTo!} ${formValue.shipToName!}";
                                    return fullText.length > 28 ? '${fullText.substring(0, 28)}...' : fullText;
                                  })()
                                : "ShipTo",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: formValue.shipTo != null ? Colors.black : Colors.black54,
                                ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  onSelected: (ShipToData shipToData) async {
                    widget.controller.setValue(
                      widget.controller.value..shipTo = shipToData.shipTo,
                    );
                    widget.controller.setValue(
                      widget.controller.value..shipToName = shipToData.shipToName,
                    );
                    widget.controller.setValue(
                      widget.controller.value..channelCode = shipToData.channelCode,
                    );
                    // Reset plant-related values
                    widget.controller.setValue(
                      widget.controller.value
                        ..plantCode = null
                        ..plantName = null,
                    );
                    if (formValue.divisionCode != null &&
                        formValue.shipTo != null &&
                        formValue.salesOrganizationCode != null &&
                        formValue.channelCode != null &&
                        formValue.shippingCondition != null) {
                      await widget.controller.getPlantBySelectedValues();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (formValue.shipToCodeList?.isEmpty ?? false || formValue.shipToCodeList == null) {
                      return [
                        PopupMenuItem<ShipToData>(
                          value: ShipToData(
                            shipTo: null,
                            shipToName: null,
                            channelCode: null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                            child: Text(
                              'No available ShipToCode',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ),
                        ),
                      ];
                    } else {
                      return [
                        if (formValue.shipToCodeList != null)
                          ...formValue.shipToCodeList!.map((shipTo) {
                            return PopupMenuItem<ShipToData>(
                              value: ShipToData(
                                shipTo: shipTo.shipToCode,
                                shipToName: shipTo.shipToName,
                                channelCode: shipTo.channelCode,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                child: Text(
                                  ("${shipTo.channelCode ?? ''} ${shipTo.shipToCode ?? ''} ${shipTo.shipToName ?? ''}"),
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: const Color(0xFF000000),
                                      ),
                                ),
                              ),
                            );
                          }),
                      ];
                    }
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 20),
                  enabled: !isExistingRadioSelected,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formValue.orderType != null ? formValue.orderType! : "Order Type",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: formValue.orderType != null ? Colors.black : Colors.black54,
                                ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Add a dropdown icon
                        ],
                      ),
                    ),
                  ),
                  onSelected: (value) async {
                    widget.controller.setValue(
                      widget.controller.value..orderType = value,
                    );
                    if (formValue.divisionCode != null &&
                        formValue.shipTo != null &&
                        formValue.salesOrganizationCode != null &&
                        formValue.channelCode != null &&
                        formValue.shippingCondition != null) {
                      await widget.controller.getPlantBySelectedValues();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (formValue.orderTypeList
                            ?.expand((orderType) => orderType.orderTypes!)
                            .toSet()
                            .toList()
                            .isEmpty ??
                        false) {
                      return [
                        PopupMenuItem<String>(
                          value: null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                            child: Text(
                              'No available Order Types',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ),
                        ),
                      ];
                    } else {
                      return [
                        if (formValue.orderTypeList != null)
                          ...formValue.orderTypeList!
                              .expand((orderType) => orderType.orderTypes!)
                              .toSet()
                              .toList()
                              .map((currentOrderType) {
                            return PopupMenuItem<String>(
                              value: currentOrderType,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                child: Text(
                                  currentOrderType,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: const Color(0xFF000000),
                                      ),
                                ),
                              ),
                            );
                          }),
                      ];
                    }
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 20),
                  enabled: !isExistingRadioSelected,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formValue.shippingConditionList
                                        ?.expand((shippingType) => shippingType.shippingConditions!)
                                        .toSet()
                                        .toList()
                                        .isNotEmpty ??
                                    false
                                ? formValue.shippingCondition ?? "Shipping Condition"
                                : "Shipping Condition",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: formValue.shippingConditionList
                                              ?.expand((shippingType) => shippingType.shippingConditions!)
                                              .toSet()
                                              .toList()
                                              .isNotEmpty ??
                                          false
                                      ? Colors.black
                                      : Colors.black54,
                                ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Add a dropdown icon
                        ],
                      ),
                    ),
                  ),
                  onSelected: (value) async {
                    widget.controller.setValue(
                      widget.controller.value..shippingCondition = value,
                    );
                    if (formValue.divisionCode != null &&
                        formValue.salesOrganizationCode != null &&
                        formValue.shipTo != null &&
                        formValue.channelCode != null &&
                        formValue.shippingCondition != null) {
                      await widget.controller.getPlantBySelectedValues();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (formValue.shippingConditionList
                            ?.expand((shippingType) => shippingType.shippingConditions!)
                            .toSet()
                            .toList()
                            .isEmpty ??
                        false) {
                      return [
                        PopupMenuItem<String>(
                          value: null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                            child: Text(
                              'No available Shipping Types',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ),
                        ),
                      ];
                    } else {
                      // Show the list of shipping types
                      return formValue.shippingConditionList
                              ?.expand((shippingType) => shippingType.shippingConditions!)
                              .toSet()
                              .toList()
                              .map((currentShippingType) {
                            return PopupMenuItem<String>(
                              value: currentShippingType,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                child: Text(
                                  currentShippingType,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: const Color(0xFF000000),
                                      ),
                                ),
                              ),
                            );
                          }).toList() ??
                          [];
                    }
                  },
                ),
                if ((formValue.channelCode == 'AG' || formValue.channelCode == 'OT' || formValue.channelCode == 'DC') &&
                    (formValue.customerType == "CHEQUE"))
                  const SizedBox(
                    height: 25,
                  ),
                if (formValue.orderType == 'CREDIT' &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM'))
                  const SizedBox(height: 25),
                if ((formValue.channelCode == 'CP' || formValue.channelCode == 'OT' || formValue.channelCode == 'DC') &&
                    (formValue.orderType == 'CREDIT') &&
                    (formValue.customerType != "DIRECT_DEBIT" && formValue.customerType != null))
                  const SizedBox(
                    height: 25,
                  ),
                if ((formValue.orderType == 'CREDIT' || formValue.orderType == 'CASH') &&
                    (formValue.customerType != "DIRECT_DEBIT") &&
                    (formValue.customerType == null && formValue.orderType == "CASH"))
                  const SizedBox(
                    height: 25,
                  ),
                if ((formValue.channelCode == 'AG' || formValue.channelCode == 'OT' || formValue.channelCode == 'DC') &&
                    (formValue.orderType == 'CREDIT') &&
                    (formValue.customerType != "DIRECT_DEBIT" && formValue.customerType != null))
                  PopupMenuButton<String>(
                    offset: const Offset(0, 20),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formValue.bank != null ? formValue.bank! : "Bank",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: formValue.bank != null ? Colors.black : Colors.black54,
                                  ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Add a dropdown icon
                          ],
                        ),
                      ),
                    ),
                    onSelected: (value) async {
                      widget.controller.setValue(
                        widget.controller.value..bank = value,
                      );
                      if (formValue.bank != null) {
                        await widget.controller.getChequeByBank();
                        chequeNumberController.text = formValue.chequeNumber ?? "";
                        if (formValue.divisionCode != null &&
                            formValue.shipTo != null &&
                            formValue.salesOrganizationCode != null &&
                            formValue.channelCode != null &&
                            formValue.shippingCondition != null) {
                          await widget.controller.getPlantBySelectedValues();
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      if (formValue.bankList == null || formValue.bankList!.customerBankInfos!.isEmpty) {
                        return [
                          PopupMenuItem<String>(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                              child: Text(
                                'No available Banks',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                            ),
                          ),
                        ];
                      } else {
                        return [
                          if (formValue.bankList != null)
                            ...formValue.bankList!.customerBankInfos!.map((bank) {
                              return PopupMenuItem<String>(
                                value: bank.bankKey,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    ("${bank.bankKey ?? ''} ${bank.bankName ?? ''} ${bank.bankBranch ?? ''}"),
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              );
                            }),
                        ];
                      }
                    },
                  ),
                if (((formValue.channelCode == 'AG' ||
                            formValue.channelCode == 'OT' ||
                            formValue.channelCode == 'DC') &&
                        (formValue.orderType == 'CREDIT')) &&
                    (formValue.customerType != "DIRECT_DEBIT" && formValue.customerType != null))
                  const SizedBox(
                    height: 10,
                  ),
                if (((formValue.channelCode == 'AG' ||
                            formValue.channelCode == 'OT' ||
                            formValue.channelCode == 'DC') &&
                        (formValue.orderType == 'CREDIT')) &&
                    (formValue.customerType != "DIRECT_DEBIT" && formValue.customerType != null))
                  TextField(
                    controller: chequeNumberController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Cheque Number",
                      errorText: formValue.getError("chequeNumber"),
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..chequeNumber = value,
                    ),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                if (formValue.orderType == 'CASH' &&
                    formValue.customerType == "DIRECT_DEBIT")
                  const SizedBox(
                    height: 15,
                  ),
                if (formValue.orderType == 'CASH')
                  ValueListenableBuilder(
                      valueListenable: widget.controller,
                      builder: (BuildContext context, formValue, _) {
                        return InkWell(
                          onTap: () {
                            _showSelectionDialog(context);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.tempAssignmentNumberList?.isNotEmpty ?? false
                                        ? (() {
                                            final fullText = formValue.tempAssignmentNumberList!.join(', ');
                                            return fullText.length > 26 ? '${fullText.substring(0, 26)}...' : fullText;
                                          })()
                                        : "Assignment Number",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: formValue.tempAssignmentNumberList?.isNotEmpty ?? false
                                              ? Colors.black
                                              : Colors.black54,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                if (formValue.orderType == 'CASH' &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM'))
                  const SizedBox(height: 25),
                if ((formValue.channelCode == 'AG' || formValue.channelCode == 'OT' || formValue.channelCode == 'DC'))
                  const SizedBox(height: 25),
                if (formValue.channelCode == null) const SizedBox(height: 25),
                PopupMenuButton<PlantData>(
                  enabled: !isExistingRadioSelected,
                  offset: const Offset(0, 20),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formValue.plantCode != null
                                ? (() {
                                    final fullText = "${formValue.plantCode} ${formValue.plantName}";
                                    return fullText.length > 26 ? '${fullText.substring(0, 26)}...' : fullText;
                                  })()
                                : "Plant",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: formValue.plantCode != null ? Colors.black : Colors.black54,
                                ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Add a dropdown icon
                        ],
                      ),
                    ),
                  ),
                  onSelected: (PlantData plantData) async {
                    widget.controller.setValue(
                      widget.controller.value..plantCode = plantData.plantCode,
                    );
                    widget.controller.setValue(
                      widget.controller.value..plantName = plantData.plantName,
                    );
                    if (formValue.plantCode != null) {
                      await widget.controller.fetchProductByPlant();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (formValue.plantList?.isEmpty ?? false || formValue.plantList == null) {
                      return [
                        PopupMenuItem<PlantData>(
                          value: PlantData(
                            plantCode: null,
                            plantName: null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                            child: Text(
                              'No available Plants',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ),
                        ),
                      ];
                    } else {
                      return [
                        if (formValue.plantList != null)
                          ...formValue.plantList!.map((plant) {
                            return PopupMenuItem<PlantData>(
                              value: PlantData(
                                plantCode: plant.plantCode,
                                plantName: plant.plantName,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                child: Text(
                                  ("${plant.plantCode ?? ''} ${plant.plantName ?? ''}"),
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: const Color(0xFF000000),
                                      ),
                                ),
                              ),
                            );
                          }),
                      ];
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                if ((formValue.channelCode == 'AG' || formValue.channelCode == 'OT' || formValue.channelCode == 'DC') &&
                    (formValue.orderType == 'CREDIT') &&
                    (formValue.customerType == null) && !isExistingRadioSelected)
                  TextField(
                    controller: poNumberController,
                    // readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "PO Number",
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..poNumber = value,
                    ),
                  ),
                if (formValue.orderType == "CREDIT" &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM') || isExistingRadioSelected)
                  Text("PO Number Option",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF000000),
                          )),
                if (formValue.orderType == "CREDIT" &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM') || isExistingRadioSelected)
                  const SizedBox(
                    height: 10,
                  ),
                if (formValue.orderType == "CREDIT" &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM') || isExistingRadioSelected)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 'new';
                        isExistingRadioSelected = false;
                        poNumberController.text = '';
                      });
                      var newValue = widget.controller.value
                        ..isExistingRadioSelected = isExistingRadioSelected
                        ..poFileName = null
                        ..poFileImagePath = null
                        ..existingPoNumber = null
                        ..poNumber = null;

                      widget.controller.setValue(newValue);
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: 'new',
                          activeColor: Colors.red,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value.toString();
                              isExistingRadioSelected = false;
                              poNumberController.text = '';
                            });
                            var newValue = widget.controller.value
                              ..isExistingRadioSelected = isExistingRadioSelected
                              ..poFileName = null
                              ..poFileImagePath = null
                              ..existingPoNumber = null
                              ..poNumber = null;

                            widget.controller.setValue(newValue);
                          },
                        ),
                        Text("New PO",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFF000000),
                                )),
                      ],
                    ),
                  ),
                if (formValue.orderType == "CREDIT" &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM') || isExistingRadioSelected)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 'existing';
                        isExistingRadioSelected = true;
                        salesOrderNumberController.text = '';
                      });
                      var newValue = widget.controller.value
                        ..isExistingRadioSelected = isExistingRadioSelected
                        ..poFileName = null
                        ..poFileImagePath = null
                        ..existingPoNumber = null
                        ..poNumber = null;

                      widget.controller.setValue(newValue);
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: 'existing',
                          activeColor: Colors.red,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value.toString();
                              isExistingRadioSelected = true;
                              salesOrderNumberController.text = '';
                            });
                            var newValue = widget.controller.value
                              ..isExistingRadioSelected = isExistingRadioSelected
                              ..poFileName = null
                              ..poFileImagePath = null
                              ..existingPoNumber = null
                              ..poNumber = null;

                            widget.controller.setValue(newValue);
                          },
                        ),
                        Text("Existing PO",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFF000000),
                                )),
                      ],
                    ),
                  ),
                if ((selectedOption == 'new' && formValue.orderType == "CREDIT") &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM'))
                  TextField(
                    controller: poNumberController,
                    // readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "PO Number",
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..poNumber = value,
                    ),
                  ),
                if (selectedOption == 'existing' &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM') || isExistingRadioSelected)
                  const SizedBox(height: 10),
                if ((selectedOption == 'existing' && formValue.orderType == "CREDIT") &&
                    (formValue.channelCode == 'CO' ||
                        formValue.channelCode == 'CP' ||
                        formValue.channelCode == 'DI' ||
                        formValue.channelCode == 'SM') || isExistingRadioSelected)
                  PopupMenuButton<ExistingPoData>(
                    offset: const Offset(0, 20),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formValue.existingPoNumber != null ? formValue.existingPoNumber! : "Existing PO Numbers",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: formValue.existingPoNumber != null ? Colors.black : Colors.black54,
                                  ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey), // Add a dropdown icon
                          ],
                        ),
                      ),
                    ),
                    onSelected: (ExistingPoData existingData) async {
                      widget.controller.setValue(
                        widget.controller.value..existingPoNumber = existingData.poNumber,
                      );
                      salesOrderNumberController.text = existingData.salesOrderNumber ?? "";
                      widget.controller.value = widget.controller.value.copyWith(
                          salesOrderNumber: existingData.salesOrderNumber,
                          shipTo: existingData.shipToCode,
                          shipToName: existingData.shipToName,
                          channelCode: existingData.channelCode,
                          orderType: existingData.orderType,
                          shippingCondition: existingData.shippingCondition,
                          plantCode: existingData.plantCode,
                          plantName: existingData.plantName,
                          poFileName: existingData.poDocument,
                          poFileImagePath: existingData.poDocumentUrl,
                          productList: [existingData.product],
                          poQty: existingData.poQty,
                          remainingQty: existingData.remainingQty);
                    },
                    itemBuilder: (BuildContext context) {
                      if (formValue.existingPoDetails == null ||
                          formValue.existingPoDetails?.poRecordList?.isEmpty == true) {
                        return [
                          PopupMenuItem<ExistingPoData>(
                            value: ExistingPoData(
                              poNumber: null,
                              salesOrderNumber: null,
                              shipToCode: null,
                              shipToName: null,
                              channelCode: null,
                              orderType: null,
                              shippingCondition: null,
                              plantCode: null,
                              plantName: null,
                              poDocument: null,
                              productCode: null,
                              productName: null,
                              productMaskName: null,
                              productDescription: null,
                              productImage: null
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                              child: Text(
                                'No Existing PO',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                            ),
                          ),
                        ];
                      } else {
                        return [
                          if (formValue.existingPoDetails != null)
                            ...?formValue.existingPoDetails?.poRecordList?.map((existingPo) {
                              return PopupMenuItem<ExistingPoData>(
                                value: ExistingPoData(
                                  poNumber: existingPo.poNumber,
                                  salesOrderNumber: existingPo.salesOrder?.salesOrderNo,
                                  shipToCode: existingPo.salesOrder?.customerShippingLocation?.shipToCode,
                                  shipToName: existingPo.salesOrder?.customerShippingLocation?.shipToName,
                                  channelCode: existingPo.salesOrder?.distributionChannel?.channelCode,
                                  orderType: existingPo.salesOrder?.orderType,
                                  shippingCondition: existingPo.salesOrder?.shippingCondition,
                                  plantCode: existingPo.salesOrder?.plant?.plantCode,
                                  plantName: existingPo.salesOrder?.plant?.plantName,
                                  poDocument: existingPo.salesOrder?.poDocument,
                                  poDocumentUrl: existingPo.salesOrder?.poDocumentUrl,
                                  productCode: existingPo.poNumberDetailList?.first.product?.productCode,
                                  productName: existingPo.poNumberDetailList?.first.product?.productName,
                                  productMaskName: existingPo.poNumberDetailList?.first.product?.productMaskName,
                                  productDescription: existingPo.poNumberDetailList?.first.product?.productDescription,
                                  productImage: existingPo.poNumberDetailList?.first.product?.productImage?.first?.imageUrl,
                                  product: existingPo.poNumberDetailList?.first.product,
                                  poQty: existingPo.poNumberDetailList?.first.poQuantity.toString(),
                                  remainingQty: existingPo.poNumberDetailList?.first.remainingQuantity.toString(),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    (existingPo.poNumber ?? ''),
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              );
                            }),
                        ];
                      }
                    },
                  ),
                if ((formValue.channelCode == 'CO' ||
                    formValue.channelCode == 'CP' ||
                    formValue.channelCode == 'DI' ||
                    formValue.channelCode == 'SM') || isExistingRadioSelected)
                  const SizedBox(
                    height: 15,
                  ),
                if ((formValue.channelCode == 'CO' ||
                    formValue.channelCode == 'CP' ||
                    formValue.channelCode == 'DI' ||
                    formValue.channelCode == 'SM') || isExistingRadioSelected)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: B2BUploadButton(
                      controller: widget.controller,
                      onPressed: () async {
                        handleUpload(Source.files);
                      },
                      fileName: formValue.poFileName,
                      imagePath: formValue.poFileImagePath,
                      onRemove: removeFile,
                        isExistingRadioSelected: isExistingRadioSelected
                    ),
                  ),
              ],
            ),
          );
        });
  }
}

class ShipToData {
  final String? shipTo;
  final String? shipToName;
  final String? channelCode;

  ShipToData({this.shipTo, this.channelCode, this.shipToName});
}

class PlantData {
  final String? plantName;
  final String? plantCode;

  PlantData({this.plantCode, this.plantName});
}

class ExistingPoData {
  final String? poNumber;
  final String? salesOrderNumber;
  final String? shipToCode;
  final String? shipToName;
  final String? channelCode;
  final String? orderType;
  final String? shippingCondition;
  final String? plantCode;
  final String? plantName;
  final String? poDocument;
  final String? poDocumentUrl;
  final String? productCode;
  final String? productName;
  final String? productMaskName;
  final String? productDescription;
  final String? productImage;
  final ProductDto? product;
  final String? poQty;
  final String? remainingQty;

  ExistingPoData(
      {this.poNumber,
      this.salesOrderNumber,
      this.shipToCode,
      this.shipToName,
      this.channelCode,
      this.orderType,
      this.shippingCondition,
      this.plantCode,
      this.plantName,
      this.poDocument,
      this.poDocumentUrl,
      this.productCode,
      this.productName,
      this.productMaskName,
      this.productDescription,
      this.productImage,
      this.product,
      this.poQty,
      this.remainingQty});
}

class B2BUploadButton extends StatefulWidget {
  final void Function()? onPressed;
  final String? fileName;
  final String? imagePath;
  final void Function()? onRemove;
  final OrderCreateFormController controller;
  final bool isExistingRadioSelected;

  const B2BUploadButton(
      {Key? key, required this.onPressed, this.fileName, this.imagePath, this.onRemove, required this.controller,
        required this.isExistingRadioSelected})
      : super(key: key);

  @override
  State<B2BUploadButton> createState() => _B2BUploadButtonState();
}

class _B2BUploadButtonState extends State<B2BUploadButton> {
  void previewFile(String imagePath) async {
    try {
      await launchUrl(Uri.parse(imagePath));
    } catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 40,
              width: 220,
              child: FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                  visualDensity: VisualDensity.standard,
                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                  backgroundColor: MaterialStateProperty.all(Colors.red.withOpacity(0.9)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TextButton(
                            onPressed: () {
                              if (widget.imagePath != null) {
                                // If imagePath is not null, initiate file preview
                                previewFile(widget.imagePath!);
                              } else {
                                // If imagePath is null, execute the regular onPressed function
                                widget.onPressed?.call();
                              }
                            },
                            child: Text(
                              widget.fileName ?? "Upload PO Document",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.fileName == null)
                      const SizedBox(
                        width: 5,
                      ),
                    if (widget.fileName == null)
                      Center(
                        child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          onPressed: () {
                            if (widget.imagePath != null) {
                              // If imagePath is not null, initiate file preview
                              previewFile(widget.imagePath!);
                            } else {
                              // If imagePath is null, execute the regular onPressed function
                              widget.onPressed?.call();
                            }
                          },
                        ),
                      ),
                    const SizedBox(width: 5),
                    if (widget.fileName != null && !widget.isExistingRadioSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 0.5,
                            child: Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white, // Make the icon transparent
                                  ),
                                  onPressed: widget.onRemove,
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onRemove,
                                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                    ),
                                  ),
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
          );
        });
  }
}

class AvailableProduct extends StatefulWidget {
  final OrderCreateFormController controller;
  const AvailableProduct({Key? key, required this.controller}) : super(key: key);

  @override
  State<AvailableProduct> createState() => _AvailableProductState();
}

class _AvailableProductState extends State<AvailableProduct> {
  List<SelectedProduct> selectedProducts = [];
  SimulateSalesOrderDto? simulateSalesOrderData;
  dynamic amountValue;
  dynamic productPrice;
  double totalValue = 0.0;
  double totalWithVAT = 0.0;
  SimulateSalesOrderDto? simulateSalesOrderResponses;
  SimulateSalesOrderDto? convertToSimulateSalesOrderDtoLists;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeProducts();
    });
  }

  initializeProducts() async {
    if(widget.controller.value.isExistingRadioSelected ?? false) {
      await simulateSalesOrderForExistingPO(widget.controller.value.productList ?? []);
    }
  }

  void addSelectedProduct(
    String product,
    String productCode,
    String productType,
    double price,
    double orderQty,
    double poQty,
    double totalValue,
    double totalWithVAT,
  ) {
    setState(() {
      // Check if the product is already in the list
      int existingIndex = selectedProducts.indexWhere((p) => p.productCode == productCode);

      if (existingIndex != -1) {
        // If the product exists, update the quantity
        selectedProducts[existingIndex].orderQty = orderQty;
        selectedProducts[existingIndex].poQty = poQty;
        selectedProducts[existingIndex].price = price;
        selectedProducts[existingIndex].totalValue = totalValue;
        selectedProducts[existingIndex].totalWithVAT = totalWithVAT;
        if (orderQty == 0) {
          selectedProducts.removeAt(existingIndex);
        }
      } else if (orderQty != 0 && orderQty != null) {
        // If the product is not in the list, add it
        selectedProducts.add(SelectedProduct(
          product: product,
          productCode: productCode,
          productType: productType,
          price: price,
          orderQty: orderQty,
          poQty: poQty,
          totalValue: totalValue,
          totalWithVAT: totalWithVAT,
        ));
      }
      // Call simulateSalesOrder for the newly added selected product
      simulateSalesOrder(selectedProducts);
    });
  }

  Future<void> simulateSalesOrderForExistingPO(List<ProductDto> selectedProducts) async {
    String uuid = const Uuid().v4();

    List<Map<String, dynamic>> items = selectedProducts.map((selectedProduct) {
      return {
        "RequestID": uuid,
        "MaterialNumber": selectedProduct.productCode,
        "OrderQuantity": 1,
        "Plant": widget.controller.value.plantCode,
        "SalesDistrict": "",
        "CustomerGroup5": "",
      };
    }).toList();

    try {
      locate<LoadingIndicatorController>().show();
      final SimulateSalesOrderDto? responses = await locate<RestService>().simulateSalesOrder(
        referenceID: uuid,
        refDocumentNo: "",
        salesOrderType: widget.controller.value.orderType! == "CREDIT" ? "ZKDT" : "ZKCH",
        salesOrganization: widget.controller.value.salesOrganizationCode,
        distributionChannel: widget.controller.value.channelCode,
        division: widget.controller.value.divisionCode,
        soldToParty: widget.controller.value.soldToCode,
        requestDeliveryDate: "",
        shippingCondition: widget.controller.value.shippingCondition! == "PICKUP" ? "P1" : "D1",
        shippingType: "",
        specialProcessingID: "",
        paymentTerm: "",
        shipToNumber: widget.controller.value.shipTo,
        items: items,
      );
      if (mounted) {
        Future.delayed(Duration.zero, () {
          setState(() {
            convertToSimulateSalesOrderDtoLists = responses;
            simulateSalesOrderResponses = responses;
          });
        });
      }
    } catch (e) {
      // Handle errors
      return;
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  Future<void> simulateSalesOrder(List<SelectedProduct> selectedProducts) async {
    String uuid = const Uuid().v4();

    List<Map<String, dynamic>> items = selectedProducts.map((selectedProduct) {
      return {
        "RequestID": uuid,
        "MaterialNumber": selectedProduct.productCode,
        "OrderQuantity": selectedProduct.productType == "Bulk"
            ? selectedProduct.orderQty
            : double.parse((selectedProduct.orderQty * 0.05).toStringAsFixed(2)),
        "Plant": widget.controller.value.plantCode,
        "SalesDistrict": "",
        "CustomerGroup5": "",
      };
    }).toList();

    try {
      locate<LoadingIndicatorController>().show();
      final SimulateSalesOrderDto? responses = await locate<RestService>().simulateSalesOrder(
        referenceID: uuid,
        refDocumentNo: "",
        salesOrderType: widget.controller.value.orderType! == "CREDIT" ? "ZKDT" : "ZKCH",
        salesOrganization: widget.controller.value.salesOrganizationCode,
        distributionChannel: widget.controller.value.channelCode,
        division: widget.controller.value.divisionCode,
        soldToParty: widget.controller.value.soldToCode,
        requestDeliveryDate: "",
        shippingCondition: widget.controller.value.shippingCondition! == "PICKUP" ? "P1" : "D1",
        shippingType: "",
        specialProcessingID: "",
        paymentTerm: "",
        shipToNumber: widget.controller.value.shipTo,
        items: items,
      );
      setState(() {
        convertToSimulateSalesOrderDtoLists = responses;
        simulateSalesOrderResponses = responses;
      });
    } catch (e) {
      // Handle errors
      return;
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  handleNext() {
    if (selectedProducts.isNotEmpty && selectedProducts.first.orderQty != 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSubmissionView(
              selectedProducts: selectedProducts,
              controller: widget.controller,
              simulateSalesOrderResponses: convertToSimulateSalesOrderDtoLists,
            ),
          ));
    } else {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "No Item is Selected",
          subtitle: "Please Select an Item",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    }
  }

  String calculateUnitPrice(PricingItemDto response, String productGroup) {
    final unitPrice = response.amount ?? 0.0;

    // Apply different factors based on productGroup
    final factor = productGroup == "Bulk" ? 1.0 : (productGroup == "Bag" ? 0.05 : 1.0);
    widget.controller.value.productType = productGroup;
    // Calculate the adjusted unit price with two decimal points
    final adjustedUnitPrice = (unitPrice * factor).toStringAsFixed(2);

    return adjustedUnitPrice;
  }

  double convertToDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  double parseProductPrice(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.00;
    } else {
      return 0.00; // or throw an exception depending on your logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const AppBarWithTM(),
            body: Column(
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.scale(
                        scale: 0.7,
                        child: BackButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: const StepProgressIndicator(
                            totalSteps: 3,
                            currentStep: 1,
                            padding: 4,
                            selectedColor: Color(0xFF4A7A36),
                            roundedEdges: Radius.circular(15),
                            unselectedColor: Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (context, formValue, _) {
                      if (formValue.productList!.isEmpty) {
                        return const Center(
                          child: FittedBox(child: Text("There are no products available")),
                        );
                      }
                      return ListView.builder(
                          itemCount: formValue.productList?.length,
                          itemBuilder: (context, index) {
                            final product = formValue.productList?[index];
                            final correspondingResponse = simulateSalesOrderResponses?.pricingItem
                                ?.where(
                                  (response) => response.getProductCodes()?.contains(product?.productCode) ?? false,
                                )
                                .firstOrNull;
                            String unitPrice = "0.00";
                            String totalValue = "0.0";
                            double totalWithVAT = 0.0;

                            if (correspondingResponse != null) {
                              unitPrice = calculateUnitPrice(correspondingResponse, product?.productGroup ?? "");

                              totalValue = (correspondingResponse.totalCondition != null
                                  ? correspondingResponse.totalCondition.toString()
                                  : "0.0");
                              totalWithVAT = convertToDouble(totalValue) +
                                  convertToDouble(correspondingResponse.zsscCondition) +
                                  convertToDouble(correspondingResponse.vatCondition);
                            }
                            String? imagePath;
                            if (product?.productImage != null && product!.productImage!.isNotEmpty) {
                              if (product!.productImage![0]?.imageDisplayUrl != null &&
                                  product!.productImage![0]!.imageDisplayUrl == "MOBILE") {
                                imagePath = product!.productImage![0]!.imageDisplayUrl;
                              } else if (product!.productImage![1]?.imageDisplayUrl != null) {
                                imagePath = product!.productImage![1]!.imageDisplayUrl;
                              }
                            }
                            return ProductCard(
                              name: product?.productName ?? "N/A",
                              maskName: product?.productMaskName ?? "N/A",
                              price: unitPrice,
                              totalValue: totalValue,
                              totalWithVAT: totalWithVAT.toString(),
                              imagePath: imagePath ?? "",
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return WillPopScope(
                                      onWillPop: () async => false,  // Prevents the bottom sheet from closing on back button press
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,  // Ensures taps are registered inside the sheet
                                        onTap: () {},  // No action on tap outside the content
                                        child: ProductBottomSheet(
                                          controller: widget.controller,
                                          name: product?.productName ?? "N/A",
                                          productType: product?.productGroup ?? "N/A",
                                          initialOrderQty: (selectedProducts.firstWhere(
                                                  (p) => p.productCode == product?.productCode,
                                              orElse: () => SelectedProduct(
                                                  product: '',
                                                  productCode: '',
                                                  productType: '',
                                                  price: 0.0,
                                                  orderQty: 0.0,
                                                  poQty: 0.0,
                                                  totalValue: 0.0,
                                                  totalWithVAT: 0.0
                                              )
                                          )).orderQty,
                                          initialPOQty: (selectedProducts.firstWhere(
                                                  (p) => p.productCode == product?.productCode,
                                              orElse: () => SelectedProduct(
                                                  product: '',
                                                  productCode: '',
                                                  productType: '',
                                                  price: 0.0,
                                                  orderQty: 0.0,
                                                  poQty: 0.0,
                                                  totalValue: 0.0,
                                                  totalWithVAT: 0.0
                                              )
                                          )).poQty,
                                          onAddToCart: (orderQty, poQty) {
                                            setState(() {
                                              addSelectedProduct(
                                                product?.productName ?? "N/A",
                                                product?.productCode ?? "N/A",
                                                product?.productGroup ?? "N/A",
                                                double.parse(unitPrice.toString()),
                                                orderQty,
                                                poQty,
                                                double.parse(totalValue.toString()),
                                                totalWithVAT,
                                              );
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FilledButton(
                    onPressed: handleNext,
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
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }
}

class ProductBottomSheet extends StatefulWidget {
  final OrderCreateFormController controller;
  const ProductBottomSheet({
    Key? key,
    required this.controller,
    required this.name,
    required this.productType,
    required this.initialOrderQty,
    required this.initialPOQty,
    required this.onAddToCart,
  }) : super(key: key);

  final String name;
  final String productType;
  final double initialOrderQty;
  final double initialPOQty;
  final Function(double, double) onAddToCart;

  @override
  State<ProductBottomSheet> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  final TextEditingController orderQtyController = TextEditingController();
  final TextEditingController poQtyController = TextEditingController();
  final TextEditingController remainingQtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (orderQtyController.text.isEmpty) {
      widget.initialOrderQty == 0
          ? orderQtyController.text = ""
          : orderQtyController.text = widget.initialOrderQty.toString();
      widget.initialPOQty == 0 ? poQtyController.text = "" : poQtyController.text = widget.initialPOQty.toString();
    } else {
      orderQtyController.text = "";
      poQtyController.text = "";
    }
    orderQtyController.addListener(() {
      final text = orderQtyController.text;
      final newText = RegExp(r'^\d*\.?\d*$').hasMatch(text) ? text : text.replaceAll(RegExp(r'[^0-9.]'), '');
      if (newText != text) {
        orderQtyController.value = orderQtyController.value.copyWith(
          text: newText,
          selection: TextSelection(baseOffset: newText.length, extentOffset: newText.length),
          composing: TextRange.empty,
        );
      }
    });

    poQtyController.addListener(() {
      final text = poQtyController.text;
      final newText = RegExp(r'^\d*\.?\d*$').hasMatch(text) ? text : text.replaceAll(RegExp(r'[^0-9.]'), '');
      if (newText != text) {
        poQtyController.value = poQtyController.value.copyWith(
          text: newText,
          selection: TextSelection(baseOffset: newText.length, extentOffset: newText.length),
          composing: TextRange.empty,
        );
      }
    });

    if(widget.controller.value.isExistingRadioSelected ?? false){
      poQtyController.text = widget.controller.value.poQty.toString();
      remainingQtyController.text = widget.controller.value.remainingQty.toString();
    }
  }

  void addToCart() async {
    if (orderQtyController.text.trim().isEmpty || orderQtyController.text == "0") {
      // If orderQty is empty or 0, remove the selected product from the list
      widget.onAddToCart(0.0, 0.0);
    } else {
      double orderQty = double.parse(orderQtyController.text);

      double poQty;
      try {
        poQty = double.parse(poQtyController.text);
      } catch (e) {
        poQty = 0.0;
      }
      if ((widget.controller.value.channelCode == 'CO' ||
              widget.controller.value.channelCode == 'CP' ||
              widget.controller.value.channelCode == 'DI' ||
              widget.controller.value.channelCode == 'SM') &&
          (orderQty > poQty)) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Order quantity is greater than PO quantity",
            subtitle: "Please enter the Order quantity less than or equal to PO quantity",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } else {
        widget.onAddToCart(orderQty, poQty);
      }
    }
  }

  void addToCartExistingPO() async {
    if (orderQtyController.text.trim().isEmpty || orderQtyController.text == "0") {
      // If orderQty is empty or 0, remove the selected product from the list
      widget.onAddToCart(0.0, 0.0);
    } else {
      double orderQty = double.parse(orderQtyController.text);

      double poQty;
      double remainingQty;
      try {
        poQty = double.parse(poQtyController.text);
        remainingQty = double.parse(remainingQtyController.text);
      } catch (e) {
        poQty = 0.0;
        remainingQty = 0.0;
      }
      if ((widget.controller.value.channelCode == 'CO' ||
          widget.controller.value.channelCode == 'CP' ||
          widget.controller.value.channelCode == 'DI' ||
          widget.controller.value.channelCode == 'SM') &&
          (orderQty > remainingQty)) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Order quantity is greater than Remaining quantity",
            subtitle: "Please enter the Order quantity less than or equal to Remaining quantity",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } else {
        widget.onAddToCart(orderQty, poQty);
      }
    }
  }

  @override
  void dispose() {
    orderQtyController.dispose();
    poQtyController.dispose();
    super.dispose();
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.00;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.width >= 360
          ? (widget.controller.value.channelCode == 'CO' ||
                  widget.controller.value.channelCode == 'CP' ||
                  widget.controller.value.channelCode == 'DI' ||
                  widget.controller.value.channelCode == 'SM')
              ? MediaQuery.of(context).size.height * 0.5
              : MediaQuery.of(context).size.height * 0.4
          : (widget.controller.value.channelCode == 'CO' ||
                  widget.controller.value.channelCode == 'CP' ||
                  widget.controller.value.channelCode == 'DI' ||
                  widget.controller.value.channelCode == 'SM')
              ? MediaQuery.of(context).size.height * 0.7
              : MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Center(
            child: Icon(Icons.keyboard_arrow_down_outlined, size: 50, color: Colors.grey),
            ),
          const SizedBox(
            height: 5,
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
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Order Qty",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: orderQtyController,
                      keyboardType: TextInputType.number, // Use TextInputType.number for numerical input
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                          ),
                      decoration: InputDecoration(
                        suffix: widget.productType == "Bulk"
                            ? Text(
                                "TONS",
                                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )
                            : Text(
                          "BAG",
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM')
                      Text(
                        "PO Qty",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    if (widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM')
                      const SizedBox(
                        height: 5,
                      ),
                    if (widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM')
                      TextField(
                        controller: poQtyController,
                        readOnly: widget.controller.value.isExistingRadioSelected ?? false ? true : false,
                        keyboardType: TextInputType.number, // Use TextInputType.number for numerical input
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) => widget.controller.setValue(
                          widget.controller.value..poQuantity = value,
                        ),
                        decoration: InputDecoration(
                          suffix: widget.productType == "Bulk"
                              ? Text(
                                  "TONS",
                                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                        color: const Color(0xFF000000),
                                      ),
                                )
                              : Text(
                                  "BAG",
                                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                        color: const Color(0xFF000000),
                                      ),
                                ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          fillColor: widget.controller.value.isExistingRadioSelected ?? false ? const Color(0xFFDDDDDD) : Colors.white, // Set background color based on isSeleceted
                          filled: true,
                        ),
                      ),
                    if ((widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM') &&
                        widget.controller.value.isExistingRadioSelected == true)
                    const SizedBox(
                      height: 5,
                    ),
                    if ((widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM') &&
                        widget.controller.value.isExistingRadioSelected == true)
                      Text(
                        "Remaining Qty",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if ((widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM') &&
                        widget.controller.value.isExistingRadioSelected == true)
                      const SizedBox(
                        height: 5,
                      ),
                    if ((widget.controller.value.channelCode == 'CO' ||
                        widget.controller.value.channelCode == 'CP' ||
                        widget.controller.value.channelCode == 'DI' ||
                        widget.controller.value.channelCode == 'SM') &&
                        widget.controller.value.isExistingRadioSelected == true)
                      TextField(
                        controller: remainingQtyController,
                        readOnly: widget.controller.value.isExistingRadioSelected ?? false ? true : false,
                        keyboardType: TextInputType.number, // Use TextInputType.number for numerical input
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) => widget.controller.setValue(
                          widget.controller.value..poQuantity = value,
                        ),
                        decoration: InputDecoration(
                          suffix: widget.productType == "Bulk"
                              ? Text(
                            "TONS",
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                          )
                              : Text(
                            "BAG",
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          fillColor: widget.controller.value.isExistingRadioSelected ?? false ? const Color(0xFFDDDDDD) : Colors.white, // Set background color based on isSeleceted
                          filled: true,
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.controller.value.isExistingRadioSelected ?? false ? addToCartExistingPO
                            :addToCart,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
                        ),
                        child: Text(
                          "OK",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
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

class SelectedProduct {
  String product;
  String productCode;
  String productType;
  dynamic price;
  double orderQty;
  double poQty;
  dynamic totalValue;
  dynamic totalWithVAT;

  SelectedProduct({
    required this.product,
    required this.productCode,
    required this.productType,
    required this.price,
    required this.orderQty,
    required this.poQty,
    required this.totalValue,
    required this.totalWithVAT,
  });
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.name,
    required this.maskName,
    required this.price,
    required this.totalValue,
    required this.totalWithVAT,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  final String name;
  final String maskName;
  final String price;
  final String totalValue;
  final String totalWithVAT;
  final String imagePath;
  final VoidCallback onPressed;

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.00;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
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
              height: 200.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          FittedBox(
                            child: Text(
                              maskName,
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            child: Text(
                              "Unit Price (LKR)",
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              formatAmount(price),
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            child: Text(
                              "Total (LKR)",
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              formatAmount(totalValue),
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            child: Text(
                              "Total Incl. Tax (LKR)",
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              formatAmount(totalWithVAT),
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderSubmissionView extends StatefulFormWidget<OrderCreateFormValue> {
  final List<SelectedProduct> selectedProducts;
  final SimulateSalesOrderDto? simulateSalesOrderResponses;
  const OrderSubmissionView({
    Key? key,
    required OrderCreateFormController controller,
    required this.selectedProducts,
    required this.simulateSalesOrderResponses,
  }) : super(key: key, controller: controller);

  @override
  State<OrderSubmissionView> createState() => _OrderSubmissionViewState();
}

class _OrderSubmissionViewState extends State<OrderSubmissionView> {
  late SelectedCustomerController controller;
  bool _agreedToTerms = false;
  dynamic amountValue;
  dynamic productPrice;
  late double sscl;

  @override
  void initState() {
    super.initState();
    controller = locate<SelectedCustomerController>();
    setState(() {});
    dynamic netPrice = widget.simulateSalesOrderResponses?.pricing?.NetPrice;

    sscl = netPrice != null ? (netPrice is int ? netPrice.toInt() : netPrice) * ((widget.simulateSalesOrderResponses?.pricingItem?.first.zsscAmount ?? 0.0) / 100) : 0.0;
  }

  handleSalesOrderSubmit() async {
    double? totalAmountDocCurrency = double.tryParse(widget.controller.value.totalAmountDocCurrency ?? "0.0") ?? 0.0;
    dynamic netPrice = widget.simulateSalesOrderResponses?.pricing?.Net_Price_LK;

    double convertedNetPrice;

    if (netPrice is String) {
      convertedNetPrice = double.tryParse(netPrice) ?? 0.0; // Use 0.0 if parsing fails
    } else if (netPrice is int) {
      convertedNetPrice = netPrice.toDouble();
    } else if (netPrice is double) {
      convertedNetPrice = netPrice;
    } else {
      // Handle other types if needed
      convertedNetPrice = 0.0; // Default value for unknown type
    }
    if ((widget.controller.value.totalAmountDocCurrency?.isNotEmpty ?? false) &&
        (totalAmountDocCurrency >= convertedNetPrice)) {
      List<Map<String, dynamic>> salesOrderItems = widget.selectedProducts.map((selectedProduct) {
        final product = widget.selectedProducts.firstWhere((p) => p.productCode == selectedProduct.productCode);
        final data = widget.simulateSalesOrderResponses?.pricingItem
            ?.where(
              (response) => response.getProductCodes()?.contains(product.productCode) ?? false,
            )
            .firstOrNull;

        double? amountValue = 0.00;
        dynamic productPrice;
        double? beforeTax = 0.00;
        dynamic valueBeforeTax;
        double? vatCondition = 0.00;
        dynamic valueVatCondition;
        double? zsscCondition = 0.00;
        dynamic valueZsscCondition;
        double? valueAfterTax = 0.00;

        if (data?.amount is int) {
          amountValue = (data?.amount as int?)?.toDouble();
        } else if (data?.amount is double) {
          amountValue = data?.amount;
        } else if (data?.amount is String) {
          // Use toString() to convert the Object to a String
          amountValue = double.tryParse(data?.amount.toString() ?? "");
        }
        productPrice = amountValue;

        if (data?.totalCondition is int) {
          beforeTax = (data?.totalCondition as int?)?.toDouble();
        } else if (data?.totalCondition is double) {
          beforeTax = data?.totalCondition as double;
        } else if (data?.totalCondition is String) {
          // Use toString() to convert the Object to a String
          beforeTax = double.tryParse(data?.totalCondition.toString() ?? "");
        }
        valueBeforeTax = beforeTax;

        if (data?.vatCondition is int) {
          vatCondition = (data?.vatCondition as int?)?.toDouble();
        } else if (data?.vatCondition is double) {
          vatCondition = data?.vatCondition;
        } else if (data?.vatCondition is String) {
          // Use toString() to convert the Object to a String
          vatCondition = double.tryParse(data?.vatCondition.toString() ?? "");
        }
        valueVatCondition = vatCondition;

        if (data?.zsscCondition is int) {
          zsscCondition = (data?.zsscCondition as int?)?.toDouble();
        } else if (data?.zsscCondition is double) {
          zsscCondition = data?.zsscCondition;
        } else if (data?.zsscCondition is String) {
          // Use toString() to convert the Object to a String
          zsscCondition = double.tryParse(data?.zsscCondition.toString() ?? "");
        }
        valueZsscCondition = zsscCondition;
        valueAfterTax = beforeTax! + zsscCondition! + vatCondition!;
        return {
          "product": {"productCode": selectedProduct.productCode},
          "plant": {"plantCode": widget.controller.value.plantCode},
          "originalQuantity": selectedProduct.orderQty.toString(),
          "quantity": selectedProduct.orderQty.toString(),
          "poQuantity": selectedProduct.poQty.toString(),
          "lineItemNumber": data?.salesDocumentItem,
          "unitPrice": productPrice.toString(),
          "valueBeforeTax": valueBeforeTax.toString(),
          "valueAfterTax": valueAfterTax.toString(),
          "urgent": false,
        };
      }).toList();

      try {
        locate<LoadingIndicatorController>().show();
        Storage storage = Storage();
        String? email0 = await storage.readValue("email");
        final userResp = await locate<RestService>().getUserByEmail(email0!);

        final createdSalesOrderData = await locate<RestService>().createSalesOrder(
          salesOrderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          email: userResp!.email,
          firstName: userResp.firstName,
          userId: userResp.id,
          internal: userResp.internal,
          lastName: userResp.lastName,
          mobileNo: userResp.mobileNo,
          soldToCode: widget.controller.value.soldToCode,
          shipToCode: widget.controller.value.shipTo,
          channelCode: widget.controller.value.channelCode,
          divisionCode: widget.controller.value.divisionCode,
          orderType: widget.controller.value.orderType! == "CREDIT" ? "ZKDT" : "ZKCH",
          plantCode: widget.controller.value.plantCode,
          poDocumentUrl: widget.controller.value.poDocument,
          poNumber: widget.controller.value.tempAssignmentNumberList?.first ??
              widget.controller.value.bank ??
              widget.controller.value.poNumber,
          salesOrgCode: widget.controller.value.salesOrganizationCode,
          shippingCondition: widget.controller.value.shippingCondition! == "PICKUP" ? "P1" : "D1",
          ssclTax: widget.simulateSalesOrderResponses?.pricing?.NetPrice * 0.0217 ?? 0.0,
          tax: widget.simulateSalesOrderResponses?.pricing?.Tax_LK,
          valueAfterTax: widget.simulateSalesOrderResponses?.pricing?.Net_Price_LK ?? 0.0,
          valueBeforeTax: widget.simulateSalesOrderResponses?.pricing?.NetPrice.toDouble() ?? 0.0,
          vat: widget.simulateSalesOrderResponses?.pricing?.Tax ?? 0.0,
          salesOrderPaymentDetails: widget.controller.value.tempAssignmentNumberList,
          salesOrderItems: salesOrderItems,
        );
        String? requestedReferenceId = createdSalesOrderData.requestReferenceCode;
        final selectedCustomerController = locate<SelectedCustomerController>();
        selectedCustomerController.setValue(selectedCustomerController.value.copyWith(
          soldToCode: widget.controller.value.soldToCode,
        ));
        final salesOrderCalloutStatuses = await locate<RestService>().getSalesOrderStatus(requestedReferenceId ?? '');
        String? salesOrderInternalStatus = salesOrderCalloutStatuses!.internalStatus;
        if (salesOrderInternalStatus != "FAILED") {
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Order Create",
              subtitle: "Sales Order Created Successfully",
              color: Colors.green,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
          );
          GoRouter.of(context).go("/view-sales-orders");
        } else {
          String salesOrderInternalStatusMessage =
              salesOrderCalloutStatuses.salesOrderCalloutStatuses?.first.statusMessage ?? "Sales Order Creation Failed";
          locate<PopupController>().addItemFor(
            DismissiblePopup(
              title: "Order Creation Failed",
              subtitle: salesOrderInternalStatusMessage,
              color: Colors.red,
              onDismiss: (self) => locate<PopupController>().removeItem(self),
            ),
            const Duration(seconds: 5),
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
    } else {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Total Order Value should not be exceeds Total Assignments",
          subtitle: "Please enter the Total Assignments value greater than or equal to Total Order Value",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    }
  }

  handleSalesOrderSubmitWithoutAssignment() async {
    List<Map<String, dynamic>> salesOrderItems = widget.selectedProducts.map((selectedProduct) {
      final product = widget.selectedProducts.firstWhere((p) => p.productCode == selectedProduct.productCode);
      final data = widget.simulateSalesOrderResponses?.pricingItem
          ?.where(
            (response) => response.getProductCodes()?.contains(product.productCode) ?? false,
          )
          .firstOrNull;

      double? amountValue = 0.00;
      dynamic productPrice;
      double? beforeTax = 0.00;
      dynamic valueBeforeTax;
      double? vatCondition = 0.00;
      dynamic valueVatCondition;
      double? zsscCondition = 0.00;
      dynamic valueZsscCondition;
      double? valueAfterTax = 0.00;

      if (data?.amount is int) {
        amountValue = (data?.amount as int?)?.toDouble();
      } else if (data?.amount is double) {
        amountValue = data?.amount;
      } else if (data?.amount is String) {
        // Use toString() to convert the Object to a String
        amountValue = double.tryParse(data?.amount.toString() ?? "");
      }
      productPrice = amountValue;

      if (data?.totalCondition is int) {
        beforeTax = (data?.totalCondition as int?)?.toDouble();
      } else if (data?.totalCondition is double) {
        beforeTax = data?.totalCondition as double;
      } else if (data?.totalCondition is String) {
        // Use toString() to convert the Object to a String
        beforeTax = double.tryParse(data?.totalCondition.toString() ?? "");
      }
      valueBeforeTax = beforeTax;

      if (data?.vatCondition is int) {
        vatCondition = (data?.vatCondition as int?)?.toDouble();
      } else if (data?.vatCondition is double) {
        vatCondition = data?.vatCondition;
      } else if (data?.vatCondition is String) {
        // Use toString() to convert the Object to a String
        vatCondition = double.tryParse(data?.vatCondition.toString() ?? "");
      }
      valueVatCondition = vatCondition;

      if (data?.zsscCondition is int) {
        zsscCondition = (data?.zsscCondition as int?)?.toDouble();
      } else if (data?.zsscCondition is double) {
        zsscCondition = data?.zsscCondition;
      } else if (data?.zsscCondition is String) {
        // Use toString() to convert the Object to a String
        zsscCondition = double.tryParse(data?.zsscCondition.toString() ?? "");
      }
      valueZsscCondition = zsscCondition;
      valueAfterTax = beforeTax! + zsscCondition! + vatCondition!;
      return {
        "product": {"productCode": selectedProduct.productCode},
        "plant": {"plantCode": widget.controller.value.plantCode},
        "originalQuantity": selectedProduct.orderQty.toString(),
        "quantity": selectedProduct.orderQty.toString(),
        "poQuantity": selectedProduct.poQty.toString(),
        "lineItemNumber": data?.salesDocumentItem,
        "unitPrice": productPrice.toString(),
        "valueBeforeTax": valueBeforeTax.toString(),
        "valueAfterTax": valueAfterTax.toString(),
        "urgent": false,
      };
    }).toList();

    try {
      locate<LoadingIndicatorController>().show();
      Storage storage = Storage();
      String? email0 = await storage.readValue("email");
      final userResp = await locate<RestService>().getUserByEmail(email0!);

      final createdSalesOrderData = await locate<RestService>().createSalesOrder(
        salesOrderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        email: userResp!.email,
        firstName: userResp.firstName,
        userId: userResp.id,
        internal: userResp.internal,
        lastName: userResp.lastName,
        mobileNo: userResp.mobileNo,
        soldToCode: widget.controller.value.soldToCode,
        shipToCode: widget.controller.value.shipTo,
        channelCode: widget.controller.value.channelCode,
        divisionCode: widget.controller.value.divisionCode,
        orderType: widget.controller.value.orderType! == "CREDIT" ? "ZKDT" : "ZKCH",
        plantCode: widget.controller.value.plantCode,
        poDocumentUrl: widget.controller.value.poDocument,
        poNumber: widget.controller.value.tempAssignmentNumberList?.first ??
            widget.controller.value.bank ??
            widget.controller.value.poNumber,
        salesOrgCode: widget.controller.value.salesOrganizationCode,
        shippingCondition: widget.controller.value.shippingCondition! == "PICKUP" ? "P1" : "D1",
        ssclTax: widget.simulateSalesOrderResponses?.pricing?.NetPrice * 0.0217 ?? 0.0,
        tax: widget.simulateSalesOrderResponses?.pricing?.Tax_LK,
        valueAfterTax: widget.simulateSalesOrderResponses?.pricing?.Net_Price_LK ?? 0.0,
        valueBeforeTax: widget.simulateSalesOrderResponses?.pricing?.NetPrice.toDouble() ?? 0.0,
        vat: widget.simulateSalesOrderResponses?.pricing?.Tax ?? 0.0,
        salesOrderPaymentDetails: widget.controller.value.tempAssignmentNumberList,
        salesOrderItems: salesOrderItems,
      );
      String? requestedReferenceId = createdSalesOrderData.requestReferenceCode;
      final selectedCustomerController = locate<SelectedCustomerController>();
      selectedCustomerController.setValue(selectedCustomerController.value.copyWith(
        soldToCode: widget.controller.value.soldToCode,
      ));
      final salesOrderCalloutStatuses = await locate<RestService>().getSalesOrderStatus(requestedReferenceId ?? '');
      String? salesOrderInternalStatus = salesOrderCalloutStatuses!.internalStatus;
      if (salesOrderInternalStatus != "FAILED") {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Order Create",
            subtitle: "Sales Order Created Successfully",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        GoRouter.of(context).go("/view-sales-orders");
      } else {
        String salesOrderInternalStatusMessage =
            salesOrderCalloutStatuses.salesOrderCalloutStatuses?.first.statusMessage ?? "Sales Order Creation Failed";
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Order Creation Failed",
            subtitle: salesOrderInternalStatusMessage,
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
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

  void previewTC() async {
    try {
      await launchUrl(Uri.parse(locate<AppConfig>().termsAndConditionUri!));
    } catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 2),
      );
    }
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.00;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.simulateSalesOrderResponses == null) {
      return const Scaffold(
        backgroundColor: Color(0xffffffff),
        appBar: AppBarWithTM(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: const AppBarWithTM(),
      body: ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, formValue, child) {
            return Column(
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.scale(
                        scale: 0.7,
                        child: BackButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: const StepProgressIndicator(
                            totalSteps: 3,
                            currentStep: 2,
                            padding: 4,
                            selectedColor: Color(0xFF4A7A36),
                            roundedEdges: Radius.circular(15),
                            unselectedColor: Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Please verify the order summary below and submit.",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: ListView(
                    children: [
                      ShippingDetailsCard(
                        shipTo:
                            "${formValue.channelCode ?? ""} ${formValue.soldToCode ?? "N/A"} ${formValue.shipToName ?? ""}",
                        orderType: formValue.orderType ?? "N/A",
                        shippingCondition: formValue.shippingCondition ?? "N/A",
                        plant: "${formValue.plantCode ?? "N/A"} ${formValue.plantName ?? ""}",
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        endIndent: 10,
                        indent: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Order Summary",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFFDA4540),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const DashedDivider(),
                      const SizedBox(
                        height: 20,
                      ),
                      if (widget.simulateSalesOrderResponses?.pricingItem == null ||
                          widget.simulateSalesOrderResponses?.pricingItem?.isEmpty == true)
                        Center(
                          child: Text(
                            "No related data found",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: const Color(0xFF000000),
                                ),
                          ),
                        ),
                      Column(
                        children: List.generate(
                          widget.simulateSalesOrderResponses?.pricingItem?.length ?? 0,
                          (index) {
                            final product = widget.selectedProducts[index];
                            final data = widget.simulateSalesOrderResponses?.pricingItem?[index];

                            double? amountValue = 0.00;
                            dynamic productPrice;

                            if (data?.amount is int) {
                              amountValue = (data?.amount as int?)?.toDouble();
                            } else if (data?.amount is double) {
                              amountValue = data?.amount;
                            } else if (data?.amount is String) {
                              // Use toString() to convert the Object to a String
                              amountValue = double.tryParse(data?.amount.toString() ?? "");
                            }
                            if (product.productType == "Bulk") {
                              productPrice = amountValue;
                            } else {
                              double calculatedPrice = amountValue! * 0.05;
                              productPrice = double.parse(calculatedPrice.toString()).toStringAsFixed(2);
                            }

                            return OrderSummaryCard(
                              productDescription: product?.product ?? "N/A",
                              unitPrice: productPrice.toString() ?? 0.00,
                              orderQuantity: formatAmount(product.orderQty.toString() ?? "N/A"),
                              total: formatAmount(data?.totalCondition.toString() ?? "N/A"),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        endIndent: 10,
                        indent: 10,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ValueCard(
                        orderValue: formatAmount(widget.simulateSalesOrderResponses?.pricing?.NetPrice.toStringAsFixed(2) ?? "0.00"),
                        withVAT:
                            formatAmount(widget.simulateSalesOrderResponses?.pricing?.Tax.toStringAsFixed(2) ?? "0.00"),
                        sscl: formatAmount(sscl.toStringAsFixed(2) ?? "0.00"),
                        totalOrderValue: formatAmount(
                            widget.simulateSalesOrderResponses?.pricing?.Net_Price_LK.toStringAsFixed(2) ?? "0.00"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value!;
                                });
                              },
                            ),
                            Flexible(
                              child: FittedBox(
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                    children: [
                                      const TextSpan(
                                        text: "I agree to the INSEE ",
                                      ),
                                      TextSpan(
                                        text: "terms & conditions",
                                        style: const TextStyle(
                                          color: Color(0xFF0A3977),
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            previewTC();
                                          },
                                      ),
                                      const TextSpan(
                                        text: " by submitting this order.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FilledButton(
                          onPressed: _agreedToTerms
                              ? (widget.controller.value.totalAmountDocCurrency?.isNotEmpty ?? false
                                  ? handleSalesOrderSubmit
                                  : handleSalesOrderSubmitWithoutAssignment)
                              : null,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.standard,
                            minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                            backgroundColor: MaterialStateProperty.all(
                              _agreedToTerms ? const Color(0xFF4A7A36) : Colors.grey,
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                          ),
                          child: const Text("SUBMIT ORDER"),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderCreateRetailCreditView(controller: OrderCreateFormController()),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.standard,
                            minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                            backgroundColor: MaterialStateProperty.all(Colors.red.shade400),
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
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class ShippingDetailsCard extends StatelessWidget {
  const ShippingDetailsCard({
    super.key,
    required this.shipTo,
    required this.orderType,
    required this.shippingCondition,
    required this.plant,
  });
  final String shipTo;
  final String orderType;
  final String shippingCondition;
  final String plant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Colors.white,
        height: 120.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Ship To",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        shipTo,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Order Type",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        orderType,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Shipping Condition",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      shippingCondition,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Plant",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        plant,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.productDescription,
    required this.unitPrice,
    required this.orderQuantity,
    required this.total,
  });
  final String productDescription;
  final dynamic unitPrice;
  final String orderQuantity;
  final String total;
  @override
  Widget build(BuildContext context) {
    double? price = 0.0;
    if (unitPrice is int) {
      price = unitPrice.toDouble();
    } else if (unitPrice is double) {
      price = unitPrice;
    } else if (unitPrice is String) {
      // Use toString() to convert the Object to a String
      price = double.tryParse(unitPrice.toString()) ?? 0.0;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Colors.white,
        height: 140.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Product Description",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        productDescription,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Unit Price (LKR)",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      price.toString(),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Order Quantity",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      orderQuantity,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Total (LKR)",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      total,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class ValueCard extends StatelessWidget {
  const ValueCard({
    super.key,
    required this.orderValue,
    required this.withVAT,
    required this.sscl,
    required this.totalOrderValue,
  });
  final String orderValue;
  final String withVAT;
  final String sscl;
  final String totalOrderValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width >= 360 ? 100.0 : 80.0,
        right: 8,
      ),
      child: Container(
        color: Colors.white,
        height: 130.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Order Value",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        orderValue,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "SSCL (2.17%)",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      sscl,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "VAT (18%)",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      withVAT,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Total Order Value",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        totalOrderValue,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DashedDivider(),
          ],
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1.0,
    this.color = Colors.grey,
    this.dashWidth = 3.0,
    this.dashSpace = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class CustomerSearchCard extends StatefulWidget {
  final OrderCreateFormController controller;
  const CustomerSearchCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomerSearchCard> createState() => _CustomerSearchCardState();
}

class _CustomerSearchCardState extends State<CustomerSearchCard> {
  late Future<UserResponseDto?> action;
  UserResponseDto? customerList;
  UserResponseDto? user;
  TextEditingController customerSearchController = TextEditingController();
  List<CustomerSearchDto>? fetchedCustomerList;
  CustomerSearchDto? selectedCustomer;

  @override
  void initState() {
    fetchCustomer();
    customerSearchController.addListener(onSearchTextChanged);
    customerSearchController.text = widget.controller.value.soldToCode != null
        ? "${widget.controller.value.soldToCode} ${widget.controller.value.soldToName}"
        : "";
    super.initState();
  }

  fetchCustomer() {
    setState(() {
      action = () async {
        Storage storage = Storage();
        String? email = await storage.readValue("email");
        final data = await locate<RestService>().getUserByEmail(email!);
        customerList = data;
        user = data;
      }.call();
    });
  }

  fetchSearchCustomer(String searchText) async {
    try {
      final searchList = await locate<RestService>().searchCustomerDetails(searchText: searchText.toLowerCase());

      setState(() {
        fetchedCustomerList = searchList;
      });
    } catch (error) {
      setState(() {
        fetchedCustomerList = null;
      });
    }
  }

  void onSearchTextChanged() {
    fetchSearchCustomer(customerSearchController.text.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
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
                height: 85,
                width: 350,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  child: Text(
                                    "Customer",
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: SearchField(
                                    suggestions: fetchedCustomerList
                                            ?.map((customer) => SearchFieldListItem(
                                                  "${customer.soldToCode!} ${customer.name!}",
                                                  item: customer,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                    child: Text(
                                                      "${customer.soldToCode!} "
                                                      "${customer.name!} ",
                                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                  ),
                                                ))
                                            .toList() ??
                                        [],
                                    suggestionState: Suggestion.hidden,
                                    controller: customerSearchController,
                                    suggestionStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    hint: '  Search Customer',
                                    searchStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxSuggestionsInViewPort: 4,
                                    autoCorrect: false,
                                    itemHeight: 45,
                                    textCapitalization: TextCapitalization.words,
                                    inputType: TextInputType.text,
                                    onSuggestionTap: (suggestion) async {
                                      if (suggestion.item != null) {
                                        if (suggestion.item is CustomerSearchDto) {
                                          CustomerSearchDto soldToData = suggestion.item as CustomerSearchDto;
                                          if (soldToData.soldToCode != null && soldToData.name != null) {
                                            setState(() {
                                              selectedCustomer = soldToData;
                                            });
                                            widget.controller.setValue(
                                              widget.controller.value
                                                ..soldToCode = soldToData.soldToCode
                                                ..soldToName = soldToData.name,
                                            );
                                            setState(() {
                                              customerSearchController.text =
                                                  "${widget.controller.value.soldToCode} ${widget.controller.value.soldToName}";
                                            });
                                            locate<LoadingIndicatorController>().show();
                                            await widget.controller.getDivisionCode(soldToData.soldToCode);
                                            if (formValue.soldToCode != null) {
                                              await widget.controller.getDivisionCode(soldToData.soldToCode);
                                              await widget.controller.getBankListBySoldToCode(soldToData.soldToCode);
                                              await widget.controller.getCustomerDetails(soldToData.soldToCode);
                                            }
                                            if (formValue.divisionCode != null &&
                                                formValue.soldToCode != null &&
                                                formValue.salesOrganizationCode != null) {
                                              await widget.controller.fetchQueryCreditAvailabilityReport();
                                              await widget.controller.fetchSalesOrderFormValueList();
                                              await widget.controller.fetchAssignmentNumberList();
                                            }
                                            locate<LoadingIndicatorController>().hide();
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      selectedCustomer = null;
                                      customerSearchController.text = "";
                                      clearSelectedData();
                                    });
                                  },
                                ),
                              ],
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

  // Clear selected customer data
  void clearSelectedData() {
    widget.controller.setValue(widget.controller.value
      ..soldToCode = null
      ..soldToName = null
      ..shipTo = null
      ..shipToName = null
      ..shipToCodeList = null
      ..channelCode = null
      ..orderType = null
      ..shippingCondition = null
      ..shippingConditionList = null
      ..bank = null
      ..salesOrderFormValueList = null
      ..bank = null
      ..chequeNumber = null
      ..poNumber = null
      ..assignmentNoList = null
      ..assignmentNumber = null
      ..tempAssignmentNumberList = null
      ..plantCode = null
      ..plantName = null
      ..plantList = null
      ..orderTypeList = null
      ..divisionCode = null
      ..divisionCodeList = null
      ..salesOrganizationCode = null
      ..salesOrganizationName = null
      ..salesOrgCodeList = null
      ..creditLimitAvailable = null
      ..creditLimitUsedAmount = null
      ..salesOrderNumber = null
      ..poDocument = null
      ..poFileImagePath = null
      ..poFileName = null
      ..totalAmountDocCurrency = null);
  }
}

class SoldToDataBySearchedCustomer {
  final String? soldToCode;
  final String? soldToName;

  SoldToDataBySearchedCustomer({this.soldToCode, this.soldToName});
}
