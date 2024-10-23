import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../locator.dart';
import '../../widgets.dart';

class DeliveryOrderView extends StatelessWidget {
  const DeliveryOrderView({Key? key}) : super(key: key);

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
            Transform.scale(
              scale: 0.7,
              child: BackButton(
                onPressed: () => GoRouter.of(context).go("/delivery-order-creation-view"),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return DeliveryOrderViewBottomSheet(
                    onClose: Navigator.of(context).pop,
                    name: 'Sorting & Filtering',
                  );
                },
              );
            }, icon: const Icon(Icons.tune_outlined, color: Colors.black, size: 20)),
          ],
        ),
        const Flexible(
          child: DeliveryOrderSummeryView(),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FilledButton(
            onPressed: () => GoRouter.of(context).go("/delivery-order-submission-view"),
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
              backgroundColor: MaterialStateProperty.all(Colors.red.shade400),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            child: const Text("Create Shipment Request"),
          ),
        ),
        const SizedBox(height: 10),
      ]),
    );
  }
}

class DeliveryRepoValue {
  DeliveryRepoValue()
      : allOrders = [
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "12-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "OPEN",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "12-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "SUBMITTED",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "12-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "SUBMITTED",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "12-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "COMPLETED",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "12-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "CANCELLED",
          },
          {
            "orderId": "SO00583481238",
            "shipToCode": "9384477-Loc-B",
            "date": "12-02-2023",
            "orderValue": "LKR 16,450,250.00",
            "status": "BLOCKED",
          },
        ];

  final List<dynamic> allOrders;
}

class DeliveryRepo extends ValueNotifier<DeliveryRepoValue> {
  DeliveryRepo({DeliveryRepoValue? value}) : super(value ?? DeliveryRepoValue());

  List<dynamic> filterByStatus(String status) {
    return value.allOrders.where((element) => element["status"] == status).toList();
  }
}

class DeliveryOrderSummeryView extends StatelessWidget {
  const DeliveryOrderSummeryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: locate<DeliveryRepo>(),
      builder: (context, value, _) {
        return ListView.builder(
          itemCount: value.allOrders.length,
          itemBuilder: (context, index) {
            return DeliveryOrderCard(
              orderId: value.allOrders[index]["orderId"],
              shipToCode: value.allOrders[index]["shipToCode"],
              date: value.allOrders[index]["date"],
              orderValue: value.allOrders[index]["orderValue"],
              status: value.allOrders[index]["status"],
            );
          },
        );
      },
    );
  }
}

class DeliveryOrderCard extends StatelessWidget {
  const DeliveryOrderCard({
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
        ),
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4A7A36)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          height: 140.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                color: const Color(0xFF4A7A36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FittedBox(
                      child: Text(
                        "Sales Order",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FittedBox(
                      child: Text(
                        orderId,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FittedBox(
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(
                                "Order Date",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                                "Order Value",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                                "Incl VAT",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: const Color(0xFF000000),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  date,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                                  orderValue,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                                  orderValue,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryOrderViewBottomSheet extends StatefulWidget {
  const DeliveryOrderViewBottomSheet({
    Key? key,
    required this.name,
    required this.onClose,
  }) : super(key: key);

  final String name;
  final VoidCallback onClose;

  @override
  State<DeliveryOrderViewBottomSheet> createState() => _DeliveryOrderViewBottomSheetState();
}

class _DeliveryOrderViewBottomSheetState extends State<DeliveryOrderViewBottomSheet> {
  List<DeliveryRadioOption> shippingConditionOptions = [
    DeliveryRadioOption(title: "PickUp", value: 0),
    DeliveryRadioOption(title: "Delivery", value: 1),
  ];

  List<DeliveryRadioOption> shipUnitOptions = [
    DeliveryRadioOption(title: "Bag 1", value: 0),
    DeliveryRadioOption(title: "Bag 2", value: 1),
    DeliveryRadioOption(title: "Bag 3", value: 2),
  ];

  List<DeliveryRadioOption> plantOptions = [
    DeliveryRadioOption(title: "Plant 1", value: 0),
    DeliveryRadioOption(title: "Plant 2", value: 1),
    DeliveryRadioOption(title: "Plant 3", value: 2),
  ];

  List<DeliveryRadioOption> shipToOptions = [
    DeliveryRadioOption(title: "765645567", value: 0),
    DeliveryRadioOption(title: "S76554343", value: 1),
    DeliveryRadioOption(title: "766545437", value: 2),
  ];
  int? selectedShippingCondition;
  int? selectedShipUnit;
  int? selectedPlant;
  int? selectedShipTo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.0),
          topRight: Radius.circular(6.0),
        ),
      ),
      height: MediaQuery.of(context).size.height / 2,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 40, color: Colors.grey),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: FittedBox(
                        child: Text(
                          widget.name,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Shipping Condition",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: const Color(0xFF868687),
                      ),
                    ),
                    for (var option in shippingConditionOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedShippingCondition == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedShippingCondition,
                          onChanged: (value) {
                            setState(() {
                              selectedShippingCondition = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                    const Divider(
                      thickness: 2,
                    ),
                    Text(
                      "Ship Unit",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: const Color(0xFF868687),
                      ),
                    ),
                    for (var option in shipUnitOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedShipUnit == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedShipUnit,
                          onChanged: (value) {
                            setState(() {
                              selectedShipUnit = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                    const Divider(thickness: 2),
                    Text(
                      "Plant",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: const Color(0xFF868687),
                      ),
                    ),
                    for (var option in plantOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedPlant == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedPlant,
                          onChanged: (value) {
                            setState(() {
                              selectedPlant = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                    const Divider(thickness: 2),
                    Text(
                      "Ship To",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: const Color(0xFF868687),
                      ),
                    ),
                    for (var option in shippingConditionOptions)
                      Container(
                        decoration: BoxDecoration(
                          color: selectedShippingCondition == option.value ? const Color(0xFFECECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: RadioListTile<int>(
                          title: Text(option.title),
                          value: option.value,
                          groupValue: selectedShippingCondition,
                          onChanged: (value) {
                            setState(() {
                              selectedShippingCondition = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: const Color(0xFFDA4A40),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryRadioOption {
  final String title;
  final int value;

  DeliveryRadioOption({required this.title, required this.value});
}
