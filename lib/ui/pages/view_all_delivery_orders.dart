import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../locator.dart';

class OrderViewLauncher extends StatelessWidget {
  const OrderViewLauncher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbfcf8),
      appBar: const AppBarWithTM(),
      body: Column(children: [
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
                  FittedBox(
                    child: Text(
                      "Delivery Orders",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
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
        const DeliveryOrderViewTabs(),
        const SizedBox(height: 10),
      ]),
    );
  }
}

class DeliveryOrderViewTabs extends StatefulWidget {
  const DeliveryOrderViewTabs({Key? key}) : super(key: key);

  @override
  State<DeliveryOrderViewTabs> createState() => _DeliveryOrderViewTabsState();
}

class _DeliveryOrderViewTabsState extends State<DeliveryOrderViewTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;
  // late Future action;

  @override
  void initState() {
    super.initState();
    // action = locate<SalesOrderViewService>().fetchSalesOrder();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            color: const Color(0xFFD9D9D9).withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicator: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: Colors.red.withOpacity(0.8),
                  shadows: const [BoxShadow(color: Colors.black26, blurRadius: 3.0, spreadRadius: 2.0)],
                ),
                tabs: [
                  DeliveryOrderViewCustomTab(
                    text: "  All  ",
                    isSelected: tabController.index == 0,
                  ),
                  DeliveryOrderViewCustomTab(
                    text: "Open",
                    isSelected: tabController.index == 1,
                  ),
                  DeliveryOrderViewCustomTab(
                    text: "Pending",
                    isSelected: tabController.index == 2,
                  ),
                  DeliveryOrderViewCustomTab(
                    text: "Dispatched",
                    isSelected: tabController.index == 3,
                  ),
                  DeliveryOrderViewCustomTab(
                    text: "Deleted",
                    isSelected: tabController.index == 4,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                FutureBuilder(
                    future: Future.delayed(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ValueListenableBuilder(
                    valueListenable: locate<OrdersRepo>(),
                    builder: (context, value, _) {
                      // if (snapshot.isEmpty) {
                      //   return const Center(
                      //     child: Text("There are no Open Sales Orders."),
                      //   );
                      // }
                      String formatDateString(String? dateString) {
                        const expectedFormat = "dd-MM-yyyy";
                        final regex = RegExp(r'^\d{2}-\d{2}-\d{4}$');

                        if (dateString == null || !regex.hasMatch(dateString)) {
                          return "Invalid Date";
                        }

                        try {
                          final parts = dateString.split("-");
                          final day = int.parse(parts[0]);
                          final month = int.parse(parts[1]);
                          final year = int.parse(parts[2]);
                          final dateTime = DateTime(year, month, day);
                          final formattedDate = DateFormat(expectedFormat).format(dateTime);
                          return formattedDate;
                        } catch (e) {
                          return "$e";
                        }
                      }

                      List<Map<String, dynamic>> sortedOrders = List.from(value.allOrders);
                      sortedOrders.sort((a, b) => formatDateString(b["date"]).compareTo(formatDateString(a["date"])));
                      return ListView.builder(
                        itemCount: sortedOrders.length,
                        itemBuilder: (context, index) {
                          return OrderCard(
                            orderId: value.allOrders[index]["orderId"],
                            shipToCode: value.allOrders[index]["shipToCode"],
                            date: formatDateString(value.allOrders[index]["date"]),
                            orderValue: value.allOrders[index]["orderValue"],
                            status: value.allOrders[index]["status"],
                          );
                        },
                      );
                    },
                  );
                }),
                ValueListenableBuilder(
                  valueListenable: locate<OrdersRepo>(),
                  builder: (context, value, _) {
                    final items = locate<OrdersRepo>().filterByStatus("OPEN");
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return OrderCard(
                          orderId: items[index]["orderId"],
                          shipToCode: items[index]["shipToCode"],
                          date: items[index]["date"],
                          orderValue: items[index]["orderValue"],
                          status: items[index]["status"],
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<OrdersRepo>(),
                  builder: (context, value, _) {
                    final items = locate<OrdersRepo>().filterByStatus("PENDING");
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return OrderCard(
                          orderId: items[index]["orderId"],
                          shipToCode: items[index]["shipToCode"],
                          date: items[index]["date"],
                          orderValue: items[index]["orderValue"],
                          status: items[index]["status"],
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<OrdersRepo>(),
                  builder: (context, value, _) {
                    final items = locate<OrdersRepo>().filterByStatus("DISPATCHED");
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return OrderCard(
                          orderId: items[index]["orderId"],
                          shipToCode: items[index]["shipToCode"],
                          date: items[index]["date"],
                          orderValue: items[index]["orderValue"],
                          status: items[index]["status"],
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<OrdersRepo>(),
                  builder: (context, value, _) {
                    final items = locate<OrdersRepo>().filterByStatus("DELETED");
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return OrderCard(
                          orderId: items[index]["orderId"],
                          shipToCode: items[index]["shipToCode"],
                          date: items[index]["date"],
                          orderValue: items[index]["orderValue"],
                          status: items[index]["status"],
                        );
                      },
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

class DeliveryOrderViewCustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const DeliveryOrderViewCustomTab({super.key, required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Center(
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
    );
  }
}

class OrdersRepoValue {
  OrdersRepoValue()
      : allOrders = [
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "01-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "OPEN",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "09-01-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "PENDING",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "10-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "PENDING",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "09-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "DISPATCHED",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "08-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "DELETED",
          },
        ];

  final List<dynamic> allOrders;
}

class OrdersRepo extends ValueNotifier<OrdersRepoValue> {
  OrdersRepo({OrdersRepoValue? value}) : super(value ?? OrdersRepoValue());

  List<dynamic> filterByStatus(String status) {
    return value.allOrders.where((element) => element["status"] == status).toList();
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,
    required this.shipToCode,
    required this.date,
    required this.orderValue,
    required this.status,
  });
  final String orderId;
  final String shipToCode;
  final String date;
  final String orderValue;
  final String status;

  Color _getStatusColor(String status) {
    switch (status) {
      case "PENDING":
        return const Color(0xFFFF8E00);
      case "DISPATCHED":
        return const Color(0xFF173C79);
      case "OPEN":
        return const Color(0xFF4A7A36);
      case "DELETED":
        return const Color(0xFF717579);
      default:
        return Colors.black;
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
          height: 120.0,
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
                      Row(
                        children: [
                          FittedBox(
                            child: Text(
                              "Order ID",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          if (status == "OPEN" || status == "DISPATCHED")
                            Icon(Icons.share_location_outlined,
                                color: status == "OPEN" ? const Color(0xFF4A7A36) : const Color(0xFF173C79), size: 25),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          orderId,
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
                          "Ship To",
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
                          shipToCode,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF000000),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (status != "CANCELLED")
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.edit_outlined, color: Color(0xFF717579), size: 20),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.delete_outline_outlined, color: Color(0xFF717579), size: 20),
                            ],
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            child: Text(
                              date,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        FittedBox(
                          child: Text(
                            'Order Value',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: _getStatusColor(status)),
                          ),
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
