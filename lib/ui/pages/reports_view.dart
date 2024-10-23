import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';

class ReportFormValue {
  String? shipTo;
  String? shipToName;
  List<SoldToCodeSummaryDto>? shipToCodeList;
  String? materialName;
  String? shippingCondition;
  String? orderType;
  String? materialGroup;
  List<PlantListDto>? plantList;
  List<ProductDto>? productList = [];
  String? poNumber;
  String? poQuantity;
  String? plantCode;
  String? plantName;
  String? salesOrderNumber;
  String? soStatus;
  String? dateFrom;
  String? dateTo;
  ReportDataDto? reportData;
  SOReportDto? soReportData;
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  ReportFormValue.empty();

  ReportFormValue copyWith({
    String? shipTo,
    String? shipToName,
    List<SoldToCodeSummaryDto>? shipToCodeList,
    String? materialName,
    String? shippingCondition,
    String? orderType,
    String? materialGroup,
    List<PlantListDto>? plantList,
    List<ProductDto>? productList,
    String? poNumber,
    String? poQuantity,
    String? plantCode,
    String? plantName,
    String? salesOrderNumber,
    String? soStatus,
    String? dateFrom,
    String? dateTo,
    ReportDataDto? reportData,
    SOReportDto? soReportData,
    DateTime? selectedDateFrom,
    DateTime? selectedDateTo,
    Map<String, String>? errors,
  }) {
    return ReportFormValue.empty()
      ..shipTo = shipTo ?? this.shipTo
      ..shipToName = shipToName ?? this.shipToName
      ..shipToCodeList = shipToCodeList ?? this.shipToCodeList
      ..materialName = materialName ?? this.materialName
      ..shippingCondition = shippingCondition ?? this.shippingCondition
      ..orderType = orderType ?? this.orderType
      ..materialGroup = materialGroup ?? this.materialGroup
      ..poNumber = poNumber ?? this.poNumber
      ..poQuantity = poQuantity ?? this.poQuantity
      ..plantCode = plantCode ?? this.plantCode
      ..plantName = plantName ?? this.plantName
      ..plantList = plantList ?? this.plantList
      ..productList = productList ?? this.productList
      ..salesOrderNumber = salesOrderNumber ?? this.salesOrderNumber
      ..soStatus = soStatus ?? this.soStatus
      ..dateFrom = dateFrom ?? this.dateFrom
      ..dateTo = dateTo ?? this.dateTo
      ..reportData = reportData ?? this.reportData
      ..soReportData = soReportData ?? this.soReportData
      ..selectedDateFrom = selectedDateFrom ?? this.selectedDateFrom
      ..selectedDateTo = selectedDateTo ?? this.selectedDateTo
      ..errors = errors ?? this.errors;
  }
}

class ReportFormController extends FormController<ReportFormValue> {
  ReportFormController() : super(initialValue: ReportFormValue.empty());

  clear() {
    value = ReportFormValue.empty();
  }
}

class SearchFilterSalesOrderView extends StatefulWidget {
  final ReportFormController controller;
  const SearchFilterSalesOrderView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SearchFilterSalesOrderView> createState() => _SearchFilterSalesOrderViewState();
}

class _SearchFilterSalesOrderViewState extends State<SearchFilterSalesOrderView> {
  late Future action;
  late SelectedCustomerController controller;
  ReportDataDto? reportData;

  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    initializeReportData();
    super.initState();
  }

  initializeReportData() async {
    controller = locate<SelectedCustomerController>();
    await fetchData();
  }

  fetchData() {
    setState(() {
      action = () async {
        final selectedCustomerController = locate<SelectedCustomerController>();
        String? soldToCode = selectedCustomerController.value.soldToCode;
        String? salesOrganizationCode = selectedCustomerController.value.salesOrganizationCode;
        String? divisionCode = selectedCustomerController.value.divisionCode;
        final data = await locate<RestService>().fetchReportData(
            soldToCode: soldToCode ?? "",
            salesOrganizationCode: salesOrganizationCode ?? "",
            divisionCode: divisionCode ?? "");
        if (data != null) {
          widget.controller.setValue(widget.controller.value.copyWith(reportData: data));
        }

        final formFieldData = await locate<RestService>().getSoldToCodeSummary(
          soldToCode: soldToCode ?? "",
          divisionCode: divisionCode ?? "",
          salesOrgCode: salesOrganizationCode ?? "",
        );

        if (formFieldData != null && formFieldData.isNotEmpty) {
          widget.controller.setValue(widget.controller.value.copyWith(
            shipToCodeList: formFieldData.isNotEmpty ? formFieldData : null,
          ));
        }
      }.call();
    });
  }

  handleSOReportSearch() async {
    try {
      locate<LoadingIndicatorController>().show();

      final searchSOReport = await locate<RestService>().soReportSearchData(
        startDate: widget.controller.value.dateFrom ?? "",
        endDate: widget.controller.value.dateTo ?? "",
        shipToCode: widget.controller.value.shipTo ?? "",
        orderType: widget.controller.value.orderType ?? "",
        soNumber: widget.controller.value.salesOrderNumber ?? "",
        poNumber: widget.controller.value.poNumber ?? "",
        plant: widget.controller.value.plantName ?? "",
        shippingCondition: widget.controller.value.shippingCondition ?? "",
        material: widget.controller.value.materialName ?? "",
        materialGroup: widget.controller.value.materialGroup ?? "",
        soStatus: widget.controller.value.soStatus ?? "",
      );
      widget.controller.setValue(widget.controller.value.copyWith(soReportData: searchSOReport));
      if (searchSOReport != null && searchSOReport.salesOrderReports?.isNotEmpty == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportView(controller: widget.controller),
          ),
        );
      } else {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "No Records Available",
            subtitle: "No any Records Available",
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

  requiredSearchOptions() {
    locate<PopupController>().addItemFor(
      DismissiblePopup(
        title: "Please enter form data",
        subtitle: "Please enter form data to search reports",
        color: Colors.red,
        onDismiss: (self) => locate<PopupController>().removeItem(self),
      ),
      const Duration(seconds: 5),
    );
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
          future: Future.delayed(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: BackButton(
                        onPressed: () => GoRouter.of(context).go("/home"),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Search & Filter Sales Order Reports  ",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (context, formValue, _) {
                      return Expanded(
                        child: ListView(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            ReportDropdownBox(controller: widget.controller),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: FilledButton(
                                onPressed: () {
                                  if (widget.controller.value.dateFrom != null ||
                                      widget.controller.value.dateTo != null ||
                                      widget.controller.value.shipTo != null ||
                                      widget.controller.value.salesOrderNumber != null ||
                                      widget.controller.value.poNumber != null ||
                                      widget.controller.value.plantCode != null ||
                                      widget.controller.value.shippingCondition != null ||
                                      widget.controller.value.materialName != null ||
                                      widget.controller.value.soStatus != null ||
                                      widget.controller.value.orderType != null ||
                                      widget.controller.value.materialGroup != null) {
                                    handleSOReportSearch();
                                  } else {
                                    requiredSearchOptions();
                                  }
                                },
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.standard,
                                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                                  backgroundColor: MaterialStateProperty.all(AppColors.red),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                ),
                                child: const Text("Search"),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: FilledButton(
                                onPressed: () {
                                  widget.controller.setValue(widget.controller.value
                                    ..dateFrom = null
                                    ..dateTo = null
                                    ..shipTo = null
                                    ..salesOrderNumber = null
                                    ..poNumber = null
                                    ..plantCode = null
                                    ..plantName = null
                                    ..shippingCondition = null
                                    ..materialName = null
                                    ..materialGroup = null
                                    ..soStatus = null
                                    ..orderType = null
                                    ..selectedDateFrom = null
                                    ..selectedDateTo = null);
                                },
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.standard,
                                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                                  backgroundColor: MaterialStateProperty.all(const Color(0xFFD9D9D9)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Clear Filter",
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    }),
              ],
            );
          }),
    );
  }
}

class ReportDropdownBox extends StatefulWidget {
  final ReportFormController controller;
  const ReportDropdownBox({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<ReportDropdownBox> createState() => _ReportDropdownBoxState();
}

class _ReportDropdownBoxState extends State<ReportDropdownBox> {
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;
  List<String> soStatus = ["OPEN", "PENDING", "COMPLETED", "FAILED", "BLOCKED", "UNBLOCK PENDING", "SUBMITTED"];

  @override
  void initState() {
    super.initState();
    widget.controller.value.selectedDateFrom =
        widget.controller.value.dateFrom != null ? DateTime.parse(widget.controller.value.dateFrom!) : null;
    widget.controller.value.selectedDateTo =
        widget.controller.value.dateTo != null ? DateTime.parse(widget.controller.value.dateTo!) : null;

    if (widget.controller.value.dateFrom == null) {
      widget.controller.value.selectedDateFrom = null;
    } else {
      widget.controller.value.selectedDateFrom = DateTime.parse(widget.controller.value.dateFrom!);
    }

    if (widget.controller.value.dateTo == null) {
      widget.controller.value.selectedDateTo = null;
    } else {
      widget.controller.value.selectedDateTo = DateTime.parse(widget.controller.value.dateTo!);
    }
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime initialDate = widget.controller.value.selectedDateFrom ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != widget.controller.value.selectedDateFrom) {
      setState(() {
        widget.controller.value.selectedDateFrom = picked;
        widget.controller.setValue(
          widget.controller.value
            ..dateFrom = DateFormat('yyyy-MM-dd').format(widget.controller.value.selectedDateFrom!),
        );
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    // Only allow selecting "To" date if "From" date is set
    if (widget.controller.value.selectedDateFrom == null) {
      return;
    }
    final DateTime initialDate = widget.controller.value.selectedDateTo ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.controller.value.selectedDateFrom!,
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != widget.controller.value.selectedDateTo) {
      setState(() {
        widget.controller.value.selectedDateTo = picked;
        widget.controller.setValue(
          widget.controller.value..dateTo = DateFormat('yyyy-MM-dd').format(widget.controller.value.selectedDateTo!),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, formValue, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Date Range",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Date Range",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _selectDateFrom(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.dateFrom != null
                                        ? "${widget.controller.value.selectedDateFrom?.toLocal()}".split(' ')[0]
                                        : "From",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            " ",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: const Color(0xFF000000),
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.controller.value.dateFrom != null ? _selectDateTo(context) : null;
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      formValue.dateTo != null
                                          ? "${widget.controller.value.selectedDateTo?.toLocal()}".split(' ')[0]
                                          : "To",
                                      style: formValue.dateFrom != null
                                          ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                                color: Colors.black,
                                              )
                                          : Theme.of(context).textTheme.titleSmall!.copyWith(
                                                color: Colors.black54,
                                              )),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: formValue.dateFrom != null ? Colors.black : Colors.black54),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Ship-To Code",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Ship-To Code",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<ReportShipToData>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.shipTo != null ? formValue.shipTo! : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(widget.controller.value
                              ..shipTo = value.shipTo
                              ..shipToName = value.shipToName);
                          },
                          itemBuilder: (BuildContext context) {
                            if (formValue.reportData?.poNumbers?.isEmpty ?? true) {
                              return [
                                PopupMenuItem<ReportShipToData>(
                                  value: null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                    child: Text(
                                      'No ShipToCodes',
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
                                    return PopupMenuItem<ReportShipToData>(
                                      value: ReportShipToData(
                                        shipTo: shipTo.shipToCode,
                                        shipToName: shipTo.shipToName,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                        child: Text(
                                          (shipTo.shipToCode ?? ''),
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
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Shipping Condition",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Shipping Condition",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.shippingCondition != null
                                        ? (() {
                                            final fullText =
                                                formValue.shippingCondition == "P1" ? "PICKUP" : "DELIVERED";
                                            return fullText.length > 28 ? '${fullText.substring(0, 28)}...' : fullText;
                                          })()
                                        : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(widget.controller.value..shippingCondition = value);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: "P1",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    "PICKUP",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "D1",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    "DELIVERED",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Order type",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Order type",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.orderType != null
                                        ? (() {
                                            final fullText = formValue.orderType == "ZKCH" ? "CASH" : "CREDIT";
                                            return fullText.length > 28 ? '${fullText.substring(0, 28)}...' : fullText;
                                          })()
                                        : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(widget.controller.value..orderType = value);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: "ZKCH",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    "CASH",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "ZKDT",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    "CREDIT",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Material Group",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Material Group",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.materialGroup != null
                                        ? (() {
                                            final fullText = formValue.materialGroup == "Bag" ? "BAGS" : "BULKS";
                                            return fullText.length > 28 ? '${fullText.substring(0, 28)}...' : fullText;
                                          })()
                                        : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(widget.controller.value..materialGroup = value);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: "Bag",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    "BAGS",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "Bulk",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                  child: Text(
                                    "BULKS",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Material",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Material",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<ReportMaterialData>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.materialName != null
                                        ? MediaQuery.of(context).size.width >= 360
                                            ? (() {
                                                final fullText = formValue.materialName ?? "-Select-";
                                                return fullText.length > 15
                                                    ? '${fullText.substring(0, 15)}..'
                                                    : fullText;
                                              })()
                                            : (() {
                                                final fullText = formValue.materialName ?? "-Select-";
                                                return fullText.length > 10
                                                    ? '${fullText.substring(0, 10)}..'
                                                    : fullText;
                                              })()
                                        : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(widget.controller.value..materialName = value.materialName);
                          },
                          itemBuilder: (BuildContext context) {
                            if (formValue.reportData?.materials?.isEmpty ?? true) {
                              return [
                                PopupMenuItem<ReportMaterialData>(
                                  value: null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                    child: Text(
                                      'No Materials',
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ),
                                ),
                              ];
                            } else {
                              return [
                                if (formValue.reportData?.materials != null)
                                  ...?formValue.reportData?.materials?.map((material) {
                                    return PopupMenuItem<ReportMaterialData>(
                                      value: ReportMaterialData(
                                        materialCode: material.code,
                                        materialName: material.name,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                        child: Text(
                                          (material.name ?? ''),
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
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Plant",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Plant",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<ReportPlantData>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.plantCode != null
                                        ? MediaQuery.of(context).size.width >= 360
                                            ? (() {
                                                final fullText = "${formValue.plantName!} ${formValue.plantCode!}";
                                                return fullText.length > 13
                                                    ? '${fullText.substring(0, 13)}..'
                                                    : fullText;
                                              })()
                                            : (() {
                                                final fullText = "${formValue.plantName!} ${formValue.plantCode!}";
                                                return fullText.length > 8 ? '${fullText.substring(0, 8)}..' : fullText;
                                              })()
                                        : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(widget.controller.value
                              ..plantCode = value.plantCode
                              ..plantName = value.plantName);
                          },
                          itemBuilder: (BuildContext context) {
                            if (formValue.reportData?.plants?.isEmpty ?? true) {
                              return [
                                PopupMenuItem<ReportPlantData>(
                                  value: null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                    child: Text(
                                      'No Plants',
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                  ),
                                ),
                              ];
                            } else {
                              return [
                                if (formValue.reportData?.plants != null)
                                  ...?formValue.reportData?.plants?.map((plants) {
                                    return PopupMenuItem<ReportPlantData>(
                                      value: ReportPlantData(
                                        plantCode: plants.code,
                                        plantName: plants.name,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                        child: Text(
                                          ("${plants.name} ${plants.code}" ?? ''),
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
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: MediaQuery.of(context).size.width >= 360
                                ? Text(
                                    "SO Status",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  )
                                : Text(
                                    "SO Status",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  )),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width >= 360 ? 170 : 140,
                            height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formValue.soStatus != null
                                        ? MediaQuery.of(context).size.width >= 360
                                            ? (() {
                                                final fullText = formValue.soStatus!;
                                                return fullText.length > 13
                                                    ? '${fullText.substring(0, 13)}..'
                                                    : fullText;
                                              })()
                                            : (() {
                                                final fullText = formValue.soStatus!;
                                                return fullText.length > 8 ? '${fullText.substring(0, 8)}..' : fullText;
                                              })()
                                        : "-Select-",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            widget.controller.setValue(
                              widget.controller.value..soStatus = value,
                            );
                          },
                          itemBuilder: (BuildContext context) {
                            {
                              // Show the list of sales order numbers
                              return soStatus.map((soStatus) {
                                    return PopupMenuItem<String>(
                                      value: soStatus,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                                        child: Text(
                                          soStatus,
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
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class ReportShipToData {
  final String? shipTo;
  final String? shipToName;

  ReportShipToData({this.shipTo, this.shipToName});
}

class ReportPlantData {
  final String? plantName;
  final String? plantCode;

  ReportPlantData({this.plantCode, this.plantName});
}

class ReportMaterialData {
  final String? materialName;
  final String? materialCode;

  ReportMaterialData({this.materialCode, this.materialName});
}

class ReportView extends StatefulWidget {
  final ReportFormController controller;
  const ReportView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
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
      body: Column(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 0.7,
                child: BackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Search Order Reports",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                ReportDetailViewCard(
                  quantity: formatAmount(widget.controller.value.soReportData?.orderQuantity ?? "0.0"),
                  totalValue: formatAmount(widget.controller.value.soReportData?.totalValueWithoutVat ?? "0.0"),
                  tax: formatAmount(widget.controller.value.soReportData?.tax ?? "0.0"),
                  totalWithVAT: formatAmount(widget.controller.value.soReportData?.totalValueWithVat ?? "0.0"),
                  controller: widget.controller,
                ),
                ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, snapshot, _) {
                    if (snapshot.soReportData?.salesOrderReports?.isEmpty ?? true) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Sales Orders.")),
                      );
                    }

                    String? getRemainingQuantityForMaterial(List<RemainingQtyDto>? remainingQuantities, String? material) {
                      if (remainingQuantities == null || material == null) {
                        return null;
                      }

                      for (var quantity in remainingQuantities) {
                        if (quantity.productName == material) {
                          return quantity.remainingPoQuantity.toString();
                        }
                      }

                      return "N/A";
                    }
                    return Column(
                      children: snapshot.soReportData?.salesOrderReports
                              ?.map(
                                (salesOrder) => ReportViewCard(
                                  salesOrderNo: salesOrder.soNumber ?? "N/A",
                                  createdDate: salesOrder.salesOrderDate ?? "N/A",
                                  orderType: salesOrder.orderType == "ZKCH" ? "CASH" : "CREDIT",
                                  soStatus: salesOrder.soStatus ?? "N/A",
                                  plant: salesOrder.plant ?? "N/A",
                                  poNumber: salesOrder.poNumber ?? "N/A",
                                  remainingQty: getRemainingQuantityForMaterial(salesOrder.remainingQuantity, salesOrder.material) ?? "N/A",
                                  shipToCode: salesOrder.shipToCode ?? "N/A",
                                  shippingCondition: salesOrder.shippingCondition == "P1" ? "PICKUP" : "DELIVERED",
                                  material: salesOrder.material ?? "N/A",
                                  soldToCode: salesOrder.soldToCode ?? "N/A",
                                  soldToName: salesOrder.soldToName ?? "N/A",
                                  shipToName: salesOrder.shipToName ?? "N/A",
                                  qty: salesOrder.orderQuantity.toString(),
                                  materialGroup: salesOrder.materialGroup ?? "N/A",
                                  unitPrice: salesOrder.unitPriceWithoutVat ?? "N/A",
                                  unitPriceVAT: salesOrder.unitPriceWithVat ?? "N/A",
                                  totalValue: salesOrder.totalValueWithoutVat.toString(),
                                  tax: salesOrder.tax.toString(),
                                  totalValueVAT: salesOrder.totalValueWithVat.toString(),
                                ),
                              )
                              .toList() ??
                          [],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportDetailViewCard extends StatefulWidget {
  final ReportFormController controller;
  const ReportDetailViewCard({
    Key? key,
    required this.controller,
    required this.quantity,
    required this.totalValue,
    required this.tax,
    required this.totalWithVAT,
  }) : super(key: key);

  final String quantity;
  final String totalValue;
  final String tax;
  final String totalWithVAT;

  @override
  State<ReportDetailViewCard> createState() => _ReportDetailViewCardState();
}

class _ReportDetailViewCardState extends State<ReportDetailViewCard> {
  void previewFile() async {
    try {
      locate<LoadingIndicatorController>().show();
      String path = await locate<RestService>().salesOrderReportExport(
          startDate: widget.controller.value.dateFrom ?? "",
          endDate: widget.controller.value.dateTo ?? "",
          shipToCode: widget.controller.value.shipTo ?? "",
          orderType: widget.controller.value.orderType ?? "",
          soNumber: widget.controller.value.salesOrderNumber ?? "",
          poNumber: widget.controller.value.poNumber ?? "",
          plant: widget.controller.value.plantCode ?? "",
          shippingCondition: widget.controller.value.shippingCondition ?? "",
          material: widget.controller.value.materialName ?? "",
          materialGroup: widget.controller.value.materialGroup ?? "",
          soStatus: widget.controller.value.soStatus ?? "",
          fileType: "CSV");
      await launchUrl(Uri.parse(path));
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
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        color: const Color(0xFFE3E3E3),
        height: 190.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Quantity (MT)",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Total Value (Without VAT)",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Tax",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Total Value + VAT",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.quantity,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.totalValue,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.tax,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.totalWithVAT,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
                alignment: Alignment.center,
                child: SOViewButton(
                  onPressed: previewFile,
                  color: Colors.red.withOpacity(0.9),
                  title: "Export",
                  width: 155,
                  textColor: const Color(0xFFFFFFFF),
                  icon: const Icon(
                    Icons.turn_slight_right,
                    color: Color(0xFFFFFFFF),
                    size: 16,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class ReportViewCard extends StatelessWidget {
  const ReportViewCard({
    Key? key,
    required this.createdDate,
    required this.soldToCode,
    required this.soldToName,
    required this.orderType,
    required this.shipToCode,
    required this.shipToName,
    required this.salesOrderNo,
    required this.poNumber,
    required this.qty,
    required this.remainingQty,
    required this.plant,
    required this.shippingCondition,
    required this.material,
    required this.materialGroup,
    required this.unitPrice,
    required this.unitPriceVAT,
    required this.totalValue,
    required this.tax,
    required this.totalValueVAT,
    required this.soStatus,
  }) : super(key: key);

  final String createdDate;
  final String soldToCode;
  final String soldToName;
  final String orderType;
  final String shipToCode;
  final String shipToName;
  final String salesOrderNo;
  final String poNumber;
  final String qty;
  final String remainingQty;
  final String plant;
  final String shippingCondition;
  final String material;
  final String materialGroup;
  final String unitPrice;
  final String unitPriceVAT;
  final String totalValue;
  final String tax;
  final String totalValueVAT;
  final String soStatus;

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.00;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  void showViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: MediaQuery.of(context).size.width >= 360 ? 560.0 : 250.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Created Date",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              createdDate,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Sold to Code",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              soldToCode,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Sold to Name",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  soldToName,
                                  style: MediaQuery.of(context).size.width >= 360
                                      ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          )
                                      : Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Order Type",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              orderType,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Ship to Code",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              shipToCode,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Ship to Name",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  shipToName,
                                  style: MediaQuery.of(context).size.width >= 360
                                      ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          )
                                      : Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Sales Order No",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              salesOrderNo,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "PO Number",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              poNumber,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Qty",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(qty),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Remaining Qty",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(remainingQty),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Plant",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  plant,
                                  style: MediaQuery.of(context).size.width >= 360
                                      ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          )
                                      : Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Shipping Condition",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              shippingCondition,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Material",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  material,
                                  style: MediaQuery.of(context).size.width >= 360
                                      ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          )
                                      : Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w300,
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Material Group",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              materialGroup,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Unit Price",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(unitPrice),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Unit Price + VAT",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(unitPriceVAT),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Total Value",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(totalValue),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "TAX",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(tax),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Total Value + VAT",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              formatAmount(totalValueVAT),
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      height: 30,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "SO Status",
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            Text(
                              soStatus,
                              style: MediaQuery.of(context).size.width >= 360
                                  ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      )
                                  : Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: SOViewButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: const Color(0xFFD9D9D9),
                          title: "Ok",
                          width: 190,
                          textColor: const Color(0xFF000000),
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.transparent,
                            size: 0,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 3,
          child: Container(
            color: Colors.white,
            height: 100.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              "SO Number",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              salesOrderNo,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            child: Text(
                              "Order type",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              orderType,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: SOViewButton(
                      onPressed: () {
                        showViewDialog(context);
                      },
                      color: const Color(0xFFD9D9D9),
                      title: "View",
                      width: 190,
                      textColor: const Color(0xFF000000),
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.transparent,
                        size: 0,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SOViewButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final double width;
  final Color color;
  final Icon icon;
  final Color textColor;
  const SOViewButton(
      {Key? key,
      required this.onPressed,
      required this.title,
      required this.width,
      required this.color,
      required this.icon,
      required this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 35,
        width: width,
        child: FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: MaterialStateProperty.all(color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor),
                  ),
                  icon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
