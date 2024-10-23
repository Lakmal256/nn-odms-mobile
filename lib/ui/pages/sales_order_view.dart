import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/sales_order.dart';
import '../../locator.dart';
import '../ui.dart';
import 'package:go_router/go_router.dart';

class SalesOrderView extends StatelessWidget {
  const SalesOrderView({Key? key}) : super(key: key);

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
                      "Sales Orders",
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
                        onPressed: () => GoRouter.of(context).go("/order-retail-credit-view"),
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
          const Tabs(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<SalesOrderViewService>().fetchSalesOrder();
    tabController = TabController(length: 7, vsync: this);
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
                  CustomTab(
                    text: "  All  ",
                    isSelected: tabController.index == 0,
                  ),
                  CustomTab(
                    text: "Open",
                    isSelected: tabController.index == 1,
                  ),
                  CustomTab(
                    text: "Submitted",
                    isSelected: tabController.index == 2,
                  ),
                  CustomTab(
                    text: "Completed",
                    isSelected: tabController.index == 3,
                  ),
                  CustomTab(
                    text: "Pending",
                    isSelected: tabController.index == 4,
                  ),
                  CustomTab(
                    text: "Unblock Pending",
                    isSelected: tabController.index == 5,
                  ),
                  CustomTab(
                    text: "Blocked",
                    isSelected: tabController.index == 6,
                  ),
                ],
              ),
            ),
          ),
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
                      valueListenable: locate<SalesOrderViewService>(),
                      builder: (context, snapshot, _) {
                        if (snapshot.salesOrders.isEmpty) {
                          return const Center(
                            child: FittedBox(child: Text("There are no Sales Orders.")),
                          );
                        }
                        snapshot.salesOrders.sort((a, b) {
                          DateTime dateA = DateFormat("yyyy-MM-dd").parse(a.salesOrderDate!);
                          DateTime dateB = DateFormat("yyyy-MM-dd").parse(b.salesOrderDate!);
                          return dateB.compareTo(dateA); // Descending order
                        });
                        return ListView(
                          shrinkWrap: true,
                          children: snapshot.salesOrders
                              .map(
                                (salesOrder) => SalesOrderCard(
                                  salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                                  date: salesOrder.salesOrderDate ?? "N/A",
                                  orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                                  status: salesOrder.status ?? "N/A",
                                  internalStatus: salesOrder.internalStatus ?? "N/A",
                                  requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                                  shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                                  orderType: salesOrder.orderType ?? "N/A",
                                  shippingCondition: salesOrder.shippingCondition ?? "N/A",
                                  plantName: salesOrder.plant?.plantName ?? "N/A",
                                  plantCode: salesOrder.plant?.plantCode ?? "N/A",
                                  selectedProduct: salesOrder.salesOrderItems,
                                  vat: formatAmount(salesOrder.vat.toString()),
                                  valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                                  sscl: formatAmount(salesOrder.ssclTax.toString()),
                                  totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                                  orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                                  unitPrice: salesOrder.salesOrderItems?.first.unitPrice.toString() ?? "N/A",
                                ),
                              )
                              .toList(),
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<SalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    final items = snapshot.salesOrders;
                    final filteredItems = items.where((salesOrder) {
                      final status = salesOrder.status;
                      final internalStatus = salesOrder.internalStatus;
                      return (status == "OPEN" && (internalStatus == "APPROVED" || internalStatus == "REPLICATED")) ||
                          (status == "BEING_PROCESSED" && internalStatus == "APPROVED");
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Open Sales Orders.")),
                      );
                    }

                    return ListView(
                      shrinkWrap: true,
                      children: filteredItems
                          .map(
                            (salesOrder) => SalesOrderCard(
                              salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                              date: salesOrder.salesOrderDate ?? "N/A",
                              orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                              status: salesOrder.status ?? "N/A",
                              internalStatus: salesOrder.internalStatus ?? "N/A",
                              requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                              shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                              orderType: salesOrder.orderType ?? "N/A",
                              shippingCondition: salesOrder.shippingCondition ?? "N/A",
                              plantName: salesOrder.plant?.plantName ?? "N/A",
                              plantCode: salesOrder.plant?.plantCode ?? "N/A",
                              selectedProduct: salesOrder.salesOrderItems,
                              vat: formatAmount(salesOrder.vat.toString()),
                              valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                              sscl: formatAmount(salesOrder.ssclTax.toString()),
                              totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                              orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                              unitPrice: salesOrder.salesOrderItems?.first.unitPrice.toString() ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<SalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    final items = snapshot.salesOrders;
                    final filteredItems = items.where((salesOrder) {
                      final status = salesOrder.status;
                      final internalStatus = salesOrder.internalStatus;
                      return (status == null && internalStatus == "CREATING") ||
                          (status == null && internalStatus == "CREATED");
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Submitted Sales Orders.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: filteredItems
                          .map(
                            (salesOrder) => SalesOrderCard(
                              salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                              date: salesOrder.salesOrderDate ?? "N/A",
                              orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                              status: salesOrder.status ?? "N/A",
                              internalStatus: salesOrder.internalStatus ?? "N/A",
                              requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                              shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                              orderType: salesOrder.orderType ?? "N/A",
                              shippingCondition: salesOrder.shippingCondition ?? "N/A",
                              plantName: salesOrder.plant?.plantName ?? "N/A",
                              plantCode: salesOrder.plant?.plantCode ?? "N/A",
                              selectedProduct: salesOrder.salesOrderItems,
                              vat: formatAmount(salesOrder.vat.toString()),
                              valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                              sscl: formatAmount(salesOrder.ssclTax.toString()),
                              totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                              orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                              unitPrice: salesOrder.salesOrderItems?.first.unitPrice.toString() ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<SalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    final items = locate<SalesOrderViewService>().filterByStatus("COMPLETED", "COMPLETED");
                    if (items.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Completed Sales Orders.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (salesOrder) => SalesOrderCard(
                              salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                              date: salesOrder.salesOrderDate ?? "N/A",
                              orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                              status: salesOrder.status ?? "N/A",
                              internalStatus: salesOrder.internalStatus ?? "N/A",
                              requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                              shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                              orderType: salesOrder.orderType ?? "N/A",
                              shippingCondition: salesOrder.shippingCondition ?? "N/A",
                              plantName: salesOrder.plant?.plantName ?? "N/A",
                              plantCode: salesOrder.plant?.plantCode ?? "N/A",
                              selectedProduct: salesOrder.salesOrderItems,
                              vat: formatAmount(salesOrder.vat.toString()),
                              valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                              sscl: formatAmount(salesOrder.ssclTax.toString()),
                              totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                              orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                              unitPrice: salesOrder.salesOrderItems?.first.unitPrice.toString() ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<SalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    final items = locate<SalesOrderViewService>().filterByStatus(null, "DRAFT");
                    if (items.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Pending Sales Orders.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (salesOrder) => SalesOrderCard(
                              salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                              date: salesOrder.salesOrderDate ?? "N/A",
                              orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                              status: salesOrder.status ?? "N/A",
                              internalStatus: salesOrder.internalStatus ?? "N/A",
                              requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                              shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                              orderType: salesOrder.orderType ?? "N/A",
                              shippingCondition: salesOrder.shippingCondition ?? "N/A",
                              plantName: salesOrder.plant?.plantName ?? "N/A",
                              plantCode: salesOrder.plant?.plantCode ?? "N/A",
                              selectedProduct: salesOrder.salesOrderItems,
                              vat: formatAmount(salesOrder.vat.toString()),
                              valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                              sscl: formatAmount(salesOrder.ssclTax.toString()),
                              totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                              orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                              unitPrice: salesOrder.salesOrderItems?.first.unitPrice.toString() ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<SalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    final items =
                        locate<SalesOrderViewService>().filterByStatus("BEING_PROCESSED", "SUBMIT_PAYMENT_PLAN");

                    // Adding additional condition for "UNBLOCK_REQUEST_PROCESSING"
                    final unblockItems =
                        locate<SalesOrderViewService>().filterByStatus("BEING_PROCESSED", "UNBLOCK_REQUEST_PROCESSING");

                    // Combining the results
                    items.addAll(unblockItems);

                    if (items.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Unblock Pending Sales Orders.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (salesOrder) => SalesOrderCard(
                              salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                              date: salesOrder.salesOrderDate ?? "N/A",
                              orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                              status: salesOrder.status ?? "N/A",
                              internalStatus: salesOrder.internalStatus ?? "N/A",
                              requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                              shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                              orderType: salesOrder.orderType ?? "N/A",
                              shippingCondition: salesOrder.shippingCondition ?? "N/A",
                              plantName: salesOrder.plant?.plantName ?? "N/A",
                              plantCode: salesOrder.plant?.plantCode ?? "N/A",
                              selectedProduct: salesOrder.salesOrderItems,
                              vat: formatAmount(salesOrder.vat.toString()),
                              valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                              sscl: formatAmount(salesOrder.ssclTax.toString()),
                              totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                              orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                              unitPrice: salesOrder.salesOrderItems?.first.product?.price.toString() ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: locate<SalesOrderViewService>(),
                  builder: (context, snapshot, _) {
                    final items = locate<SalesOrderViewService>().filterByStatus("BEING_PROCESSED", "CREDIT_BLOCKED");
                    if (items.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Blocked Sales Orders.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (salesOrder) => SalesOrderCard(
                              salesOrderNo: salesOrder.salesOrderNo ?? "DRAFT",
                              date: salesOrder.salesOrderDate ?? "N/A",
                              orderValue: formatAmount(salesOrder.valueAfterTax.toString()),
                              status: salesOrder.status ?? "N/A",
                              internalStatus: salesOrder.internalStatus ?? "N/A",
                              requestReferenceCode: salesOrder.requestReferenceCode ?? "N/A",
                              shipTo: salesOrder.customerShippingLocation?.shipToCode ?? "N/A",
                              orderType: salesOrder.orderType ?? "N/A",
                              shippingCondition: salesOrder.shippingCondition ?? "N/A",
                              plantName: salesOrder.plant?.plantName ?? "N/A",
                              plantCode: salesOrder.plant?.plantCode ?? "N/A",
                              selectedProduct: salesOrder.salesOrderItems,
                              vat: formatAmount(salesOrder.vat.toString()),
                              valueBeforeTax: formatAmount(salesOrder.valueBeforeTax.toString()),
                              sscl: formatAmount(salesOrder.ssclTax.toString()),
                              totalItemValue: formatAmount(salesOrder.valueBeforeTax.toString()),
                              orderQty: salesOrder.salesOrderItems?.first.quantity.toString() ?? "N/A",
                              unitPrice: salesOrder.salesOrderItems?.first.unitPrice.toString() ?? "N/A",
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
}

class CustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const CustomTab({super.key, required this.text, required this.isSelected});

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

class SalesOrderCard extends StatelessWidget {
  const SalesOrderCard({
    Key? key,
    required this.salesOrderNo,
    required this.date,
    required this.orderValue,
    required this.status,
    required this.internalStatus,
    required this.requestReferenceCode,
    required this.shipTo,
    required this.orderType,
    required this.shippingCondition,
    required this.plantName,
    required this.plantCode,
    required this.selectedProduct,
    required this.vat,
    required this.valueBeforeTax,
    required this.sscl,
    required this.totalItemValue,
    required this.orderQty,
    required this.unitPrice,
  }) : super(key: key);

  final String salesOrderNo;
  final String date;
  final String orderValue;
  final String status;
  final String internalStatus;
  final String requestReferenceCode;
  final String shipTo;
  final String orderType;
  final String shippingCondition;
  final String plantName;
  final String plantCode;
  final List<SalesOrderItemsDto>? selectedProduct;
  final String vat;
  final String valueBeforeTax;
  final String sscl;
  final String totalItemValue;
  final String orderQty;
  final String unitPrice;

  Color _getStatusColor(String? status, String? internalStatus) {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (status == "BEING_PROCESSED" && internalStatus == "CREDIT_BLOCKED")
          Positioned(
            top: 5,
            right: 60,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestToUnblockOrderView(
                      salesOrderNumber: salesOrderNo,
                      requestReferenceCode: requestReferenceCode,
                      outstandingAmount: orderValue,
                    ),
                  ),
                );
              },
              child: Card(
                color: const Color(0xFFFEAE35),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.0),
                    child: Text(
                      "Unblock",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Container(
            margin: const EdgeInsets.only(top: 28),
            child: (status == "BEING_PROCESSED" && internalStatus == "CREDIT_BLOCKED")
                ? InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlockedSOView(
                            shipTo: shipTo,
                            orderType: orderType,
                            shippingCondition: shippingCondition,
                            plantName: plantName,
                            plantCode: plantCode,
                            selectedProduct: selectedProduct,
                            salesOrderNo: salesOrderNo,
                            requestReferenceCode: requestReferenceCode,
                            vat: vat,
                            valueBeforeTax: valueBeforeTax,
                            sscl: sscl,
                            totalOrderValue: orderValue,
                            orderQty: orderQty,
                            unitPrice: unitPrice,
                            total: totalItemValue,
                          ),
                        ),
                      );
                    },
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
                                        "Sales Order No",
                                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                              color: const Color(0xFF000000),
                                              fontWeight: FontWeight.w700,
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
                                              fontWeight: FontWeight.w300,
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
                                              color: _getStatusColor(status, internalStatus),
                                              fontWeight: FontWeight.w400,
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
                                      if (status != "BLOCKED" ||
                                          status != "CANCELLED" ||
                                          internalStatus != "BLOCKED" ||
                                          internalStatus != "CANCELLED")
                                        GestureDetector(
                                            // onTap: () => GoRouter.of(context).go("/order-b2b-credit-update-view"),
                                            onTap: () {},
                                            child: const Icon(Icons.edit_outlined, color: Color(0xFFFFFFFF), size: 20)),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      FittedBox(
                                        child: Text(
                                          date,
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                color: const Color(0xFF000000),
                                                fontWeight: FontWeight.w300,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      FittedBox(
                                        child: Text(
                                          "LKR ${orderValue.toString()}",
                                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                              color: _getStatusColor(status, internalStatus),
                                              fontWeight: FontWeight.w400),
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
                  )
                : Card(
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
                                      "Sales Order No",
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: const Color(0xFF000000),
                                            fontWeight: FontWeight.w700,
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
                                            fontWeight: FontWeight.w300,
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
                                            color: _getStatusColor(status, internalStatus),
                                            fontWeight: FontWeight.w400,
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
                                    if (status != "BLOCKED" ||
                                        status != "CANCELLED" ||
                                        internalStatus != "BLOCKED" ||
                                        internalStatus != "CANCELLED")
                                      GestureDetector(
                                          // onTap: () => GoRouter.of(context).go("/order-b2b-credit-update-view"),
                                          onTap: () {},
                                          child: const Icon(Icons.edit_outlined, color: Color(0xFFFFFFFF), size: 20)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    FittedBox(
                                      child: Text(
                                        date,
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: const Color(0xFF000000),
                                              fontWeight: FontWeight.w300,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "LKR ${orderValue.toString()}",
                                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                            color: _getStatusColor(status, internalStatus),
                                            fontWeight: FontWeight.w400),
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
          ),
        ),
      ],
    );
  }
}

class BlockedSOView extends StatelessWidget {
  final String? shipTo;
  final String? orderType;
  final String? shippingCondition;
  final String? plantName;
  final String? plantCode;
  final List<SalesOrderItemsDto>? selectedProduct;
  final String? salesOrderNo;
  final String? requestReferenceCode;
  final String? vat;
  final String? valueBeforeTax;
  final String? sscl;
  final String? totalOrderValue;
  final String? orderQty;
  final String? unitPrice;
  final String? total;
  const BlockedSOView({
    Key? key,
    required this.shipTo,
    required this.orderType,
    required this.shippingCondition,
    required this.plantName,
    required this.plantCode,
    required this.selectedProduct,
    required this.salesOrderNo,
    required this.requestReferenceCode,
    required this.vat,
    required this.valueBeforeTax,
    required this.sscl,
    required this.totalOrderValue,
    required this.orderQty,
    required this.unitPrice,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8E00),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                  height: 24,
                  width: 60,
                  child: Center(
                    child: Text(
                      "Blocked",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Flexible(
            child: ListView(
              children: [
                UnblockShippingDetailsCard(
                  shipTo: shipTo ?? "N/A",
                  orderType: orderType ?? "N/A",
                  shippingCondition: shippingCondition ?? "N/A",
                  plant: "$plantCode $plantName",
                ),
                const Divider(
                  color: Color(0xFFD2D2D2),
                  thickness: 1,
                  endIndent: 10,
                  indent: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MediaQuery.of(context).size.width >= 360
                        ? Text(
                            "Order Summary",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFFDA4540),
                                ),
                          )
                        : Text(
                            "Order Summary",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: const Color(0xFFDA4540),
                                ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: DashedDivider(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: selectedProduct
                          ?.map((selectedProduct) => UnblockOrderSummaryCard(
                              productDescription: selectedProduct.product?.productName ?? "N/A",
                              unitPrice: selectedProduct.unitPrice,
                              orderQuantity: selectedProduct.quantity.toString(),
                              total: selectedProduct.valueBeforeTax.toString()))
                          .toList() ??
                      [],
                ),
                const Divider(
                  color: Color(0xFFD2D2D2),
                  thickness: 1,
                  endIndent: 10,
                  indent: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                UnblockValueCard(
                  valueBeforeTax: valueBeforeTax ?? "N/A",
                  vat: vat ?? "N/A",
                  sscl: sscl ?? "N/A",
                  totalOrderValue: totalOrderValue ?? "N/A",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestToUnblockOrderView(
                            salesOrderNumber: salesOrderNo,
                            requestReferenceCode: requestReferenceCode,
                            outstandingAmount: totalOrderValue,
                          ),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.standard,
                      minimumSize: MediaQuery.of(context).size.width >= 360
                          ? MaterialStateProperty.all(const Size.fromHeight(45))
                          : MaterialStateProperty.all(const Size.fromHeight(35)),
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                    child: const Text("REQUEST  TO UNBLOCK"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnblockShippingDetailsCard extends StatelessWidget {
  const UnblockShippingDetailsCard({
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
                    fit: BoxFit.scaleDown,
                    child: MediaQuery.of(context).size.width >= 360
                        ? Text(
                            "Ship To",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        : Text(
                            "Ship To",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              shipTo,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              shipTo,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Order Type",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Order Type",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                orderType,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )
                            : Text(
                                orderType,
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Shipping Condition",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Shipping Condition",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              shippingCondition,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              shippingCondition,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Plant",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Plant",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              plant,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              plant,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnblockOrderSummaryCard extends StatelessWidget {
  const UnblockOrderSummaryCard({
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

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.00;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    double? price = 0.00;
    if (unitPrice is int) {
      price = unitPrice.toDouble();
    } else if (unitPrice is double) {
      price = unitPrice;
    } else if (unitPrice is String) {
      // Use toString() to convert the Object to a String
      price = double.tryParse(unitPrice.toString()) ?? 0.00;
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Product Description",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Product Description",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                productDescription,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )
                            : Text(
                                productDescription,
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Unit Price (LKR)",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Unit Price (LKR)",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              formatAmount(price.toString()),
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              formatAmount(price.toString()),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Order Quantity",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Order Quantity",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              formatAmount(orderQuantity),
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              formatAmount(orderQuantity),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Total (LKR)",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Total (LKR)",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              formatAmount(total),
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              formatAmount(total),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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

class UnblockValueCard extends StatelessWidget {
  const UnblockValueCard({
    super.key,
    required this.valueBeforeTax,
    required this.vat,
    required this.sscl,
    required this.totalOrderValue,
  });
  final String valueBeforeTax;
  final String vat;
  final String sscl;
  final String totalOrderValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 100.0,
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Order Value",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Order Value",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                valueBeforeTax,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )
                            : Text(
                                valueBeforeTax,
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: const Color(0xFF000000),
                                    ),
                              )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "VAT (15%)",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "VAT (15%)",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              vat,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              vat,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "SSCL (2.17%)",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "SSCL (2.17%)",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              sscl,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              sscl,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              "Total Order Value",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Text(
                              "Total Order Value",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                  const SizedBox(width: 5),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MediaQuery.of(context).size.width >= 360
                          ? Text(
                              totalOrderValue,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )
                          : Text(
                              totalOrderValue,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: const Color(0xFF000000),
                                  ),
                            )),
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

class UnblockDashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const UnblockDashedDivider({
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
