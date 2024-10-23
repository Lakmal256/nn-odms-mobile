import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../../util/storage.dart';
import '../ui.dart';

class SelectedCustomerValue {
  String? userRole;
  String? shipTo;
  String? shipToName;
  String? soldToCode;
  String? soldToName;
  String? channelCode;
  String? salesOrganizationCode;
  String? salesOrganizationName;
  String? divisionCode;
  DashboardSummaryResponseDto? dashboardSummary;
  List<DetailDto>? divisionCodeList;
  List<DetailDto>? salesOrgCodeList;
  List<DataItemDto>? ytdGraphData;
  List<DataItemDto>? mtdGraphData;
  String? ytdData;
  String? mtdData;
  String? creditLimitAvailable;
  String? activeUsers;
  String chartType = "YTD View";
  List<BannerDto>? bannerList;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  SelectedCustomerValue.empty();

  SelectedCustomerValue copyWith({
    String? userRole,
    String? shipTo,
    String? shipToName,
    String? soldToCode,
    String? soldToName,
    String? channelCode,
    String? salesOrganizationCode,
    String? salesOrganizationName,
    String? divisionCode,
    DashboardSummaryResponseDto? dashboardSummary,
    List<DetailDto>? divisionCodeList,
    List<DetailDto>? salesOrgCodeList,
    List<DataItemDto>? ytdGraphData,
    List<DataItemDto>? mtdGraphData,
    String? ytdData,
    String? mtdData,
    String? creditLimitAvailable,
    String? activeUsers,
    String? chartType,
    List<BannerDto>? bannerList,
    Map<String, String>? errors,
  }) {
    return SelectedCustomerValue.empty()
      ..userRole = userRole ?? this.userRole
      ..shipTo = shipTo ?? this.shipTo
      ..shipToName = shipToName ?? this.shipToName
      ..soldToCode = soldToCode ?? this.soldToCode
      ..soldToName = soldToName ?? this.soldToName
      ..channelCode = channelCode ?? this.channelCode
      ..salesOrganizationCode = salesOrganizationCode ?? this.salesOrganizationCode
      ..salesOrganizationName = salesOrganizationName ?? this.salesOrganizationName
      ..divisionCode = divisionCode ?? this.divisionCode
      ..dashboardSummary = dashboardSummary ?? this.dashboardSummary
      ..divisionCodeList = divisionCodeList ?? this.divisionCodeList
      ..salesOrgCodeList = salesOrgCodeList ?? this.salesOrgCodeList
      ..ytdGraphData = ytdGraphData ?? this.ytdGraphData
      ..mtdGraphData = mtdGraphData ?? this.mtdGraphData
      ..mtdData = mtdData ?? this.mtdData
      ..ytdData = ytdData ?? this.ytdData
      ..creditLimitAvailable = creditLimitAvailable ?? this.creditLimitAvailable
      ..activeUsers = activeUsers ?? this.activeUsers
      ..chartType = chartType ?? this.chartType
      ..bannerList = bannerList ?? this.bannerList
      ..errors = errors ?? this.errors;
  }
}

class SelectedCustomerController extends FormController<SelectedCustomerValue> {
  SelectedCustomerController() : super(initialValue: SelectedCustomerValue.empty());

  clear() {
    value = SelectedCustomerValue.empty();
  }

  Future<void> getDivisionCode(String? selectedSoldToCode) async {
    if (selectedSoldToCode != null) {
      List<DetailDto>? codeList =
          await locate<RestService>().getCustomerDetailsBySoldToCode(soldToCode: selectedSoldToCode);
      if (codeList != null && codeList?.isEmpty == false) {
        setValue(value.copyWith(
          divisionCodeList: codeList,
          salesOrgCodeList: codeList,
          divisionCode: codeList.first.divisionCode,
          salesOrganizationCode: codeList.first.salesOrgCode,
          salesOrganizationName: codeList.first.salesOrgName,
        ));
        notifyListeners();
      }
    }
  }

  Future<void> getDashboardSummary() async {
    final String? soldToCode = value.soldToCode;
    final String? salesOrganizationCode = value.salesOrganizationCode;
    final String? divisionCode = value.divisionCode;

    final dashboardData = await locate<RestService>().fetchDashboardSummary(
      soldToCode: soldToCode!,
      salesOrganizationCode: salesOrganizationCode!,
      divisionCode: divisionCode!,
    );
    if (dashboardData != null) {
      setValue(value.copyWith(
        dashboardSummary: dashboardData,
      ));
      notifyListeners();
    }
  }

  Future<void> fetchGraphData() async {
    final String? soldToCode = value.soldToCode;
    final String? salesOrganizationCode = value.salesOrganizationCode;
    final String? divisionCode = value.divisionCode;
    final graphData = await locate<RestService>().orderVolumeGraph(
        soldToCode: soldToCode ?? "",
        salesOrganizationCode: salesOrganizationCode ?? "",
        divisionCode: divisionCode ?? "");
    if (graphData != null) {
      setValue(value.copyWith(
        mtdGraphData: graphData.result?.mtd?.data,
        ytdGraphData: graphData.result?.ytd?.data,
        mtdData: graphData.result?.mtd?.total,
        ytdData: graphData.result?.ytd?.total,
      ));
      notifyListeners();
    }
  }

  Future<void> fetchActiveUsers() async {
    final String? soldToCode = value.soldToCode;
    final activeUsers = await locate<RestService>().fetchActiveUserList(customerCode: soldToCode ?? "");
    if (activeUsers != null) {
      setValue(value.copyWith(
        activeUsers: activeUsers.length.toString(),
      ));
      notifyListeners();
    }
  }

  Future<void> getBannerList(String? selectedSoldToCode) async {
    if (selectedSoldToCode != null) {
      List<BannerDto>? bannerList = await locate<RestService>().fetchDashboardBanners(soldToCode: selectedSoldToCode);
      if (bannerList != null && bannerList.isEmpty == false) {
        setValue(value.copyWith(
          bannerList: bannerList,
        ));
        notifyListeners();
      }
    }
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, this.tableContent}) : super(key: key);

  final Widget? tableContent;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<DashboardSummaryResponseDto?>? action;
  DashboardSummaryResponseDto? dashboardSummary;
  UserResponseDto? user;
  List<ActiveUserDto>? activeUserCount;
  late SelectedCustomerController controller;
  late int currentBannerIndex;
  late Timer timer;

  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    initializeDashboard();
    currentBannerIndex = 0;
    startTimer();
    super.initState();
  }

  initializeDashboard() async {
    controller = locate<SelectedCustomerController>();
    await fetchDashboardData();
    checkTermsAndConditions();
  }

  fetchDashboardData() {
    setState(() {
      action = () async {
        final selectedCustomerController = locate<SelectedCustomerController>();
        Storage storage = Storage();
        String? email = await storage.readValue("email");
        final data = await locate<RestService>().getUserByEmail(email!);
        String? soldToCode = data!.customers?.first.soldToCode;
        user = data;

        if (data.roles?.first.roleName == "Call Center User" ||
            data.roles?.first.roleName == "Retail Sales User" ||
            data.roles?.first.roleName == "B2B Sales User/AM" ||
            data.roles?.first.roleName == "Business Administrator" ||
            data.roles?.first.roleName == "Customer Admin" ||
            data.roles?.first.roleName == "Customer User" ||
            data.roles?.first.roleName == "Commercial User") {
          final getCustomerDetail = await locate<RestService>().getCustomerDetailsBySoldToCode(soldToCode: soldToCode!);

          // Check if getCustomerDetail is not null and not empty
          if (getCustomerDetail != null && getCustomerDetail.isNotEmpty) {
            String? salesOrganizationCode = getCustomerDetail.first.salesOrgCode ?? "";
            String? divisionCode = getCustomerDetail.first.divisionCode ?? "";

            final dashboardData = await locate<RestService>().fetchDashboardSummary(
              soldToCode: soldToCode,
              salesOrganizationCode: salesOrganizationCode,
              divisionCode: divisionCode,
            );

            user = data;
            if (dashboardData != null) {
              selectedCustomerController.value.dashboardSummary = dashboardData;
              action = Future.value(dashboardData);
            } else {
              selectedCustomerController.value.dashboardSummary = null;
              action = Future.value(null);
            }
          } else {
            // Handle the case where getCustomerDetail is null or empty
            //set some default values.
            user = data;
            selectedCustomerController.value.dashboardSummary = null;
            action = Future.value(null);
          }
        } else {
          setState(() {
            user = data;
          });
        }
        final getCustomerDetail = await locate<RestService>().getCustomerDetailsBySoldToCode(soldToCode: soldToCode!);
        final graphData = await locate<RestService>().orderVolumeGraph(
          soldToCode: soldToCode ?? "",
          salesOrganizationCode: getCustomerDetail?.first.salesOrgCode ?? "",
          divisionCode: getCustomerDetail?.first.divisionCode ?? "",
        );
        controller.setValue(controller.value.copyWith(
          mtdGraphData: graphData?.result?.mtd?.data,
          ytdGraphData: graphData?.result?.ytd?.data,
          mtdData: (graphData?.result?.mtd?.total),
          ytdData: graphData?.result?.ytd?.total,
        ));
        setState(() {});
        if (data.roles?.first.roleName == "IT Administrator") {
          activeUserCount = await locate<RestService>().fetchActiveUserList(customerCode: soldToCode!);
        }
        final bannerList = await locate<RestService>().fetchDashboardBanners(soldToCode: soldToCode);
        if (bannerList != null && bannerList.isNotEmpty) {
          controller.setValue(controller.value.copyWith(
            bannerList: bannerList,
          ));
        }
      }.call();
    });
  }

  void startTimer() {
    // Set up a timer to change the image every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Update the index and trigger a rebuild
      setState(() {
        if (controller.value.bannerList != null && controller.value.bannerList!.isNotEmpty) {
          currentBannerIndex = (currentBannerIndex + 1) % controller.value.bannerList!.length;
        }
      });
    });
  }

  void checkTermsAndConditions() async {
    Storage storage = Storage();
    String? email = await storage.readValue("email");
    final data = await locate<RestService>().getUserByEmail(email!);
    int? userId = data?.id;
    String? userRole = data?.roles?.first.roleName;
    bool? termsAndConditions = data?.termsAccepted;
    // If terms are not accepted, show the dialog
    if (termsAndConditions != true && (userRole == "Customer Admin" || userRole == "Customer User")) {
      bool? ok = await showCustomerTncConfirmationDialog(context);

      if (ok != null && ok) {
        await locate<RestService>().termsAndConditions(userId!, true);
      }
      return;
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: action,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const AppBarWithTM(),
            body: SingleChildScrollView(
              child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, customerValue, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user?.roles?.first.roleName == "Finance User")
                          const Column(
                            children: [
                              SizedBox(height: 20),
                              FinanceUser(),
                            ],
                          )
                        else if (user?.roles?.first.roleName == "Customer Support User")
                          const Column(
                            children: [
                              SizedBox(height: 20),
                              CustomerSupportUser(),
                            ],
                          )
                        else if (user?.roles?.first.roleName == "Transporter")
                          const Column(
                            children: [
                              SizedBox(height: 20),
                              TransporterUser(),
                            ],
                          ),
                        if ((user?.roles?.first.roleName == "Customer Admin" ||
                                user?.roles?.first.roleName == "Customer User") &&
                            (controller.value.bannerList == null || controller.value.bannerList!.isEmpty))
                          Container(
                            height: MediaQuery.of(context).size.height / 4.5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                image: AssetImage("assets/images/dashboard/dashboard.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        if ((user?.roles?.first.roleName == "Customer Admin" ||
                                user?.roles?.first.roleName == "Customer User") &&
                            (controller.value.bannerList != null && controller.value.bannerList!.isNotEmpty))
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 4.5,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500), // Set the duration for the fading effect
                              child: FadeTransition(
                                key: ValueKey<int>(currentBannerIndex),
                                opacity: const AlwaysStoppedAnimation<double>(1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          controller.value.bannerList![currentBannerIndex].contentMobileImageUrl ?? ""),
                                      fit: BoxFit.fill, // Adjust BoxFit property as needed
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (user?.roles?.first.roleName == "Call Center User" ||
                            user?.roles?.first.roleName == "Retail Sales User" ||
                            user?.roles?.first.roleName == "B2B Sales User/AM" ||
                            user?.roles?.first.roleName == "Business Administrator" ||
                            user?.roles?.first.roleName == "Customer Admin" ||
                            user?.roles?.first.roleName == "Customer User" ||
                            user?.roles?.first.roleName == "Commercial User" ||
                            user?.roles?.first.roleName == "Logistics Other" ||
                            user?.roles?.first.roleName == "DPMC User" ||
                            user?.roles?.first.roleName == "IT Administrator" ||
                            user?.roles?.first.roleName == "Super Admin")
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: OVSView(),
                          ),
                        const SizedBox(height: 10),
                        if ((user?.roles?.first.roleName == "Call Center User" ||
                                user?.roles?.first.roleName == "Retail Sales User" ||
                                user?.roles?.first.roleName == "B2B Sales User/AM" ||
                                user?.roles?.first.roleName == "Business Administrator" ||
                                user?.roles?.first.roleName == "Customer Admin" ||
                                user?.roles?.first.roleName == "Customer User" ||
                                user?.roles?.first.roleName == "Commercial User" ||
                                user?.roles?.first.roleName == "Logistics Other" ||
                                user?.roles?.first.roleName == "DPMC User" ||
                                user?.roles?.first.roleName == "IT Administrator") &&
                            (controller.value.ytdGraphData?.isNotEmpty == true ||
                                controller.value.mtdGraphData?.isNotEmpty == true))
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: DashboardGraph(),
                          ),
                        if (((controller.value.ytdGraphData?.isEmpty == true ||
                                    controller.value.mtdGraphData?.isEmpty == true) ||
                                (controller.value.ytdGraphData == null || controller.value.mtdGraphData == null)) &&
                            (user?.roles?.first.roleName == "Call Center User" ||
                                user?.roles?.first.roleName == "Retail Sales User" ||
                                user?.roles?.first.roleName == "B2B Sales User/AM" ||
                                user?.roles?.first.roleName == "Business Administrator" ||
                                user?.roles?.first.roleName == "Customer Admin" ||
                                user?.roles?.first.roleName == "Customer User" ||
                                user?.roles?.first.roleName == "Commercial User" ||
                                user?.roles?.first.roleName == "Logistics Other" ||
                                user?.roles?.first.roleName == "DPMC User" ||
                                user?.roles?.first.roleName == "IT Administrator"))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50.0),
                            child: Center(
                              child: Text(
                                "No Graph Data Available",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        if (user?.roles?.first.roleName == "Call Center User" ||
                            user?.roles?.first.roleName == "Retail Sales User")
                          CallCenterRetailSalesUsers(
                              orderVolume: customerValue.dashboardSummary?.orderVolumeValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.orderVolumeValue ?? "N/A"
                                  : "N/A")
                        else if (user?.roles?.first.roleName == "B2B Sales User/AM")
                          B2BSalesUser(
                              orderVolume: customerValue.dashboardSummary?.orderVolumeValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.orderVolumeValue ?? "N/A"
                                  : "N/A",
                              totalOutstanding:
                                  customerValue.dashboardSummary?.totalOutstandingValue?.isNotEmpty == true
                                      ? customerValue.dashboardSummary?.totalOutstandingValue ?? "N/A"
                                      : "N/A",
                              OSOQuantity: customerValue.dashboardSummary?.orderVolumeValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.orderVolumeValue ?? "N/A"
                                  : "N/A")
                        else if (user?.roles?.first.roleName == "Business Administrator")
                          BusinessAdmin(
                              orderVolume: customerValue.dashboardSummary?.orderVolumeValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.orderVolumeValue ?? "N/A"
                                  : "N/A",
                              totalOutstanding:
                                  customerValue.dashboardSummary?.totalOutstandingValue?.isNotEmpty == true
                                      ? customerValue.dashboardSummary?.totalOutstandingValue ?? "N/A"
                                      : "N/A",
                              overdueAmount: customerValue.dashboardSummary?.overDueAmountValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.overDueAmountValue ?? "N/A"
                                  : "N/A")
                        else if (user?.roles?.first.roleName == "Customer Admin" ||
                            user?.roles?.first.roleName == "Customer User")
                          CustomerAdmin(
                            orderVolume: customerValue.dashboardSummary?.orderVolumeValue?.isNotEmpty == true
                                ? customerValue.dashboardSummary?.orderVolumeValue ?? "0.0"
                                : "0.0",
                            creditLimitLimitExceeded: customerValue.dashboardSummary?.credit.isNotEmpty == true
                                ? customerValue.dashboardSummary?.credit.first.creditLimitLimitExceeded ?? false
                                : false,
                            creditLimit: customerValue.dashboardSummary?.credit.isNotEmpty == true
                                ? customerValue.dashboardSummary?.credit.first.creditLimitValue ?? "N/A"
                                : "N/A",
                            overDueAmount: customerValue.dashboardSummary?.overDueAmountValue?.isNotEmpty == true
                                ? customerValue.dashboardSummary?.overDueAmountValue ?? "0.00"
                                : "0.00",
                            totalOutstanding: customerValue.dashboardSummary?.totalOutstandingValue?.isNotEmpty == true
                                ? customerValue.dashboardSummary?.totalOutstandingValue ?? "N/A"
                                : "N/A",
                          )
                        else if (user?.roles?.first.roleName == "Commercial User")
                          CommercialUser(
                              orderVolume: customerValue.dashboardSummary?.orderVolumeValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.orderVolumeValue ?? "N/A"
                                  : "N/A",
                              dailyInvoicedVolume:
                                  customerValue.dashboardSummary?.dailyInvoicedVolumeValue?.isNotEmpty == true
                                      ? customerValue.dashboardSummary?.dailyInvoicedVolumeValue ?? "N/A"
                                      : "N/A",
                              overdueAmount: customerValue.dashboardSummary?.overDueAmountValue?.isNotEmpty == true
                                  ? customerValue.dashboardSummary?.overDueAmountValue ?? "N/A"
                                  : "N/A",
                              totalOutstanding:
                                  customerValue.dashboardSummary?.totalOutstandingValue?.isNotEmpty == true
                                      ? customerValue.dashboardSummary?.totalOutstandingValue ?? "N/A"
                                      : "N/A")
                        else if (user?.roles?.first.roleName == "Logistics Other")
                          const LogisticsUser()
                        else if (user?.roles?.first.roleName == "IT Administrator")
                          ITAdmin(activeUsers: customerValue.activeUsers ?? "0")
                        else if (user?.roles?.first.roleName == "DPMC User")
                          const DPMCUser(),
                        const SizedBox(height: 25),
                        if (user?.roles?.first.roleName == "Commercial User") const LogisticsUser(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ActionView(roleName: user?.roles?.first.roleName ?? "N/A"),
                        ),
                      ],
                    );
                  }),
            ),
          );
        });
  }
}

class OVSView extends StatefulWidget {
  const OVSView({Key? key}) : super(key: key);

  @override
  State<OVSView> createState() => _OVSViewState();
}

class _OVSViewState extends State<OVSView> {
  late Future<UserResponseDto?> action;
  late SelectedCustomerController controller;
  UserResponseDto? userData;
  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetchData() {
    setState(() {
      action = () async {
        try {
          final selectedCustomerController = locate<SelectedCustomerController>();
          Storage storage = Storage();
          String? email = await storage.readValue("email");
          final userResponseData = await locate<RestService>().getUserByEmail(email!);
          if (mounted) {
            userData = userResponseData;
            selectedCustomerController.setValue(selectedCustomerController.value.copyWith(
              userRole: userResponseData?.roles?.first.roleName,
              soldToCode: userResponseData?.customers?.first.soldToCode,
            ));
            if (userResponseData != null && userResponseData.customers?.isNotEmpty == true) {
              List<DetailDto>? codeList = await locate<RestService>().getCustomerDetailsBySoldToCode(
                soldToCode: userResponseData.customers?.first.soldToCode! ?? "",
              );

              if (codeList != null && codeList.isNotEmpty) {
                selectedCustomerController.setValue(selectedCustomerController.value.copyWith(
                  soldToCode: userResponseData.customers?.first.soldToCode,
                  soldToName: userResponseData.customers?.first.name,
                  salesOrganizationCode: codeList.first.salesOrgCode,
                  salesOrganizationName: codeList.first.salesOrgName,
                  divisionCode: codeList.first.divisionCode,
                ));
              }
            }
          }
        } catch (error) {
          return null;
        }
      }.call();
    });
  }

  void showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, customerValue, child) {
              return AlertDialog(
                title: Text(
                  "Filter Your Details",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                content: const SizedBox(
                  height: 270,
                  child: Column(
                    children: [
                      DashboardCustomerCard(),
                      SizedBox(height: 10),
                      DashboardOrganizationCard(),
                      SizedBox(height: 10),
                      DashboardDivisionCard(),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  void showSelectionSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, customerValue, child) {
              return AlertDialog(
                title: Text(
                  "Filter Your Details",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                content: const SizedBox(
                  height: 270,
                  child: Column(
                    children: [
                      DashboardCustomerSearchCard(),
                      SizedBox(height: 10),
                      DashboardOrganizationCard(),
                      SizedBox(height: 10),
                      DashboardDivisionCard(),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, customerValue, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (customerValue.userRole != "Super Admin")
                    Text("Volume Performance", style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  if (customerValue.userRole == "Customer Admin" ||
                      customerValue.userRole == "Customer User" ||
                      customerValue.userRole == "B2B Sales User/AM")
                    IconButton(
                        onPressed: () {
                          showSelectionDialog(context);
                        },
                        icon: const Icon(Icons.tune_outlined)),
                  if (customerValue.userRole == "Call Center User" ||
                      customerValue.userRole == "Retail Sales User" ||
                      customerValue.userRole == "Business Administrator" ||
                      customerValue.userRole == "Commercial User" ||
                      customerValue.userRole == "Logistics Other" ||
                      customerValue.userRole == "DPMC User" ||
                      customerValue.userRole == "IT Administrator" ||
                      customerValue.userRole == "Super Admin")
                    IconButton(
                        onPressed: () {
                          showSelectionSearchDialog(context);
                        },
                        icon: const Icon(Icons.tune_outlined)),
                ],
              ),
              const SizedBox(height: 5),
              if (customerValue.userRole != "Super Admin")
                Row(
                  children: [
                    CardBase(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "YTD Volume",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${formatAmount(customerValue.ytdData ?? "0.0")} Mt",
                                style:
                                    Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xFFFF0000)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CardBase(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "MTD Volume",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${formatAmount(customerValue.mtdData ?? "0.0")} Mt",
                                style:
                                    Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xFFFF0000)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Chart Type",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "Chart Type",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(0, 20),
                          child: Container(
                            width: 105,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    customerValue.chartType,
                                    style: MediaQuery.of(context).size.width >= 360
                                        ? Theme.of(context).textTheme.titleSmall!.copyWith(
                                              color: Colors.black,
                                            )
                                        : Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: Colors.black,
                                            ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black, size: MediaQuery.of(context).size.width >= 360 ? 14 : 12),
                                ],
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            controller.setValue(controller.value..chartType = value);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: "YTD View",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                                  child: Text(
                                    "YTD View",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "MTD View",
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                                  child: Text(
                                    "MTD View",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
            ],
          );
        });
  }
}

class CardBase extends StatelessWidget {
  const CardBase({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}

class DashboardLineChartData extends LineChartData {
  final List<DataItemDto>? ytdData;
  final List<DataItemDto>? mtdData;
  SelectedCustomerController controller;
  DashboardLineChartData(BuildContext context, this.ytdData, this.mtdData, this.controller)
      : super(
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (barData, indexes) => indexes
                .map(
                  (e) => TouchedSpotIndicatorData(
                    FlLine(color: barData.color, dashArray: [5, 3]),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, value, data, index) =>
                          FlDotCirclePainter(strokeColor: Colors.white, color: data.color),
                    ),
                  ),
                )
                .toList(),
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              tooltipBorder: const BorderSide(
                width: 1,
                color: Colors.black26,
              ),
              tooltipBgColor: Colors.white,
              fitInsideHorizontally: true,
              getTooltipItems: (List<LineBarSpot> lineBars) {
                return lineBars.map((lineBar) {
                  final xAxis = controller.value.chartType == "YTD View" ? getMonthName(lineBar.x.toInt()) : getDay(lineBar.x.toInt());
                  return LineTooltipItem(
                    "${lineBar.y} Mt\n",
                    Theme.of(context).textTheme.titleMedium!,
                    textAlign: TextAlign.center,
                    children: [
                      TextSpan(
                        text: xAxis, // Modify this as needed
                        style: const TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) => controller.value.chartType == "YTD View" ? _monthBottomTitleWidgets(value, meta, context) : _dayBottomTitleWidgets(value, meta, context),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              barWidth: 2,
              isCurved: true,
              isStrokeCapRound: true,
              preventCurveOverShooting: true,
              dotData: FlDotData(show: false),
              spots: controller.value.chartType == "YTD View" ? ytdData?.map((item) {
                    final xValue = monthNameToValue(item.key);
                    return FlSpot(xValue.toDouble(), item.value ?? 0);
                  }).toList() ??
                  [] : mtdData?.map((item) {
                final xValue = dayToValue(item.key);
                return FlSpot(xValue.toDouble(), item.value ?? 0);
              }).toList() ??
                  [],
              color: const Color(0xFFFF0000),
              belowBarData: BarAreaData(
                show: true,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.mirror,
                  colors: [
                    Color(0x88FF0000),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ],
        );

  static String getMonthName(int monthValue) {
    switch (monthValue) {
      case 0:
        return 'January';
      case 1:
        return 'February';
      case 2:
        return 'March';
      case 3:
        return 'April';
      case 4:
        return 'May';
      case 5:
        return 'June';
      case 6:
        return 'July';
      case 7:
        return 'August';
      case 8:
        return 'September';
      case 9:
        return 'October';
      case 10:
        return 'November';
      case 11:
        return 'December';
      default:
        return '';
    }
  }

  static String getDay(int dayValue) {
    switch (dayValue) {
      case 0:
        return '1';
      case 1:
        return '2';
      case 2:
        return '3';
      case 3:
        return '4';
      case 4:
        return '5';
      case 5:
        return '6';
      case 6:
        return '7';
      case 7:
        return '8';
      case 8:
        return '9';
      case 9:
        return '10';
      case 10:
        return '11';
      case 11:
        return '12';
      case 12:
        return '13';
      case 13:
        return '14';
      case 14:
        return '15';
      case 15:
        return '16';
      case 16:
        return '17';
      case 17:
        return '18';
      case 18:
        return '19';
      case 19:
        return '20';
      case 20:
        return '21';
      case 21:
        return '22';
      case 22:
        return '23';
      case 23:
        return '24';
      case 24:
        return '25';
      case 25:
        return '26';
      case 26:
        return '27';
      case 27:
        return '28';
      case 28:
        return '29';
      case 29:
        return '30';
      case 30:
        return '31';
      default:
        return '';
    }
  }

  static int monthNameToValue(String? monthName) {
    switch (monthName?.toLowerCase()) {
      case 'january':
        return 0;
      case 'february':
        return 1;
      case 'march':
        return 2;
      case 'april':
        return 3;
      case 'may':
        return 4;
      case 'june':
        return 5;
      case 'july':
        return 6;
      case 'august':
        return 7;
      case 'september':
        return 8;
      case 'october':
        return 9;
      case 'november':
        return 10;
      case 'december':
        return 11;
      default:
        return 0;
    }
  }

  static int dayToValue(String? day) {
    switch (day?.toLowerCase()) {
      case '1':
        return 0;
      case '2':
        return 1;
      case '3':
        return 2;
      case '4':
        return 3;
      case '5':
        return 4;
      case '6':
        return 5;
      case '7':
        return 6;
      case '8':
        return 7;
      case '9':
        return 8;
      case '10':
        return 9;
      case '11':
        return 10;
      case '12':
        return 11;
      case '13':
        return 12;
      case '14':
        return 13;
      case '15':
        return 14;
      case '16':
        return 15;
      case '17':
        return 16;
      case '18':
        return 17;
      case '19':
        return 18;
      case '20':
        return 19;
      case '21':
        return 20;
      case '22':
        return 21;
      case '23':
        return 22;
      case '24':
        return 23;
      case '25':
        return 24;
      case '26':
        return 25;
      case '27':
        return 26;
      case '28':
        return 27;
      case '29':
        return 28;
      case '30':
        return 29;
      case '31':
        return 30;
      default:
        return 0;
    }
  }

  static Widget _monthBottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '   Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec   ';
        break;
      default:
        return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: MediaQuery.of(context).size.width < 360 ? 5 : 8),
          ),
        ),
      ),
    );
  }

  static Widget _dayBottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = ' 1';
        break;
      case 1:
        text = '2';
        break;
      case 2:
        text = '3';
        break;
      case 3:
        text = '4';
        break;
      case 4:
        text = '5';
        break;
      case 5:
        text = '6';
        break;
      case 6:
        text = '7';
        break;
      case 7:
        text = '8';
        break;
      case 8:
        text = '9';
        break;
      case 9:
        text = '10';
        break;
      case 10:
        text = '11';
        break;
      case 11:
        text = '12';
        break;
      case 12:
        text = '13';
        break;
      case 13:
        text = '14';
        break;
      case 14:
        text = '15';
        break;
      case 15:
        text = '16';
        break;
      case 16:
        text = '17';
        break;
      case 17:
        text = '18';
        break;
      case 18:
        text = '19';
        break;
      case 19:
        text = '20';
        break;
      case 20:
        text = ' 21 ';
        break;
      case 21:
        text = ' 22 ';
        break;
      case 22:
        text = ' 23 ';
        break;
      case 23:
        text = ' 24 ';
        break;
      case 24:
        text = ' 25 ';
        break;
      case 25:
        text = ' 26 ';
        break;
      case 26:
        text = ' 27 ';
        break;
      case 27:
        text = ' 28 ';
        break;
      case 28:
        text = ' 29 ';
        break;
      case 29:
        text = ' 30 ';
        break;
      case 30:
        text = ' 31  ';
        break;
      default:
        return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: MediaQuery.of(context).size.width < 360 ? 5 : 8),
          ),
        ),
      ),
    );
  }
}

class DashboardGraph extends StatefulWidget {
  const DashboardGraph({Key? key}) : super(key: key);

  @override
  State<DashboardGraph> createState() => _DashboardGraphState();
}

class _DashboardGraphState extends State<DashboardGraph> {
  late SelectedCustomerController controller;
  List<DataItemDto>? ytdData;
  List<DataItemDto>? mtdData;
  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, snapshot, child) {
          return AspectRatio(
            aspectRatio: 1.8,
            child: LineChart(
                DashboardLineChartData(context, controller.value.ytdGraphData, controller.value.mtdGraphData, controller)),
          );
        });
  }
}

class ActionView extends StatelessWidget {
  const ActionView({Key? key, required this.roleName}) : super(key: key);
  final String roleName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (roleName == "B2B Sales User/AM" ||
              roleName == "Customer Admin" ||
              roleName == "Customer User" ||
              roleName == "Business Administrator")
            ActionItem(
              path: "/view-recent-payments",
              icon: Image.asset(
                "assets/images/dashboard/time-is-money.png",
                color: Colors.grey,
              ),
              text: "Recent\nPayments",
            ),
          if (roleName == "Call Center User" ||
              roleName == "Retail Sales User" ||
              roleName == "Customer Admin" ||
              roleName == "Customer User" ||
              roleName == "Business Administrator")
            ActionItem(
              path: "/view-recent-sales-orders",
              icon: Image.asset(
                "assets/images/dashboard/credit-card.png",
                color: Colors.grey,
              ),
              text: "Recent\nSales Order",
            ),
          if (roleName == "Call Center User" ||
              roleName == "B2B Sales User/AM" ||
              roleName == "Retail Sales User" ||
              roleName == "Customer Admin" ||
              roleName == "Customer User" ||
              roleName == "Business Administrator")
            ActionItem(
              path: "/view-recent-deliveries",
              icon: Image.asset(
                "assets/images/dashboard/delivery-truck.png",
                color: Colors.grey,
              ),
              text: "Recent\nDeliveries",
            ),
          if (roleName == "Call Center User")
            ActionItem(
              path: "/view-pending-delivered-orders",
              icon: Image.asset(
                "assets/images/dashboard/work-in-progress.png",
                color: Colors.grey,
              ),
              text: "Pending\nDelivered Orders",
            ),
          if (roleName == "Call Center User" ||
              roleName == "B2B Sales User/AM" ||
              roleName == "Retail Sales User" ||
              roleName == "Business Administrator")
            ActionItem(
              path: "/view-latest-block-sales-orders",
              icon: Image.asset(
                "assets/images/dashboard/blocked.png",
                color: Colors.grey,
              ),
              text: "Latest Blocked\nSales Orders",
            ),
          if (roleName == "Business Administrator")
            ActionItem(
              path: "/view-active-user-list",
              icon: Image.asset(
                "assets/images/dashboard/check.png",
                color: Colors.grey,
              ),
              text: "Active\nUsers",
            ),
        ],
      ),
    );
  }
}

class ActionItem extends StatelessWidget {
  const ActionItem({
    Key? key,
    required this.path,
    required this.icon,
    required this.text,
  }) : super(key: key);

  final String path;
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 3,
        child: InkWell(
          onTap: () => GoRouter.of(context).push(
            path,
          ),
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            width: 120,
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: icon,
                  ),
                ),
                AspectRatio(
                  aspectRatio: 2.5,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CallCenterRetailSalesUsers extends StatelessWidget {
  const CallCenterRetailSalesUsers({Key? key, required this.orderVolume}) : super(key: key);
  final String orderVolume;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 6,
      children: [
        CardBase(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Today's\nOrder Volume",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFF0A4977)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("$orderVolume Mt",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class B2BSalesUser extends StatelessWidget {
  const B2BSalesUser({Key? key, required this.orderVolume, required this.totalOutstanding, required this.OSOQuantity})
      : super(key: key);
  final String orderVolume;
  final String totalOutstanding;
  final String OSOQuantity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          crossAxisCount: 2,
          childAspectRatio: 3,
          children: [
            CardBase(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 360 ? 6 : 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Today’s\nOrder Volume",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width < 360 ? 55 : 75,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: const BoxDecoration(color: Color(0xFF0A4977)),
                    child: Text(
                      "$orderVolume Mt",
                      style: MediaQuery.of(context).size.width < 360
                          ? Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white, fontWeight: FontWeight.w700)
                          : Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
            ),
            CardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Total Outstanding",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      decoration: const BoxDecoration(color: Color(0xFF1AC06E)),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "${totalOutstanding} LKR",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          crossAxisCount: 1,
          childAspectRatio: 6,
          children: [
            CardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Open Sales Order Quantity",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      decoration: const BoxDecoration(color: Color(0xFFA0A0A0)),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "${OSOQuantity} LKR",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class CustomerAdmin extends StatelessWidget {
  const CustomerAdmin(
      {Key? key,
      required this.orderVolume,
      required this.creditLimitLimitExceeded,
      required this.creditLimit,
      required this.overDueAmount,
      required this.totalOutstanding})
      : super(key: key);
  final String orderVolume;
  final bool creditLimitLimitExceeded;
  final String creditLimit;
  final String overDueAmount;
  final String totalOutstanding;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 15,
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        CardBase(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 360 ? 6 : 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Today’s\nOrder Volume",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width < 360 ? 55 : 75,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(color: Color(0xFF0A4977)),
                child: Text(
                  "$orderVolume Mt",
                  style: MediaQuery.of(context).size.width < 360
                      ? Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700)
                      : Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              )
            ],
          ),
        ),
        CardBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Credit Availability",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      if (creditLimitLimitExceeded.toString() == "true")
                        const Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: (Text("Limit Exceeded",
                                style: TextStyle(color: Color(0xFFFC6363), fontWeight: FontWeight.w500, fontSize: 10))),
                          ),
                        )
                      else
                        const Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: (Text("Within Limit",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 10))),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFFFC6363)),
                  child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    child: Text(
                      "${creditLimit} LKR",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        CardBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Overdue Amount",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFFA0A0A0)),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "$overDueAmount LKR",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        CardBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Total Outstanding",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFF1AC06E)),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text("${totalOutstanding} LKR",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BusinessAdmin extends StatelessWidget {
  const BusinessAdmin(
      {Key? key, required this.orderVolume, required this.totalOutstanding, required this.overdueAmount})
      : super(key: key);
  final String orderVolume;
  final String totalOutstanding;
  final String overdueAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          crossAxisCount: 1,
          childAspectRatio: 6,
          children: [
            CardBase(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Today's\nOrder Volume",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      decoration: const BoxDecoration(color: Color(0xFF0A4977)),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("$orderVolume Mt",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          crossAxisCount: 2,
          childAspectRatio: 3,
          children: [
            CardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Overdue Amount",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      decoration: const BoxDecoration(color: Color(0xFFA0A0A0)),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "$overdueAmount LKR",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            CardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Total Outstanding",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      decoration: const BoxDecoration(color: Color(0xFF1AC06E)),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "${totalOutstanding} LKR",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class FinanceUser extends StatelessWidget {
  const FinanceUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 3,
      children: [
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-last-invoice-list"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/bill.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF1AC06E),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Latest\nInvoice List",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-recent-payments"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/time-is-money.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF173C79),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Recent\nPayments",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-latest-block-sales-orders"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/blocked.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFA238),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Latest Blocked\nSales Orders",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CommercialUser extends StatelessWidget {
  const CommercialUser(
      {Key? key,
      required this.orderVolume,
      required this.dailyInvoicedVolume,
      required this.overdueAmount,
      required this.totalOutstanding})
      : super(key: key);
  final String orderVolume;
  final String dailyInvoicedVolume;
  final String overdueAmount;
  final String totalOutstanding;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 15,
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        CardBase(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 360 ? 6 : 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Today’s\nOrder Volume",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width < 360 ? 55 : 75,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(color: Color(0xFF0A4977)),
                child: Text(
                  "$orderVolume Mt",
                  style: MediaQuery.of(context).size.width < 360
                      ? Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700)
                      : Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              )
            ],
          ),
        ),
        CardBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Daily Invoiced Volume",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.black, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFFFC6363)),
                  child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    child: Text(
                      "$dailyInvoicedVolume Mt",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        CardBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Overdue Amount",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFFA0A0A0)),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "$overdueAmount LKR",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        CardBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text("Total Outstanding",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: const BoxDecoration(color: Color(0xFF1AC06E)),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "${totalOutstanding} LKR",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class LogisticsUser extends StatelessWidget {
  const LogisticsUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 3,
      children: [
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-pending-delivered-orders"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/work-in-progress.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF173C79),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Pending\nDelivered Order",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DPMCUser extends StatelessWidget {
  const DPMCUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 3,
      children: [
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-pending-delivered-orders"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/work-in-progress.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF173C79),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Pending\nDelivered Orders",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-recent-sales-orders"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/credit-card.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFA238),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Recent\nSales Orders",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-recent-deliveries"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/delivery-truck.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF1AC06E),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Recent\nDeliveries",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomerSupportUser extends StatelessWidget {
  const CustomerSupportUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 3,
      children: [
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-last-invoice-list"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/bill.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF1AC06E),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Latest\nInvoice List",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-recent-payments"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/time-is-money.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF173C79),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Recent\nPayments",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TransporterUser extends StatelessWidget {
  const TransporterUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 3,
      children: [
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-assigned-truck-list"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/truck.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFA238),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Assigned\nTruck List",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-last-delivery-list"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Image.asset(
                          "assets/images/dashboard/delivered.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF173C79),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Last\nDelivery List",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ITAdmin extends StatefulWidget {
  final String activeUsers;
  const ITAdmin({required this.activeUsers, Key? key}) : super(key: key);

  @override
  State<ITAdmin> createState() => _ITAdminState();
}

class _ITAdminState extends State<ITAdmin> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 1,
      childAspectRatio: 3,
      children: [
        GestureDetector(
          onTap: () => GoRouter.of(context).push("/view-active-user-list"),
          child: CardBase(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: (Text(widget.activeUsers,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w600))),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: (Text("Active",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF173C79)))),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF173C79),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7))),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Active\nUsers List",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardCustomerCard extends StatefulWidget {
  const DashboardCustomerCard({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardCustomerCard> createState() => _DashboardCustomerCardState();
}

class _DashboardCustomerCardState extends State<DashboardCustomerCard> {
  late Future<UserResponseDto?> action;
  UserResponseDto? customerList;
  UserResponseDto? user;
  List<CustomerSearchDto>? fetchedCustomerList;
  CustomerSearchDto? selectedCustomer;
  late SelectedCustomerController controller;

  @override
  void initState() {
    fetchCustomer();
    controller = locate<SelectedCustomerController>();
    super.initState();
  }

  fetchCustomer() {
    setState(() {
      action = () async {
        Storage storage = Storage();
        String? email = await storage.readValue("email");
        final data = await locate<RestService>().getUserByEmail(email!);
        customerList = data;
        controller.value.userRole = data?.roles?.first.roleName;
      }.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, customerValue, _) {
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
                            PopupMenuButton<SoldToData>(
                              offset: const Offset(0, 30),
                              child: FittedBox(
                                child: Text(
                                  customerValue.soldToCode != null
                                      ? (() {
                                          final fullText = "${customerValue.soldToCode} ${customerValue.soldToName}";
                                          return fullText.length > 28 ? '${fullText.substring(0, 28)}...' : fullText;
                                        })()
                                      : "Select a Customer",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: customerValue.soldToCode != null ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (SoldToData soldToData) async {
                                controller.setValue(
                                  controller.value..soldToCode = soldToData.soldToCode,
                                );
                                controller.setValue(
                                  controller.value..soldToName = soldToData.soldToName,
                                );
                                if (customerValue.soldToCode != null) {
                                  await controller.getDivisionCode(soldToData.soldToCode);
                                  await controller.getBannerList(controller.value.soldToCode!);
                                }
                                if (controller.value.soldToCode != null &&
                                    controller.value.salesOrganizationCode != null &&
                                    controller.value.divisionCode != null) {
                                  await controller.getDashboardSummary();
                                  await controller.fetchGraphData();
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                if (customerList?.customers?.isEmpty ?? false || customerList?.customers == null) {
                                  return [
                                    PopupMenuItem<SoldToData>(
                                      value: SoldToData(
                                        soldToCode: null,
                                        soldToName: null,
                                      ),
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
                                  return customerList!.customers?.map((soldTo) {
                                        return PopupMenuItem<SoldToData>(
                                          value: SoldToData(
                                            soldToCode: soldTo.soldToCode,
                                            soldToName: soldTo.name,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: Text(
                                              "${soldTo.soldToCode!} "
                                              "${soldTo.name!} ",
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
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

class DashboardCustomerSearchCard extends StatefulWidget {
  const DashboardCustomerSearchCard({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardCustomerSearchCard> createState() => _DashboardCustomerSearchCard();
}

class _DashboardCustomerSearchCard extends State<DashboardCustomerSearchCard> {
  late Future<UserResponseDto?> action;
  UserResponseDto? customerList;
  UserResponseDto? user;
  TextEditingController customerSearchController = TextEditingController();
  List<CustomerSearchDto>? fetchedCustomerList;
  CustomerSearchDto? selectedCustomer;
  late SelectedCustomerController controller;

  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    fetchCustomer();
    customerSearchController.addListener(onSearchTextChanged);
    customerSearchController.text =
        controller.value.soldToCode != null ? "${controller.value.soldToCode} ${controller.value.soldToName}" : "";
    super.initState();
  }

  fetchCustomer() {
    setState(() {
      action = () async {
        try {
          Storage storage = Storage();
          String? email = await storage.readValue("email");
          final data = await locate<RestService>().getUserByEmail(email!);
          customerList = data;
          controller.value.userRole = data?.roles?.first.roleName;
        } catch (error) {
          customerList = null;
        }
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
      // Handle API call error here
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
        valueListenable: controller,
        builder: (context, customerValue, _) {
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
                                            controller.setValue(
                                              controller.value
                                                ..soldToCode = soldToData.soldToCode
                                                ..soldToName = soldToData.name,
                                            );
                                            setState(() {
                                              customerSearchController.text =
                                                  "${controller.value.soldToCode} ${controller.value.soldToName}";
                                            });
                                            locate<LoadingIndicatorController>().show();
                                            await controller.getDivisionCode(soldToData.soldToCode);

                                            if (controller.value.soldToCode != null &&
                                                controller.value.salesOrganizationCode != null &&
                                                controller.value.divisionCode != null) {
                                              await controller.getDashboardSummary();
                                              await controller.fetchGraphData();
                                            }
                                            if (controller.value.soldToCode != null) {
                                              await controller.fetchActiveUsers();
                                              await controller.getBannerList(controller.value.soldToCode!);
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
                                    clearSelectedCustomer();
                                    setState(() {
                                      selectedCustomer = null;
                                      customerSearchController.text = "";
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
  void clearSelectedCustomer() {
    controller.setValue(controller.value
      ..soldToCode = null
      ..soldToName = null
      ..shipTo = null
      ..shipToName = null
      ..divisionCode = null
      ..divisionCodeList = null
      ..salesOrganizationCode = null
      ..salesOrgCodeList = null
      ..soldToCode = null
      ..soldToName = null
      ..dashboardSummary = null
      ..ytdGraphData = null
      ..mtdGraphData = null
      ..mtdData = null
      ..ytdData = null
      ..creditLimitAvailable = null
      ..activeUsers = null
      ..bannerList = null);
  }
}

class SoldToData {
  final String? soldToCode;
  final String? soldToName;

  SoldToData({this.soldToCode, this.soldToName});
}

class DashboardDivisionCard extends StatefulWidget {
  const DashboardDivisionCard({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardDivisionCard> createState() => _DashboardDivisionCardState();
}

class _DashboardDivisionCardState extends State<DashboardDivisionCard> {
  Set<String> uniqueDivisionCodes = {};
  late SelectedCustomerController controller;
  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    super.initState();
    controller.addListener(_handleControllerValueChange);
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerValueChange);
    super.dispose();
  }

  void _handleControllerValueChange() {
    uniqueDivisionCodes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, customerValue, _) {
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
                height: 70,
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
                                    "Division",
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 30),
                              child: FittedBox(
                                child: Text(
                                  customerValue.divisionCode != null
                                      ? customerValue.divisionCode!
                                      : "Select a Division",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: customerValue.divisionCode != null ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (value) async {
                                controller.setValue(
                                  controller.value..divisionCode = value,
                                );
                                locate<LoadingIndicatorController>().show();
                                if (controller.value.soldToCode != null &&
                                    controller.value.salesOrganizationCode != null &&
                                    controller.value.divisionCode != null) {
                                  await controller.getDashboardSummary();
                                  await controller.fetchGraphData();
                                }
                                if (controller.value.soldToCode != null) {
                                  await controller.fetchActiveUsers();
                                  await controller.getBannerList(controller.value.soldToCode!);
                                }
                                locate<LoadingIndicatorController>().hide();
                              },
                              itemBuilder: (BuildContext context) {
                                List<DetailDto>? divisionList = customerValue.divisionCodeList;
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
}

class DashboardOrganizationCard extends StatefulWidget {
  const DashboardOrganizationCard({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardOrganizationCard> createState() => _DashboardOrganizationCardState();
}

class _DashboardOrganizationCardState extends State<DashboardOrganizationCard> {
  Set<String> uniqueSalesOrgCodes = {};
  late SelectedCustomerController controller;
  @override
  void initState() {
    controller = locate<SelectedCustomerController>();
    super.initState();
    controller.addListener(_handleControllerValueChange);
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerValueChange);
    super.dispose();
  }

  void _handleControllerValueChange() {
    uniqueSalesOrgCodes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, customerValue, _) {
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
                height: 70,
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
                                    "Sales Organization",
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            PopupMenuButton<SalesOrgData>(
                              offset: const Offset(0, 30),
                              child: FittedBox(
                                child: Text(
                                  customerValue.salesOrganizationCode != null
                                      ? "${customerValue.salesOrganizationCode} ${customerValue.salesOrganizationName}"
                                      : "Select a Organization",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: customerValue.salesOrganizationCode != null ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                              onSelected: (SalesOrgData salesOrgData) async {
                                controller.setValue(
                                  controller.value..salesOrganizationCode = salesOrgData.salesOrgCode,
                                );
                                controller.setValue(
                                  controller.value..salesOrganizationName = salesOrgData.salesOrgName,
                                );
                                locate<LoadingIndicatorController>().show();
                                if (controller.value.soldToCode != null &&
                                    controller.value.salesOrganizationCode != null &&
                                    controller.value.divisionCode != null) {
                                  await controller.getDashboardSummary();
                                  await controller.fetchGraphData();
                                }
                                if (controller.value.soldToCode != null) {
                                  await controller.fetchActiveUsers();
                                  await controller.getBannerList(controller.value.soldToCode!);
                                }
                                locate<LoadingIndicatorController>().hide();
                              },
                              itemBuilder: (BuildContext context) {
                                List<DetailDto>? salesOrgCodeList = customerValue.salesOrgCodeList;
                                if (salesOrgCodeList != null) {
                                  salesOrgCodeList = salesOrgCodeList.where((dto) {
                                    bool isUnique = uniqueSalesOrgCodes.add(dto.salesOrgCode!);
                                    return isUnique;
                                  }).toList();
                                }
                                if (salesOrgCodeList?.isEmpty ?? false || salesOrgCodeList == null) {
                                  return [
                                    PopupMenuItem<SalesOrgData>(
                                      value: SalesOrgData(
                                        salesOrgCode: null,
                                        salesOrgName: null,
                                      ),
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
                                  return (salesOrgCodeList ?? []).map((salesOrg) {
                                    return PopupMenuItem<SalesOrgData>(
                                      value: SalesOrgData(
                                        salesOrgCode: salesOrg.salesOrgCode,
                                        salesOrgName: salesOrg.salesOrgName,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: Text(
                                          ("${salesOrg.salesOrgCode!} ${salesOrg.salesOrgName!}"),
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
}

class SalesOrgData {
  final String? salesOrgCode;
  final String? salesOrgName;

  SalesOrgData({this.salesOrgCode, this.salesOrgName});
}
