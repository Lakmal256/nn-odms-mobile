import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../../util/util.dart';
import '../ui.dart';
import 'package:go_router/go_router.dart';

class ViewPayments extends StatefulWidget {
  const ViewPayments({super.key});

  @override
  State<ViewPayments> createState() => _ViewPaymentsState();
}

class _ViewPaymentsState extends State<ViewPayments> {
  late Future action;
  late SelectedCustomerController controller;
  UserResponseDto? user;

  @override
  void initState() {
    super.initState();
    controller = locate<SelectedCustomerController>();
    initializeQueryData();
  }

  initializeQueryData() async {
    controller = locate<SelectedCustomerController>();
    await fetchData();
  }

  fetchData() {
    action = () async {
      await locate<PaymentListService>().fetchCustomerPaymentList();
      await locate<InvoiceListService>().fetchCustomerInvoiceList();
      await locate<PaymentSetoffListService>().fetchCustomerSetoffList();
      final queryData = await locate<RestService>().getQueryCreditAvailabilityReport(
        customerCode: controller.value.soldToCode ?? "",
        companyCode: controller.value.salesOrganizationCode ?? "",
      );
      if (queryData != null && queryData.isNotEmpty) {
        controller.setValue(
            controller.value.copyWith(creditLimitAvailable: queryData.first.CreditLimitAvailable.toString() ?? "0.00"));
      }
      Storage storage = Storage();
      String? email = await storage.readValue("email");
      final data = await locate<RestService>().getUserByEmail(email!);
      user = data;
      if (data != null) {
        controller.setValue(controller.value.copyWith(userRole: data.roles?.first.roleName));
      }
    }.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbfcf8),
      appBar: const AppBarWithTM(),
      body: FutureBuilder(
          future: action,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                const SizedBox(height: 10),
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
                          "Payment & Invoices",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                const PaymentViewTabs(),
                const SizedBox(height: 10),
              ],
            );
          }),
    );
  }
}

class PaymentViewTabs extends StatefulWidget {
  const PaymentViewTabs({super.key});

  @override
  State<PaymentViewTabs> createState() => _PaymentViewTabsState();
}

class _PaymentViewTabsState extends State<PaymentViewTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Future action;
  bool isPaymentCheckboxSelected = false;
  bool isInvoiceCheckboxSelected = false;
  bool showPaymentCheckboxes = false;
  bool showInvoiceCheckboxes = true;
  double? selectedPaymentAmount = 0.0;
  double? selectedInvoiceAmount = 0.0;
  Map<int, bool> selectedPaymentsStates = {};
  Map<int, bool> selectedInvoicesStates = {};
  List<dynamic> source = [];
  late List<bool> isExpandedList = [];
  List<SelectedPayments> selectedPaymentsList = [];
  List<SelectedInvoices> selectedInvoicesList = [];
  late SelectedCustomerController controller;
  late List<PaymentSetoffListDto> displayedItems = [];
  UserResponseDto? user;
  int cardsPerPage = 5; // Number of cards to show per page
  int currentPage = 0; // Current page index, starting from 0

  // Flag to determine whether the tabs should be disabled
  bool areTabsDisabled() {
    return selectedPaymentsStates.isNotEmpty || selectedInvoicesStates.isNotEmpty;
  }

  double calculateTotalAmount(List<PaymentListDto> payments) {
    double totalAmount = 0.0;
    for (var payment in payments) {
      totalAmount +=
          double.tryParse(payment.amountDocCurrency!.substring(0, payment.amountDocCurrency!.length - 1)) ?? 0.0;
    }
    return totalAmount;
  }

  void handlePaymentCheckboxSelection(
    int index,
    bool? value,
    String? name,
    String? paymentAmount,
    int? companyCode,
    String? customerCode,
    int? documentNo_FI,
    int? billingDoc,
    int? invoiceDoc,
    String? postingDate,
    String? documentDate,
    String? netDueDate,
    String? lineItem,
    String? amountDocCurrency,
    String? docCurrency,
    String? documentType,
    String? documentType2,
    String? customerPONumber,
    String? reference,
    String? overdueDays,
    String? overdueAmount,
    String? description,
    String? assignment,
      String? specialGL
  ) {
    setState(() {
      selectedPaymentsStates[index] = value ?? false;
      if (value ?? false) {
        selectedPaymentAmount = (selectedPaymentAmount ?? 0.0) + (double.tryParse(paymentAmount ?? "0.0") ?? 0.0);
        selectedPaymentsList.add(
          SelectedPayments(
            name: name,
            companyCode: companyCode,
            customerCode: customerCode,
            documentNo_FI: documentNo_FI,
            billingDoc: billingDoc,
            invoiceDoc: invoiceDoc,
            postingDate: postingDate,
            documentDate: documentDate,
            netDueDate: netDueDate,
            lineItem: lineItem,
            amountDocCurrency: amountDocCurrency,
            docCurrency: docCurrency,
            documentType: documentType,
            documentType2: documentType2,
            customerPONumber: customerPONumber,
            reference: reference,
            overdueDays: overdueDays,
            overdueAmount: overdueAmount,
            description: description,
            assignment: assignment,
            specialGL: specialGL,
          ),
        );
      } else {
        selectedPaymentAmount = (selectedPaymentAmount ?? 0.0) - (double.tryParse(paymentAmount ?? "0.0") ?? 0.0);
        selectedPaymentsList.removeWhere(
          (payment) =>
              payment.name == name &&
              payment.companyCode == companyCode &&
              payment.customerCode == customerCode &&
              payment.documentNo_FI == documentNo_FI &&
              payment.billingDoc == billingDoc &&
              payment.invoiceDoc == invoiceDoc &&
              payment.postingDate == postingDate &&
              payment.documentDate == documentDate &&
              payment.netDueDate == netDueDate &&
              payment.lineItem == lineItem &&
              payment.amountDocCurrency == amountDocCurrency &&
              payment.docCurrency == docCurrency &&
              payment.documentType == documentType &&
              payment.documentType2 == documentType2 &&
              payment.customerPONumber == customerPONumber &&
              payment.reference == reference &&
              payment.overdueDays == overdueDays &&
              payment.overdueAmount == overdueAmount &&
              payment.description == description &&
              payment.assignment == assignment &&
            payment.specialGL == specialGL,
        );
      }
      selectedPaymentAmount = selectedPaymentAmount?.clamp(0.0, double.infinity);

      // Remove unchecked payments from the map
      selectedPaymentsStates.removeWhere((key, value) => value == false);
    });
  }

  void handleInvoiceCheckboxSelection(
      int index,
      bool? value,
      String? name,
      String? invoiceAmount,
      String? svat,
      String? totalAfterSvat,
      int? companyCode,
      String? customerCode,
      int? documentNo_FI,
      int? billingDoc,
      int? invoiceDoc,
      String? postingDate,
      String? documentDate,
      String? netDueDate,
      String? lineItem,
      String? amountDocCurrency,
      String? docCurrency,
      String? documentType,
      String? documentType2,
      String? customerPONumber,
      String? reference,
      String? overdueDays,
      String? overdueAmount,
      String? description,
      String? assignment,
      String? specialGL) {
    setState(() {
      if (value ?? false) {
        selectedInvoicesStates[index] = true;
        selectedInvoiceAmount = (selectedInvoiceAmount ?? 0.0) + (double.tryParse(invoiceAmount ?? "0.0") ?? 0.0);
        selectedInvoicesList.add(
          SelectedInvoices(
            name: name,
            svat: svat,
            totalAfterSvat: totalAfterSvat,
            companyCode: companyCode,
            customerCode: customerCode,
            documentNo_FI: documentNo_FI,
            billingDoc: billingDoc,
            invoiceDoc: invoiceDoc,
            postingDate: postingDate,
            documentDate: documentDate,
            netDueDate: netDueDate,
            lineItem: lineItem,
            amountDocCurrency: amountDocCurrency,
            docCurrency: docCurrency,
            documentType: documentType,
            documentType2: documentType2,
            customerPONumber: customerPONumber,
            reference: reference,
            overdueDays: overdueDays,
            overdueAmount: overdueAmount,
            description: description,
            assignment: assignment,
            specialGL: specialGL,
          ),
        );
      } else {
        selectedInvoicesStates[index] = false;
        selectedInvoiceAmount = (selectedInvoiceAmount ?? 0.0) - (double.tryParse(invoiceAmount ?? "0.0") ?? 0.0);
        selectedInvoicesList.removeWhere(
          (invoice) =>
              invoice.name == name &&
              invoice.svat == svat &&
              invoice.totalAfterSvat == totalAfterSvat &&
              invoice.companyCode == companyCode &&
              invoice.customerCode == customerCode &&
              invoice.documentNo_FI == documentNo_FI &&
              invoice.billingDoc == billingDoc &&
              invoice.invoiceDoc == invoiceDoc &&
              invoice.postingDate == postingDate &&
              invoice.documentDate == documentDate &&
              invoice.netDueDate == netDueDate &&
              invoice.lineItem == lineItem &&
              invoice.amountDocCurrency == amountDocCurrency &&
              invoice.docCurrency == docCurrency &&
              invoice.documentType == documentType &&
              invoice.documentType2 == documentType2 &&
              invoice.customerPONumber == customerPONumber &&
              invoice.reference == reference &&
              invoice.overdueDays == overdueDays &&
              invoice.overdueAmount == overdueAmount &&
              invoice.description == description &&
              invoice.assignment == assignment &&
            invoice.specialGL == specialGL,
        );
      }

      selectedInvoiceAmount = selectedInvoiceAmount?.clamp(0.0, double.infinity);

      // Remove unchecked invoices from the map
      selectedInvoicesStates.removeWhere((key, value) => value == false);
    });
  }

  @override
  void initState() {
    super.initState();
    initializeQueryData();
    tabController = TabController(
        length: (controller.value.userRole == "Finance User" ||
                controller.value.userRole == "B2B Sales User/AM" ||
                controller.value.userRole == "Retail Sales User" ||
                controller.value.userRole == "Customer Support User" ||
                controller.value.userRole == "Customer Admin" ||
                controller.value.userRole == "Customer User" ||
                controller.value.userRole == "Super Admin" ||
                controller.value.userRole == "Business Administrator" ||
                controller.value.userRole == "Call Center User")
            ? 3
            : 2,
        vsync: this);
    tabController.addListener(_handleTabSelection);
    isExpandedList = List.generate(locate<PaymentSetoffListService>().value.setoffList.length, (index) => false);
    controller = locate<SelectedCustomerController>();
  }

  fetchData() {
    setState(() {
      action = () async {
        await locate<PaymentListService>().fetchCustomerPaymentList();
        await locate<InvoiceListService>().fetchCustomerInvoiceList();
        await locate<PaymentSetoffListService>().fetchCustomerSetoffList();
        final queryData = await locate<RestService>().getQueryCreditAvailabilityReport(
          customerCode: controller.value.soldToCode ?? "",
          companyCode: controller.value.salesOrganizationCode ?? "",
        );
        if (queryData != null && queryData.isNotEmpty) {
          controller.setValue(controller.value
              .copyWith(creditLimitAvailable: queryData.first.CreditLimitAvailable.toString() ?? "0.00"));
        }

        Storage storage = Storage();
        String? email = await storage.readValue("email");
        final data = await locate<RestService>().getUserByEmail(email!);
        user = data;
      }.call();
    });
  }

  initializeQueryData() async {
    controller = locate<SelectedCustomerController>();
    await fetchData();
  }

  void _handleTabSelection() {
    setState(() {
      isPaymentCheckboxSelected = false;
      isInvoiceCheckboxSelected = false;
    });
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  Future<void> setoffOrder(List<SelectedPayments> selectedPayments, List<SelectedInvoices> selectedInvoices) async {
    List<Map<String, dynamic>> customerPaymentList = selectedPayments.map((selectedPayment) {
      return {
        "name": selectedPayment.name,
        "CompanyCode": selectedPayment.companyCode,
        "CustomerCode": selectedPayment.customerCode,
        "DocumentNo_FI": selectedPayment.documentNo_FI,
        "BillingDoc": selectedPayment.billingDoc,
        "InvoiceDoc": selectedPayment.invoiceDoc,
        "PostingDate": selectedPayment.postingDate,
        "DocumentDate": selectedPayment.documentDate,
        "NetDueDate": selectedPayment.netDueDate,
        "LineItem": selectedPayment.lineItem,
        "AmountDocCurrency": selectedPayment.amountDocCurrency,
        "DocCurrency": selectedPayment.docCurrency,
        "DocumentType": selectedPayment.documentType,
        "CustomerPONumber": selectedPayment.customerPONumber,
        "Reference": selectedPayment.reference,
        "OverdueDays": selectedPayment.overdueDays,
        "OverdueAmount": selectedPayment.overdueAmount,
        "Description": selectedPayment.description,
        "Assignment": selectedPayment.assignment,
        "DocumentType2": selectedPayment.documentType2,
        "SpecialGL" : selectedPayment.specialGL,
      };
    }).toList();

    List<Map<String, dynamic>> customerInvoicesList = selectedInvoices.map((selectedInvoice) {
      return {
        "name": selectedInvoice.name,
        "totalAfterSvat": selectedInvoice.totalAfterSvat,
        "svat": selectedInvoice.svat,
        "CompanyCode": selectedInvoice.companyCode,
        "CustomerCode": selectedInvoice.customerCode,
        "DocumentNo_FI": selectedInvoice.documentNo_FI,
        "BillingDoc": selectedInvoice.billingDoc,
        "InvoiceDoc": selectedInvoice.invoiceDoc,
        "PostingDate": selectedInvoice.postingDate,
        "DocumentDate": selectedInvoice.documentDate,
        "NetDueDate": selectedInvoice.netDueDate,
        "LineItem": selectedInvoice.lineItem,
        "AmountDocCurrency": selectedInvoice.amountDocCurrency,
        "DocCurrency": selectedInvoice.docCurrency,
        "DocumentType": selectedInvoice.documentType,
        "CustomerPONumber": selectedInvoice.customerPONumber,
        "Reference": selectedInvoice.reference,
        "OverdueDays": selectedInvoice.overdueDays,
        "OverdueAmount": selectedInvoice.overdueAmount,
        "Description": selectedInvoice.description,
        "Assignment": selectedInvoice.assignment,
        "DocumentType2": selectedInvoice.documentType2,
        "SpecialGL" : selectedInvoice.specialGL,
      };
    }).toList();

    try {
      locate<LoadingIndicatorController>().show();
      await locate<RestService>().setoffSalesOrder(
        customerPaymentList: customerPaymentList,
        customerInvoiceList: customerInvoicesList,
      );
      await locate<PaymentSetoffListService>().fetchCustomerSetoffList();
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Payment Setoff Submit Successfully",
          subtitle: "Your Payment Setoff request Successfully Submitted",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
      tabController.animateTo(2);
    } on NotAcceptedException catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Payment Setoff Not Accepted",
          subtitle:  e.message,
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (e) {
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
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, snapshot, _) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (controller.value.userRole == "Finance User" ||
                    controller.value.userRole == "B2B Sales User/AM" ||
                    controller.value.userRole == "Retail Sales User" ||
                    controller.value.userRole == "Customer Support User" ||
                    controller.value.userRole == "Customer Admin" ||
                    controller.value.userRole == "Customer User" ||
                    controller.value.userRole == "Business Administrator" ||
                    controller.value.userRole == "Super Admin" ||
                    controller.value.userRole == "Call Center User")
                  if (tabController.index == 0 && !showPaymentCheckboxes)
                    Align(
                      alignment: Alignment.centerRight,
                      child: PaymentSetoffButton(
                        tabController: tabController,
                        onPressed: () {
                          setState(() {
                            showPaymentCheckboxes = !showPaymentCheckboxes;
                          });
                        },
                      ),
                    ),
                if (controller.value.userRole == "Finance User" ||
                    controller.value.userRole == "B2B Sales User/AM" ||
                    controller.value.userRole == "Retail Sales User" ||
                    controller.value.userRole == "Customer Support User" ||
                    controller.value.userRole == "Customer Admin" ||
                    controller.value.userRole == "Customer User" ||
                    controller.value.userRole == "Business Administrator" ||
                    controller.value.userRole == "Super Admin" ||
                    controller.value.userRole == "Call Center User")
                  if (tabController.index == 0 && showPaymentCheckboxes)
                    Align(
                      alignment: Alignment.centerRight,
                      child: NextButton(
                        tabController: tabController,
                        onPressed: () {
                          if (selectedPaymentsStates.isNotEmpty) {
                            tabController.animateTo(1);
                          }
                        },
                        selectedPaymentsStates: selectedPaymentsStates,
                      ),
                    ),
                if (controller.value.userRole == "Finance User" ||
                    controller.value.userRole == "B2B Sales User/AM" ||
                    controller.value.userRole == "Retail Sales User" ||
                    controller.value.userRole == "Customer Support User" ||
                    controller.value.userRole == "Customer Admin" ||
                    controller.value.userRole == "Customer User" ||
                    controller.value.userRole == "Business Administrator" ||
                    controller.value.userRole == "Super Admin" ||
                    controller.value.userRole == "Call Center User")
                  if (tabController.index == 1)
                    InvoiceConfirmButton(
                      tabController: tabController,
                      onPressed: () async {
                        await setoffOrder(selectedPaymentsList, selectedInvoicesList);
                      },
                      selectedInvoicesStates: selectedInvoicesStates,
                    ),
                const SizedBox(height: 10),
                Container(
                  color: const Color(0xFFD9D9D9).withOpacity(0.4),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: TabBar(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: tabController,
                      isScrollable: true,
                      indicator: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: Colors.red.withOpacity(0.8),
                        shadows: const [BoxShadow(color: Colors.black26, blurRadius: 3.0, spreadRadius: 2.0)],
                      ),
                      tabs: [
                        PaymentViewCustomTab(
                          text: "Payments",
                          isSelected: tabController.index == 0,
                        ),
                        PaymentViewCustomTab(
                          text: "Invoices",
                          isSelected: tabController.index == 1,
                        ),
                        if (controller.value.userRole == "Finance User" ||
                            controller.value.userRole == "B2B Sales User/AM" ||
                            controller.value.userRole == "Retail Sales User" ||
                            controller.value.userRole == "Customer Support User" ||
                            controller.value.userRole == "Customer Admin" ||
                            controller.value.userRole == "Customer User" ||
                            controller.value.userRole == "Business Administrator" ||
                            controller.value.userRole == "Super Admin" ||
                            controller.value.userRole == "Call Center User")
                          PaymentViewCustomTab(
                            text: "Setoff Payments",
                            isSelected: tabController.index == 2,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            if (showPaymentCheckboxes)
                              AvailableBalanceCard(
                                name: "Selected Payment Amount",
                                size: selectedPaymentsStates.isNotEmpty
                                    ? formatAmount(selectedPaymentAmount.toString())
                                    : "0.00",
                                color: const Color(0xFF173C79),
                                fontColor: const Color(0xFFFFFFFF),
                              ),
                            if (showPaymentCheckboxes) const SizedBox(height: 10),
                            FutureBuilder(
                              future: action,
                              builder: (context, snapshot) {
                                return ValueListenableBuilder(
                                  valueListenable: locate<PaymentListService>(),
                                  builder: (context, snapshot, _) {
                                    if (snapshot.paymentList.isEmpty) {
                                      return const Center(
                                        child: FittedBox(child: Text("There are no Payments.")),
                                      );
                                    }
                                    snapshot.paymentList.sort((a, b) {
                                      DateTime dateA = DateFormat("yyyy-MM-dd").parse(a.postingDate!);
                                      DateTime dateB = DateFormat("yyyy-MM-dd").parse(b.postingDate!);
                                      return dateB.compareTo(dateA); // Descending order
                                    });
                                    return Column(
                                      children: snapshot.paymentList
                                          .asMap()
                                          .entries
                                          .map(
                                            (entry) => PaymentViewCard(
                                              index: entry.key,
                                              documentNo: entry.value.documentNo_FI.toString(),
                                              referenceNo: entry.value.reference ?? "N/A",
                                              date: entry.value.postingDate ?? "N/A",
                                              orderValue: (entry.value.amountDocCurrency!.endsWith('-')
                                                  ? "-${entry.value.amountDocCurrency!.substring(0, entry.value.amountDocCurrency!.length - 1)}"
                                                  : entry.value.amountDocCurrency!),
                                              documentType: entry.value.name ?? "N/A",
                                              documentType2: entry.value.documentType2 ?? "N/A",
                                              showCheckbox: showPaymentCheckboxes,
                                              isSelected: selectedPaymentsStates[entry.key] ?? false,
                                              onCheckboxSelected: (isSelected) {
                                                handlePaymentCheckboxSelection(
                                                    entry.key,
                                                    isSelected,
                                                    entry.value.name,
                                                    (entry.value.amountDocCurrency!.endsWith('-')
                                                        ? entry.value.amountDocCurrency!
                                                            .substring(0, entry.value.amountDocCurrency!.length - 1)
                                                        : entry.value.amountDocCurrency!),
                                                    entry.value.companyCode,
                                                    entry.value.customerCode,
                                                    entry.value.documentNo_FI,
                                                    entry.value.billingDoc,
                                                    entry.value.invoiceDoc,
                                                    entry.value.postingDate,
                                                    entry.value.documentDate,
                                                    entry.value.netDueDate,
                                                    entry.value.lineItem,
                                                    entry.value.amountDocCurrency,
                                                    entry.value.docCurrency,
                                                    entry.value.documentType,
                                                    entry.value.documentType2,
                                                    entry.value.customerPONumber,
                                                    entry.value.reference,
                                                    entry.value.overdueDays,
                                                    entry.value.overdueAmount,
                                                    entry.value.description,
                                                    entry.value.assignment,
                                                entry.value.specialGL);
                                              },
                                              borderColor: selectedPaymentsStates[entry.key] ?? false
                                                  ? Colors.red
                                                  : Colors.transparent,
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if (controller.value.userRole == "Finance User" ||
                                controller.value.userRole == "B2B Sales User/AM" ||
                                controller.value.userRole == "Retail Sales User" ||
                                controller.value.userRole == "Customer Support User" ||
                                controller.value.userRole == "Customer Admin" ||
                                controller.value.userRole == "Customer User" ||
                                controller.value.userRole == "Business Administrator" ||
                                controller.value.userRole == "Super Admin" ||
                                controller.value.userRole == "Call Center User")
                              AvailableBalanceCard(
                                name: "Selected Payment Amount",
                                size: selectedPaymentsStates.isNotEmpty
                                    ? formatAmount(selectedPaymentAmount.toString())
                                    : "0.00",
                                color: const Color(0xFF173C79),
                                fontColor: const Color(0xFFFFFFFF),
                              ),
                            if (controller.value.userRole == "Finance User" ||
                                controller.value.userRole == "B2B Sales User/AM" ||
                                controller.value.userRole == "Retail Sales User" ||
                                controller.value.userRole == "Customer Support User" ||
                                controller.value.userRole == "Customer Admin" ||
                                controller.value.userRole == "Customer User" ||
                                controller.value.userRole == "Business Administrator" ||
                                controller.value.userRole == "Super Admin" ||
                                controller.value.userRole == "Call Center User")
                              const SizedBox(height: 10),
                            if (controller.value.userRole == "Finance User" ||
                                controller.value.userRole == "B2B Sales User/AM" ||
                                controller.value.userRole == "Retail Sales User" ||
                                controller.value.userRole == "Customer Support User" ||
                                controller.value.userRole == "Customer Admin" ||
                                controller.value.userRole == "Customer User" ||
                                controller.value.userRole == "Business Administrator" ||
                                controller.value.userRole == "Super Admin" ||
                                controller.value.userRole == "Call Center User")
                              AvailableBalanceCard(
                                name: "Selected Invoices Amount",
                                size: selectedInvoicesStates.isNotEmpty
                                    ? formatAmount(selectedInvoiceAmount.toString())
                                    : "0.00",
                                color: const Color(0xFFFFA238),
                                fontColor: const Color(0xFFFFFFFF),
                              ),
                            if (controller.value.userRole == "Finance User" ||
                                controller.value.userRole == "B2B Sales User/AM" ||
                                controller.value.userRole == "Retail Sales User" ||
                                controller.value.userRole == "Customer Support User" ||
                                controller.value.userRole == "Customer Admin" ||
                                controller.value.userRole == "Customer User" ||
                                controller.value.userRole == "Business Administrator" ||
                                controller.value.userRole == "Super Admin" ||
                                controller.value.userRole == "Call Center User")
                              const SizedBox(height: 10),
                            if (controller.value.userRole == "Finance User" ||
                                controller.value.userRole == "B2B Sales User/AM" ||
                                controller.value.userRole == "Retail Sales User" ||
                                controller.value.userRole == "Customer Support User" ||
                                controller.value.userRole == "Customer Admin" ||
                                controller.value.userRole == "Customer User" ||
                                controller.value.userRole == "Business Administrator" ||
                                controller.value.userRole == "Super Admin" ||
                                controller.value.userRole == "Call Center User")
                              InvoiceCountCard(
                                name: "Invoices Count",
                                size: selectedInvoicesStates.length,
                                color: const Color(0xFFF0F0F0),
                                fontColor: const Color(0xFF000000),
                              ),
                            const SizedBox(height: 10),
                            ValueListenableBuilder(
                              valueListenable: locate<InvoiceListService>(),
                              builder: (context, snapshot, _) {
                                if (snapshot.invoiceList.isEmpty) {
                                  return const Center(
                                    child: FittedBox(child: Text("There are no Invoices.")),
                                  );
                                }
                                snapshot.invoiceList.sort((a, b) {
                                  DateTime dateA = DateFormat("yyyy-MM-dd").parse(a.postingDate!);
                                  DateTime dateB = DateFormat("yyyy-MM-dd").parse(b.postingDate!);
                                  return dateB.compareTo(dateA); // Descending order
                                });
                                return Column(
                                  children: snapshot.invoiceList
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => InvoiceViewCard(
                                          index: entry.key,
                                          invoiceNo: entry.value.invoiceDoc.toString(),
                                          date: entry.value.postingDate ?? "N/A",
                                          netAmount: formatAmount((entry.value.totalAfterSvat!.startsWith('-')
                                              ? "-${entry.value.totalAfterSvat!.substring(0, entry.value.totalAfterSvat!.length - 1)}"
                                              : entry.value.totalAfterSvat!)),
                                          amount: formatAmount((entry.value.amountDocCurrency!.startsWith('-')
                                              ? "-${entry.value.amountDocCurrency!.substring(0, entry.value.amountDocCurrency!.length - 1)}"
                                              : entry.value.amountDocCurrency!)),
                                          svat: entry.value.svat ?? "N/A",
                                          name: entry.value.name ?? "N/A",
                                          documentType2: entry.value.documentType2 ?? "N/A",
                                          showCheckbox: showInvoiceCheckboxes,
                                          isSelected: selectedInvoicesStates[entry.key] ?? false,
                                          onCheckboxSelected: (isSelected) {
                                            handleInvoiceCheckboxSelection(
                                                entry.key,
                                                isSelected,
                                                entry.value.name,
                                                (entry.value.totalAfterSvat!.endsWith('-')
                                                    ? entry.value.totalAfterSvat!
                                                        .substring(0, entry.value.totalAfterSvat!.length - 1)
                                                    : entry.value.totalAfterSvat!),
                                                entry.value.svat,
                                                entry.value.totalAfterSvat,
                                                entry.value.companyCode,
                                                entry.value.customerCode,
                                                entry.value.documentNo_FI,
                                                entry.value.billingDoc,
                                                entry.value.invoiceDoc,
                                                entry.value.postingDate,
                                                entry.value.documentDate,
                                                entry.value.netDueDate,
                                                entry.value.lineItem,
                                                entry.value.amountDocCurrency,
                                                entry.value.docCurrency,
                                                entry.value.documentType,
                                                entry.value.documentType2,
                                                entry.value.customerPONumber,
                                                entry.value.reference,
                                                entry.value.overdueDays,
                                                entry.value.overdueAmount,
                                                entry.value.description,
                                                entry.value.assignment,
                                            entry.value.specialGL);
                                          },
                                          borderColor: selectedInvoicesStates[entry.key] ?? false
                                              ? Colors.red
                                              : Colors.transparent,
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (controller.value.userRole == "Finance User" ||
                          controller.value.userRole == "B2B Sales User/AM" ||
                          controller.value.userRole == "Retail Sales User" ||
                          controller.value.userRole == "Customer Support User" ||
                          controller.value.userRole == "Customer Admin" ||
                          controller.value.userRole == "Customer User" ||
                          controller.value.userRole == "Business Administrator" ||
                          controller.value.userRole == "Super Admin" ||
                          controller.value.userRole == "Call Center User")
                        Column(
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: locate<PaymentSetoffListService>(),
                                      builder: (context, snapshot, _) {
                                        if (snapshot.setoffList.isEmpty) {
                                          return const Center(
                                            child: FittedBox(child: Text("There are no Setoff Payments.")),
                                          );
                                        }
                                        // Paginate the setoffList
                                        List<PaymentSetoffListDto> paginatedList = snapshot.setoffList
                                            .skip(currentPage * cardsPerPage)
                                            .take(cardsPerPage)
                                            .toList();

                                        paginatedList.sort((a, b) {
                                          DateTime dateA = DateFormat("yyyy-MM-dd").parse(a.createdDate!);
                                          DateTime dateB = DateFormat("yyyy-MM-dd").parse(b.createdDate!);
                                          return dateB.compareTo(dateA); // Descending order
                                        });
                                        return Column(
                                          children: paginatedList
                                              .map(
                                                (setOff) => SetoffPaymentViewCard(
                                                  invoiceNumbers: setOff.setOffInvoiceList
                                                          ?.map((invoice) => invoice.invoiceNo)
                                                          .toList() ??
                                                      ["N/A"],
                                                  paymentNumbers: setOff.setOffPaymentList
                                                          ?.map((payment) => payment.documentNo)
                                                          .toList() ??
                                                      ["N/A"],
                                                  referenceNo: setOff.reference ?? "N/A",
                                                  soldToCode: setOff.soldToCode ?? "N/A",
                                                ),
                                              )
                                              .toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios),
                                  onPressed: () {
                                    if (currentPage > 0) {
                                      setState(() {
                                        currentPage--;
                                      });
                                    }
                                  },
                                ),
                                Text('Page ${currentPage + 1}'),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  onPressed: () {
                                    // Check if there are more pages
                                    if ((currentPage + 1) * cardsPerPage <
                                        locate<PaymentSetoffListService>().value.setoffList.length) {
                                      setState(() {
                                        currentPage++;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class SelectedPayments {
  String? name;
  int? companyCode;
  String? customerCode;
  int? documentNo_FI;
  int? billingDoc;
  int? invoiceDoc;
  String? postingDate;
  String? documentDate;
  String? netDueDate;
  String? lineItem;
  String? amountDocCurrency;
  String? docCurrency;
  String? documentType;
  String? documentType2;
  String? customerPONumber;
  String? reference;
  String? overdueDays;
  String? overdueAmount;
  String? description;
  String? assignment;
  String? specialGL;

  SelectedPayments({
    this.name,
    this.companyCode,
    this.customerCode,
    this.documentNo_FI,
    this.billingDoc,
    this.invoiceDoc,
    this.postingDate,
    this.documentDate,
    this.netDueDate,
    this.lineItem,
    this.amountDocCurrency,
    this.docCurrency,
    this.documentType,
    this.documentType2,
    this.customerPONumber,
    this.reference,
    this.overdueDays,
    this.overdueAmount,
    this.description,
    this.assignment,
    this.specialGL,
  });
}

class SelectedInvoices {
  String? name;
  String? svat;
  String? totalAfterSvat;
  int? companyCode;
  String? customerCode;
  int? documentNo_FI;
  int? billingDoc;
  int? invoiceDoc;
  String? postingDate;
  String? documentDate;
  String? netDueDate;
  String? lineItem;
  String? amountDocCurrency;
  String? docCurrency;
  String? documentType;
  String? documentType2;
  String? customerPONumber;
  String? reference;
  String? overdueDays;
  String? overdueAmount;
  String? description;
  String? assignment;
  String? specialGL;

  SelectedInvoices({
    this.name,
    this.svat,
    this.totalAfterSvat,
    this.companyCode,
    this.customerCode,
    this.documentNo_FI,
    this.billingDoc,
    this.invoiceDoc,
    this.postingDate,
    this.documentDate,
    this.netDueDate,
    this.lineItem,
    this.amountDocCurrency,
    this.docCurrency,
    this.documentType,
    this.documentType2,
    this.customerPONumber,
    this.reference,
    this.overdueDays,
    this.overdueAmount,
    this.description,
    this.assignment,
    this.specialGL,
  });
}

class PaymentViewCustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const PaymentViewCustomTab({super.key, required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Center(
        child: FittedBox(
          child: MediaQuery.of(context).size.width >= 360
              ? Text(
                  text,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isSelected ? Colors.white : const Color(0xFF000000),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                )
              : Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : const Color(0xFF000000),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
        ),
      ),
    );
  }
}

class PaymentViewCard extends StatelessWidget {
  const PaymentViewCard({
    super.key,
    required this.index,
    required this.documentNo,
    required this.date,
    required this.orderValue,
    required this.referenceNo,
    required this.documentType,
    required this.documentType2,
    required this.showCheckbox,
    required this.onCheckboxSelected,
    required this.borderColor,
    required this.isSelected,
  });

  final int index;
  final String documentNo;
  final String date;
  final String orderValue;
  final String referenceNo;
  final String documentType;
  final String documentType2;
  final bool showCheckbox;
  final void Function(bool?) onCheckboxSelected;
  final Color borderColor;
  final bool isSelected;

  String formatAmount(String amount) {
    String filterAmount = (amount.startsWith('-') ? amount.substring(0, amount.length - 1) : amount);
    double numericAmount = double.tryParse(filterAmount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Flexible(
              flex: 10,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: borderColor, width: 2.0), // Add this line
                ),
                elevation: 3,
                child: Container(
                  color: Colors.white,
                  height: 120.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              "Document No",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              "Document No",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: MediaQuery.of(context).size.width >= 360
                                        ? Text(
                                            documentNo,
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                  color: const Color(0xFF000000),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                          )
                                        : Text(
                                            documentNo,
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              "Reference No",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              "Reference No",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              referenceNo,
                                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                            )
                                          : Text(
                                              referenceNo,
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                            )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        color: Color(0xFFD9D9D9),
                        thickness: 1,
                        height: 1,
                        indent: 12,
                        endIndent: 12,
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              "$documentType2 -",
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                    color: const Color(0xFF4A7A36),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            )
                                          : Text(
                                              "$documentType2 -",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF4A7A36),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            )),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              documentType,
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                  color: const Color(0xFF4A7A36), fontWeight: FontWeight.w400),
                                            )
                                          : Text(
                                              documentType,
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                  color: const Color(0xFF4A7A36), fontWeight: FontWeight.w400),
                                            )),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              date,
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                            )
                                          : Text(
                                              date,
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                            )),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: RichText(
                                      text: MediaQuery.of(context).size.width >= 360
                                          ? TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: "LKR ",
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                      color: const Color(0xFF4A7A36), fontWeight: FontWeight.w400),
                                                ),
                                                TextSpan(
                                                  text: formatAmount(orderValue),
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                      color: const Color(0xFF4A7A36), fontWeight: FontWeight.w700),
                                                ),
                                              ],
                                            )
                                          : TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: "LKR ",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                      color: const Color(0xFF4A7A36), fontWeight: FontWeight.w400),
                                                ),
                                                TextSpan(
                                                  text: formatAmount(orderValue),
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                      color: const Color(0xFF4A7A36), fontWeight: FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                    ),
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
            ),
            if (showCheckbox)
              Flexible(
                flex: 1,
                child: Checkbox(
                  value: isSelected,
                  checkColor: Colors.white,
                  activeColor: Colors.red,
                  onChanged: onCheckboxSelected,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InvoiceViewCard extends StatefulWidget {
  const InvoiceViewCard({
    super.key,
    required this.index,
    required this.invoiceNo,
    required this.date,
    required this.amount,
    required this.netAmount,
    required this.svat,
    required this.name,
    required this.documentType2,
    required this.showCheckbox,
    required this.onCheckboxSelected,
    required this.borderColor,
    required this.isSelected,
  });

  final int index;
  final String invoiceNo;
  final String date;
  final String amount;
  final String netAmount;
  final String svat;
  final String name;
  final String documentType2;
  final bool showCheckbox;
  final void Function(bool?) onCheckboxSelected;
  final Color borderColor;
  final bool isSelected;

  @override
  State<InvoiceViewCard> createState() => _InvoiceViewCardState();
}

class _InvoiceViewCardState extends State<InvoiceViewCard> {
  late SelectedCustomerController controller;

  @override
  void initState() {
    super.initState();
    controller = locate<SelectedCustomerController>();
    initializeQueryData();
  }

  initializeQueryData() async {
    controller = locate<SelectedCustomerController>();
  }

  void previewFile() async {
    try {
      locate<LoadingIndicatorController>().show();
      String path = await locate<RestService>().invoiceReportExport(
        invoiceNo: widget.invoiceNo,
      );
      await launchUrl(Uri.parse(path));
    } catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Invoice preview failed",
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Flexible(
              flex: 10,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: widget.borderColor, width: 2.0), // Add this line
                ),
                elevation: 3,
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.width >= 360 ? 180.0 : 155,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: MediaQuery.of(context).size.width >= 360
                                              ? Text(
                                                  "Invoice No",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )
                                              : Text(
                                                  "Invoice No",
                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: MediaQuery.of(context).size.width >= 360
                                            ? Text(
                                                widget.invoiceNo,
                                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                      color: const Color(0xFF000000),
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                              )
                                            : Text(
                                                widget.invoiceNo,
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                                          fit: BoxFit.scaleDown,
                                          child: MediaQuery.of(context).size.width >= 360
                                              ? Text(
                                                  "Created Date",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )
                                              : Text(
                                                  "Created Date",
                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )),
                                      FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: MediaQuery.of(context).size.width >= 360
                                              ? Text(
                                                  widget.date,
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                )
                                              : Text(
                                                  widget.date,
                                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                )),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: MediaQuery.of(context).size.width >= 360
                                              ? Text(
                                                  "Document Type",
                                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )
                                              : Text(
                                                  "Document Type",
                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )),
                                      FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: MediaQuery.of(context).size.width >= 360
                                              ? Text(
                                                  "${widget.documentType2} - ${widget.name}",
                                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                      color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                                                )
                                              : Text(
                                                  "${widget.documentType2} - ${widget.name}",
                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                      color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                                                )),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: previewFile,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.remove_red_eye_outlined,
                                              size: MediaQuery.of(context).size.width >= 360 ? 20 : 16,
                                            ),
                                            const SizedBox(width: 5),
                                            FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: MediaQuery.of(context).size.width >= 360
                                                    ? Text(
                                                        "Preview",
                                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                              color: const Color(0xFF000000),
                                                              fontWeight: FontWeight.w300,
                                                            ),
                                                      )
                                                    : Text(
                                                        "Preview",
                                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                              color: const Color(0xFF000000),
                                                              fontWeight: FontWeight.w300,
                                                            ),
                                                      )),
                                          ],
                                        ),
                                      ),
                                      FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: MediaQuery.of(context).size.width >= 360
                                              ? Text(
                                                  " ",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )
                                              : Text(
                                                  " ",
                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                )),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        color: Color(0xFFD9D9D9),
                        thickness: 1,
                        height: 1,
                        indent: 12,
                        endIndent: 12,
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              "Amount",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              "Amount",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              widget.amount,
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              widget.amount,
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              "SVAT",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              "SVAT",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              widget.svat,
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              widget.svat,
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              "Net Amount",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF4A7A36),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              "Net Amount",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF4A7A36),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MediaQuery.of(context).size.width >= 360
                                          ? Text(
                                              widget.netAmount,
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    color: const Color(0xFF4A7A36),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )
                                          : Text(
                                              widget.netAmount,
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: const Color(0xFF4A7A36),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            )),
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
            ),
            if (controller.value.userRole == "Finance User" ||
                controller.value.userRole == "B2B Sales User/AM" ||
                controller.value.userRole == "Retail Sales User" ||
                controller.value.userRole == "Customer Support User" ||
                controller.value.userRole == "Customer Admin" ||
                controller.value.userRole == "Customer User" ||
                controller.value.userRole == "Business Administrator" ||
                controller.value.userRole == "Super Admin" ||
                controller.value.userRole == "Call Center User")
              if (widget.showCheckbox)
                Flexible(
                  flex: 1,
                  child: Checkbox(
                    value: widget.isSelected,
                    checkColor: Colors.white,
                    activeColor: Colors.red,
                    onChanged: widget.onCheckboxSelected,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class SetoffPaymentViewCard extends StatelessWidget {
  const SetoffPaymentViewCard({
    Key? key,
    required this.paymentNumbers,
    required this.invoiceNumbers,
    required this.referenceNo,
    required this.soldToCode,
  }) : super(key: key);

  final List<String?> paymentNumbers;
  final List<String?> invoiceNumbers;
  final String referenceNo;
  final String soldToCode;

  @override
  Widget build(BuildContext context) {
    // Calculate the total height needed for invoice and payment numbers
    double totalHeight = calculateTotalHeight(context, invoiceNumbers.length, paymentNumbers.length);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 3,
          child: Container(
            color: Colors.white,
            height: totalHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: paymentNumbers.length > invoiceNumbers.length ? 4 : 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: MediaQuery.of(context).size.width >= 360
                                  ? Text(
                                      "Payment No",
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : Text(
                                      "Payment No",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                            ),
                            Column(
                              children: paymentNumbers.map((payment) {
                                return FittedBox(
                                  child: MediaQuery.of(context).size.width >= 360
                                      ? Text(
                                          payment ?? "N/A",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                        )
                                      : Text(
                                          payment ?? "N/A",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                        ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              child: MediaQuery.of(context).size.width >= 360
                                  ? Text(
                                      "Sold To Code",
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : Text(
                                      "Sold To Code",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                            ),
                            FittedBox(
                              child: MediaQuery.of(context).size.width >= 360
                                  ? Text(
                                      soldToCode,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                    )
                                  : Text(
                                      soldToCode,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: paymentNumbers.length > invoiceNumbers.length ? 3 : 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: MediaQuery.of(context).size.width >= 360
                                  ? Text(
                                      "Invoice No",
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : Text(
                                      "Invoice No",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                            ),
                            Column(
                              children: invoiceNumbers.map((invoice) {
                                return FittedBox(
                                  child: MediaQuery.of(context).size.width >= 360
                                      ? Text(
                                          invoice ?? "N/A",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                        )
                                      : Text(
                                          invoice ?? "N/A",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                        ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              child: MediaQuery.of(context).size.width >= 360
                                  ? Text(
                                      "Reference No",
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : Text(
                                      "Reference No",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                            ),
                            FittedBox(
                              child: MediaQuery.of(context).size.width >= 360
                                  ? Text(
                                      referenceNo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                    )
                                  : Text(
                                      referenceNo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w300),
                                    ),
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
      ),
    );
  }

  double calculateTotalHeight(BuildContext context, int numInvoiceNumbers, int numPaymentNumbers) {
    // Set a base height
    double baseHeight = MediaQuery.of(context).size.width >= 360 ? 60.0 : 40;

    // Calculate additional height based on the numbers of invoice and payment
    double additionalHeight = numInvoiceNumbers * 35.0 + numPaymentNumbers * 35.0;

    // Ensure the additional height is capped at a maximum value
    additionalHeight = additionalHeight.clamp(0.0, 140.0);

    // Calculate the total height by adding the base height and additional height
    return baseHeight + additionalHeight;
  }
}

class AvailableBalanceCard extends StatelessWidget {
  const AvailableBalanceCard({
    super.key,
    required this.name,
    required this.size,
    required this.color,
    required this.fontColor,
  });

  final String name;
  final String size;
  final Color color;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: SizedBox(
        height: 80,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: color,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: fontColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            "$size LKR",
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: fontColor,
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

class InvoiceCountCard extends StatelessWidget {
  const InvoiceCountCard({
    super.key,
    required this.name,
    required this.size,
    required this.color,
    required this.fontColor,
  });

  final String name;
  final int size;
  final Color color;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: SizedBox(
        height: 80,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: color,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: fontColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            size.toString(),
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: fontColor,
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

class PaymentSetoffButton extends StatefulWidget {
  final void Function()? onPressed;
  final TabController tabController;
  const PaymentSetoffButton({super.key, required this.onPressed, required this.tabController});

  @override
  State<PaymentSetoffButton> createState() => _PaymentSetoffButtonState();
}

class _PaymentSetoffButtonState extends State<PaymentSetoffButton> {
  int buttonPressCount = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 35,
        width: 100,
        child: FilledButton(
          onPressed: () {
            widget.onPressed?.call();
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: MaterialStateProperty.all(Colors.red.withOpacity(0.9)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Payment Setoff",
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatefulWidget {
  final void Function()? onPressed;
  final TabController tabController;
  final Map<int, bool> selectedPaymentsStates;
  const NextButton(
      {super.key, required this.onPressed, required this.tabController, required this.selectedPaymentsStates});

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  bool showCheckboxes = false;
  int buttonPressCount = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 35,
        width: 100,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: widget.selectedPaymentsStates.isEmpty
                ? MaterialStateProperty.all(Colors.grey)
                : MaterialStateProperty.all(Colors.red.withOpacity(0.9)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Next",
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InvoiceConfirmButton extends StatefulWidget {
  final void Function()? onPressed;
  final TabController tabController;
  final Map<int, bool> selectedInvoicesStates;
  const InvoiceConfirmButton(
      {super.key, required this.onPressed, required this.tabController, required this.selectedInvoicesStates});

  @override
  State<InvoiceConfirmButton> createState() => _InvoiceConfirmButtonState();
}

class _InvoiceConfirmButtonState extends State<InvoiceConfirmButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 35,
        width: 100,
        child: FilledButton(
          onPressed: widget.selectedInvoicesStates.isEmpty ? null : widget.onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: widget.selectedInvoicesStates.isEmpty
                ? MaterialStateProperty.all(Colors.grey)
                : MaterialStateProperty.all(Colors.red.withOpacity(0.9)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Confirm",
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
