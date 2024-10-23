import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class RecentSalesOrderView extends StatefulWidget {
  const RecentSalesOrderView({Key? key}) : super(key: key);

  @override
  State<RecentSalesOrderView> createState() => _RecentSalesOrderViewState();
}

class _RecentSalesOrderViewState extends State<RecentSalesOrderView> {
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<RecentSalesOrderViewService>().fetchRecentSalesOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbfcf8),
      appBar: const AppBarWithTM(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: BackButton(
                        onPressed: () => GoRouter.of(context).go("/home"),
                      ),
                    ),
                    Text(
                      "Recent Sales Orders",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: action,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ValueListenableBuilder(
                  valueListenable: locate<RecentSalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    if (snapshot.recentSalesOrders.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Recent Sales Orders.")),
                      );
                    }
                    if (snapshot.recentSalesOrders.isNotEmpty) {
                      snapshot.recentSalesOrders.sort((a, b) {
                        DateTime dateA = DateFormat("yyyy-MM-dd").parse(a.orderDate!);
                        DateTime dateB = DateFormat("yyyy-MM-dd").parse(b.orderDate!);
                        return dateB.compareTo(dateA); // Descending order
                      });
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.recentSalesOrders
                          .map(
                            (recentSalesOrders) => RecentSalesOrderCard(
                              salesOrderNo: recentSalesOrders.soNumber ?? "DRAFT",
                              orderDate: recentSalesOrders.orderDate ?? "N/A",
                              orderValue: recentSalesOrders.amount.toString(),
                              status: recentSalesOrders.status ?? "N/A",
                              internalStatus: recentSalesOrders.internalStatus ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class RecentSalesOrderCard extends StatelessWidget {
  const RecentSalesOrderCard({
    Key? key,
    required this.salesOrderNo,
    required this.orderDate,
    required this.orderValue,
    required this.status,
    required this.internalStatus,
  }) : super(key: key);

  final String salesOrderNo;
  final String orderDate;
  final String orderValue;
  final String status;
  final String internalStatus;

  String _getStatus(String status, String internalStatus) {
    if (status == "N/A" && internalStatus == "DRAFT") {
      return "PENDING";
    } else if (status == null && internalStatus == "DRAFT") {
      return "PENDING";
    } else if (status == "BEING_PROCESSED" && internalStatus == "SUBMIT_PAYMENT_PLAN") {
      return "UNBLOCK PENDING";
    } else if (status == "BEING_PROCESSED" && internalStatus == "UNBLOCK_REQUEST_PROCESSING") {
      return "UNBLOCK PENDING";
    } else if (status == "OPEN" && internalStatus == "APPROVED") {
      return "OPEN";
    } else if (status == "OPEN" && internalStatus == "REPLICATED") {
      return "OPEN";
    } else if (status == "BEING_PROCESSED" && internalStatus == "PROCESSING") {
      return "OPEN";
    } else if (status == "BEING_PROCESSED" && internalStatus == "APPROVED") {
      return "OPEN";
    } else if (status == "N/A" && internalStatus == "FAILED") {
      return "FAILED";
    } else if (status == "N/A" && internalStatus == "CREATING") {
      return "SUBMITTED";
    } else if (status == "N/A" && internalStatus == "CREATED") {
      return "SUBMITTED";
    } else if (status == "COMPLETED" || internalStatus == "COMPLETED") {
      return "COMPLETED";
    } else if (status == "BEING_PROCESSED" || internalStatus == "CREDIT_BLOCKED") {
      return "BLOCKED";
    } else {
      return "N/A";
    }
  }

  Color _getStatusColor(String status, String internalStatus) {
    if (status == "N/A" && internalStatus == "DRAFT") {
      return const Color(0xFFFEAE35);
    } else if (status == null && internalStatus == "DRAFT") {
      return const Color(0xFFFEAE35);
    } else if (status == "BEING_PROCESSED" && internalStatus == "SUBMIT_PAYMENT_PLAN") {
      return const Color(0xFFFEAE35);
    } else if (status == "BEING_PROCESSED" && internalStatus == "UNBLOCK_REQUEST_PROCESSING") {
      return const Color(0xFFFEAE35);
    } else if (status == "OPEN" && internalStatus == "APPROVED") {
      return const Color(0xFF4A7A36);
    } else if (status == "OPEN" && internalStatus == "REPLICATED") {
      return const Color(0xFF4A7A36);
    } else if (status == "BEING_PROCESSED" && internalStatus == "PROCESSING") {
      return const Color(0xFF000000);
    } else if (status == "BEING_PROCESSED" && internalStatus == "APPROVED") {
      return const Color(0xFF4A7A36);
    } else if (status == "N/A" && internalStatus == "FAILED") {
      return const Color(0xFFDB4633);
    } else if (status == "N/A" && internalStatus == "CREATING") {
      return const Color(0xFF01B3EB);
    } else if (status == "N/A" && internalStatus == "CREATED") {
      return const Color(0xFF01B3EB);
    } else if (status == "COMPLETED" || internalStatus == "COMPLETED") {
      return const Color(0xFF173C79);
    } else if (status == "BEING_PROCESSED" || internalStatus == "CREDIT_BLOCKED") {
      return const Color(0xFFDB4633);
    } else {
      return Colors.grey;
    }
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3,
        child: Container(
          color: Colors.white,
          height: 110.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          "Sales Order No",
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
                                color: const Color(0xFF1D1B23),
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ),
                      const Spacer(),
                      FittedBox(
                        child: Text(
                          "Order Date",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          orderDate,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: const Color(0xFF1D1B23),
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          child: Text(
                            "Status",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            _getStatus(status, internalStatus),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: _getStatusColor(status, internalStatus),
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                        ),
                        const Spacer(),
                        FittedBox(
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "LKR ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: formatAmount(orderValue),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w700),
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
            ],
          ),
        ),
      ),
    );
  }
}
