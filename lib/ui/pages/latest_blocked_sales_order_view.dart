import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class LatestBlockSalesOrdersView extends StatefulWidget {
  const LatestBlockSalesOrdersView({Key? key}) : super(key: key);

  @override
  State<LatestBlockSalesOrdersView> createState() => _LatestBlockSalesOrdersViewState();
}

class _LatestBlockSalesOrdersViewState extends State<LatestBlockSalesOrdersView> {
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<RecentBlockedSalesOrderViewService>().fetchRecentBlockedSalesOrders();
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
                      "Latest Blocked Sales Orders",
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
                  valueListenable: locate<RecentBlockedSalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    if (snapshot.recentBlockedSalesOrders.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Latest Blocked Sales Orders.")),
                      );
                    }
                    snapshot.recentBlockedSalesOrders.sort((a, b) {
                      DateTime dateA = DateFormat("yyyy-MM-dd").parse(a.orderDate!);
                      DateTime dateB = DateFormat("yyyy-MM-dd").parse(b.orderDate!);
                      return dateB.compareTo(dateA); // Descending order
                    });
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.recentBlockedSalesOrders
                          .map(
                            (recentSalesOrders) => LatestBlockSalesOrdersCard(
                          salesOrderNo: recentSalesOrders.soNumber ?? "N/A",
                          orderDate: recentSalesOrders.orderDate ?? "N/A",
                          orderValue: recentSalesOrders.amount.toString(),
                          status: recentSalesOrders.status ?? "N/A",
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

class LatestBlockSalesOrdersCard extends StatelessWidget {
  const LatestBlockSalesOrdersCard({
    Key? key,
    required this.salesOrderNo,
    required this.orderDate,
    required this.orderValue,
    required this.status,
  }) : super(key: key);

  final String salesOrderNo;
  final String orderDate;
  final String orderValue;
  final String status;

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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
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
                            status,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFFFFA238),
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
                                      .copyWith(color: const Color(0xFFFFA238), fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: formatAmount(orderValue),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: const Color(0xFFFFA238), fontWeight: FontWeight.w700),
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
