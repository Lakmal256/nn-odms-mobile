import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class LastDeliveryView extends StatelessWidget {
  const LastDeliveryView({Key? key}) : super(key: key);

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
                      "Last Deliveries",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Create New",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFFFF0000).withOpacity(0.6)),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            spreadRadius: -12.0,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => GoRouter.of(context).go("/order-b2b-credit-view"),
                        icon: Icon(
                          Icons.add_circle,
                          color: const Color(0xFFFF0000).withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const LastDeliveryTabs(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class LastDeliveryTabs extends StatefulWidget {
  const LastDeliveryTabs({Key? key}) : super(key: key);

  @override
  State<LastDeliveryTabs> createState() => _LastDeliveryTabsState();
}

class _LastDeliveryTabsState extends State<LastDeliveryTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<LastDeliveryViewService>().fetchLastDelivery();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            color: const Color(0xFFD9D9D9).withOpacity(0.4),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TabBar(
                controller: tabController,
                // isScrollable: true,
                indicator: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: _indicatorColorForTab(tabController.index),
                  shadows: const [BoxShadow(color: Colors.black26, blurRadius: 3.0, spreadRadius: 2.0)],
                ),
                tabs: [
                  LastDeliveryCustomTab(
                    text: " All ",
                    isSelected: tabController.index == 0,
                  ),
                  LastDeliveryCustomTab(
                    text: "Dispatched",
                    isSelected: tabController.index == 1,
                  ),
                  LastDeliveryCustomTab(
                    text: "Completed",
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
                FutureBuilder(
                    future: action,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ValueListenableBuilder(
                        valueListenable: locate<LastDeliveryViewService>(),
                        builder: (context, snapshot, _) {
                          if (snapshot.lastDeliveries.isEmpty) {
                            return const Center(
                              child: FittedBox(child: Text("There are no Last Deliveries.")),
                            );
                          }
                          snapshot.lastDeliveries.sort((a, b) {
                            DateTime dateA = DateFormat("dd-MM-yyyy").parse(a.date!);
                            DateTime dateB = DateFormat("dd-MM-yyyy").parse(b.date!);
                            return dateB.compareTo(dateA); // Descending order
                          });
                          return ListView(
                            shrinkWrap: true,
                            children: snapshot.lastDeliveries
                                .map(
                                  (lastDelivery) => LastDeliveryCard(
                                    salesOrderNo: lastDelivery.doNumber ?? "N/A",
                                    date: lastDelivery.date ?? "N/A",
                                    orderValue: lastDelivery.truckNumber ?? "N/A",
                                    status: lastDelivery.status ?? "N/A",
                                  ),
                                )
                                .toList(),
                          );
                        },
                      );
                    }),
                ValueListenableBuilder(
                  valueListenable: locate<LastDeliveryViewService>(),
                  builder: (context, snapshot, _) {
                    final items = locate<LastDeliveryViewService>().filterByStatus("DISPATCHED");
                    if (items.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Dispatched Deliveries.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (lastDelivery) => LastDeliveryCard(
                              salesOrderNo: lastDelivery.doNumber ?? "N/A",
                              date: lastDelivery.date ?? "N/A",
                              orderValue: lastDelivery.truckNumber ?? "N/A",
                              status: lastDelivery.status ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<LastDeliveryViewService>(),
                  builder: (context, snapshot, _) {
                    final items = locate<LastDeliveryViewService>().filterByStatus("COMPLETED");
                    if (items.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Completed Deliveries.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (lastDelivery) => LastDeliveryCard(
                              salesOrderNo: lastDelivery.doNumber ?? "N/A",
                              date: lastDelivery.date ?? "N/A",
                              orderValue: lastDelivery.truckNumber ?? "N/A",
                              status: lastDelivery.status ?? "N/A",
                            ),
                          )
                          .toList(),
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

  Color _indicatorColorForTab(int index) {
    switch (index) {
      case 0:
        return Colors.red.withOpacity(0.8);
      case 1:
        return Colors.red.withOpacity(0.8);
      case 2:
        return Colors.red.withOpacity(0.8);
      default:
        return Colors.grey;
    }
  }
}

class LastDeliveryCustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const LastDeliveryCustomTab({super.key, required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Center(
        child: FittedBox(
          child: FittedBox(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF000000),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class LastDeliveryCard extends StatelessWidget {
  const LastDeliveryCard({
    super.key,
    required this.salesOrderNo,
    required this.date,
    required this.orderValue,
    required this.status,
  });
  final String salesOrderNo;
  final String date;
  final String orderValue;
  final String status;

  Color _getStatusColor(String status) {
    switch (status) {
      case "DISPATCHED":
        return const Color(0xFF173C79);
      case "COMPLETED":
        return const Color(0xFF173C79);
      default:
        return const Color(0xFF173C79);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3,
        child: Container(
          color: Colors.white,
          height: 100.0,
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
                          "Delivery Order No",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          salesOrderNo,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF000000),
                              ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          "Amount",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
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
                        FittedBox(
                          child: Text(
                            date,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFF000000),
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        FittedBox(
                          child: Text(
                            orderValue,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: _getStatusColor(status), fontWeight: FontWeight.bold),
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
