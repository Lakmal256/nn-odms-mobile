import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class PendingDeliveredOrderView extends StatefulWidget {
  const PendingDeliveredOrderView({Key? key}) : super(key: key);

  @override
  State<PendingDeliveredOrderView> createState() => _PendingDeliveredOrderViewState();
}

class _PendingDeliveredOrderViewState extends State<PendingDeliveredOrderView> {
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<RecentDeliveriesViewService>().fetchRecentDeliveries();
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
                      "Pending Delivered Orders",
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
                    valueListenable: locate<RecentDeliveriesViewService>(),
                    builder: (context, snapshot, _) {
                      if (snapshot.recentDeliveries.isEmpty || snapshot.recentDeliveries.isNotEmpty) {
                        return const Center(
                          child: FittedBox(child: Text("There are no Pending Delivered Orders.")),
                        );
                      }
                      snapshot.recentDeliveries.sort((a, b) {
                        DateTime dateA = DateFormat("dd-MM-yyyy").parse(a.date!);
                        DateTime dateB = DateFormat("dd-MM-yyyy").parse(b.date!);
                        return dateB.compareTo(dateA); // Descending order
                      });
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.recentDeliveries
                            .map(
                              (recentDeliveries) => PendingDeliveredOrderCard(
                            deliveryOrderNo: recentDeliveries.doNumber ?? "N/A",
                            orderDate: recentDeliveries.date ?? "N/A",
                            truckNumber: recentDeliveries.truckNumber ?? "N/A",
                            status: recentDeliveries.status ?? "N/A",
                          ),
                        )
                            .toList(),
                      );
                    },
                  );
                }),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class PendingDeliveredOrderCard extends StatelessWidget {
  const PendingDeliveredOrderCard({
    super.key,
    required this.deliveryOrderNo,
    required this.orderDate,
    required this.truckNumber,
    required this.status,
  });
  final String deliveryOrderNo;
  final String orderDate;
  final String truckNumber;
  final String status;

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
                          "Delivery Order No",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          deliveryOrderNo,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF1D1B23),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const Spacer(),
                      FittedBox(
                        child: Text(
                          "Transaction Date",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w400,
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
                      const SizedBox(height: 3)
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
                        const SizedBox(
                          height:2
                        ),
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
                            // status,
                            "PENDING",
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
                                  text: "Truck No ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: truckNumber,
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
