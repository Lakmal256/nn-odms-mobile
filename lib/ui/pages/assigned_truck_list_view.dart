import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class AssignedTruckListView extends StatefulWidget {
  const AssignedTruckListView({Key? key}) : super(key: key);

  @override
  State<AssignedTruckListView> createState() => _AssignedTruckListViewState();
}

class _AssignedTruckListViewState extends State<AssignedTruckListView> {
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
                      "Assigned Truck List",
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
                      if (snapshot.recentDeliveries.isNotEmpty || snapshot.recentDeliveries.isEmpty) {
                        return const Center(
                          child: FittedBox(child: Text("There are no Assigned Trucks.")),
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
                              (recentDeliveries) => AssignedTruckCard(
                            salesOrderNo: recentDeliveries.doNumber ?? "N/A",
                            date: recentDeliveries.date ?? "N/A",
                            truckNumber: recentDeliveries.truckNumber ?? "N/A",
                            shipTo: recentDeliveries.status ?? "N/A",
                            assigningTo: recentDeliveries.status ?? "N/A",
                            bags: recentDeliveries.status ?? "N/A",
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

class AssignedTruckCard extends StatelessWidget {
  const AssignedTruckCard({
    super.key,
    required this.salesOrderNo,
    required this.date,
    required this.truckNumber,
    required this.shipTo,
    required this.assigningTo,
    required this.bags,
  });
  final String salesOrderNo;
  final String date;
  final String truckNumber;
  final String shipTo;
  final String assigningTo;
  final String bags;

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
          height: 180.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          "Sales Order No",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 10),
                      FittedBox(
                        child: Text(
                          "Remaining",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          // bags,
                          "50 Bags",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF1D1B23),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        child: Text(
                          "Transaction Date",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          date,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: const Color(0xFF1D1B23),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 5),
                        FittedBox(
                          child: Text(
                            "Ship To",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            // shipTo,
                            "949999923 - Kandy",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          child: Text(
                            "Assigning To",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF000000),fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            // assigningTo,
                            "KM Gunadasa",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          child: Text(
                            // bags,
                            " ",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        FittedBox(
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Truck No ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: const Color(0xFFFFA238), fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: truckNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: const Color(0xFFFFA238), fontWeight: FontWeight.bold),
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
