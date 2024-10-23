import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:odms/ui/ui.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class DeliveryOrderSubmissionView extends StatelessWidget {
  const DeliveryOrderSubmissionView({Key? key}) : super(key: key);

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
                    onPressed: () => GoRouter.of(context).go("/delivery-order-creation-view"),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: const StepProgressIndicator(
                      totalSteps: 3,
                      currentStep: 2,
                      padding: 4,
                      selectedColor: Color(0xFF4A7A36),
                      roundedEdges: Radius.circular(15),
                      unselectedColor: Color(0xFFD9D9D9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FittedBox(
              child: Text(
                "Please verify and submit the shipment request summary",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Flexible(
            child: ListView(
              children: [
                const DeliveryOrderShippingDetailsCard(
                  shippingCondition: "Delivered",
                  shippingUnit: "Bags",
                  plant: 'Plant 1',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Order Summery",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFFDA4540),
                          ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const DODashedDivider(),
                const SizedBox(
                  height: 20,
                ),
                const DeliveryOrderSummeryCard(
                  salesOrderNo: "SO00583481238",
                  productDescription: "INSEE Sanstha",
                  orderQuantity: "1000 Bags",
                  remainingQuantity: "0",
                  shipTo: '949999923 - Kandy',
                ),
                const SizedBox(
                  height: 30,
                ),
                const DeliveryOrderSummeryCard(
                  salesOrderNo: "SO00583481238",
                  productDescription: "INSEE Mahaweli Marine Plus",
                  orderQuantity: "200 Bags",
                  remainingQuantity: "50 Bags",
                  shipTo: '376346374 - Galle',
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FilledButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return DeliveryOrderBottomSheet(
                            onClose: Navigator.of(context).pop,
                            name: 'Sorting & Filtering',
                          );
                        },
                      );
                    },
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
                    child: const Text("SET YOUR DELIVERY INFORMATION"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FilledButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      visualDensity: VisualDensity.standard,
                      minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                    child: const Text("SUBMIT ORDER"),
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

class DeliveryOrderShippingDetailsCard extends StatelessWidget {
  const DeliveryOrderShippingDetailsCard({
    super.key,
    required this.shippingUnit,
    required this.shippingCondition,
    required this.plant,
  });
  final String shippingUnit;
  final String shippingCondition;
  final String plant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Colors.white,
        height: 100.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Shipping Condition",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        shippingCondition,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
            const DODashedDivider(),
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
                    child: Text(
                      "Shipping Unit",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      shippingUnit,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DODashedDivider(),
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
                    child: Text(
                      "Plant",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      plant,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryOrderSummeryCard extends StatelessWidget {
  const DeliveryOrderSummeryCard({
    super.key,
    required this.salesOrderNo,
    required this.productDescription,
    required this.orderQuantity,
    required this.remainingQuantity,
    required this.shipTo,
  });
  final String salesOrderNo;
  final String productDescription;
  final String orderQuantity;
  final String remainingQuantity;
  final String shipTo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Colors.white,
        height: 150.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      "Sales Order No",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        salesOrderNo,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
            const DODashedDivider(),
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
                    child: Text(
                      "Product Description",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      productDescription,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DODashedDivider(),
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
                    child: Text(
                      "Delivery Order Qty",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      orderQuantity,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DODashedDivider(),
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
                    child: Text(
                      "Remaining Qty",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      remainingQuantity,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const DODashedDivider(),
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
                    child: Text(
                      "Ship To",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  FittedBox(
                    child: Text(
                      shipTo,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DODashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DODashedDivider({
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

class DeliveryOrderBottomSheet extends StatefulWidget {
  const DeliveryOrderBottomSheet({
    Key? key,
    required this.name,
    required this.onClose,
  }) : super(key: key);

  final String name;
  final VoidCallback onClose;

  @override
  State<DeliveryOrderBottomSheet> createState() => _DeliveryOrderBottomSheetState();
}

class _DeliveryOrderBottomSheetState extends State<DeliveryOrderBottomSheet> {
  final TextEditingController arrivalDateController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  late SingleValueDropDownController _cnt;

  @override
  void initState() {
    _cnt = SingleValueDropDownController();
    super.initState();
  }

  @override
  void dispose() {
    _cnt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
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
                          "Delivery Information",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF868687),
                              ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextField(
                              controller: arrivalDateController,
                              readOnly: true,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != DateTime.now()) {
                                  arrivalDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                                }
                              },
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                suffixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF000000)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                                hintText: 'Expected Arrival Date',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextField(
                              controller: arrivalTimeController,
                              readOnly: true,
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  // Convert the selected time to a formatted string
                                  final String formattedTime = picked.format(context).toString();
                                  arrivalTimeController.text = formattedTime;
                                }
                              },
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                suffixIcon: const Icon(Icons.access_time, color: Color(0xFF000000)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                                hintText: 'Time',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: DropDownTextField(
                            textFieldDecoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Transporter",
                            ),
                            controller: _cnt,
                            clearOption: true,
                            validator: (value) {
                              if (value == null) {
                                return "Required field";
                              } else {
                                return null;
                              }
                            },
                            dropDownItemCount: 4,
                            dropDownList: const [
                              DropDownValueModel(name: 'transporter1', value: "value1"),
                              DropDownValueModel(name: 'transporter2', value: "value2"),
                            ],
                            onChanged: (val) {},
                          ),
                        ),
                        const SizedBox(height: 10),
                        const RemarkBox(),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FilledButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              visualDensity: VisualDensity.standard,
                              minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                              backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                            ),
                            child: const Text("ASSIGN"),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FilledButton(
                            onPressed: Navigator.of(context).pop,
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
                            child: const Text("CANCEL"),
                          ),
                        ),
                        const SizedBox(height: 10),
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

class RemarkBox extends StatefulWidget {
  const RemarkBox({Key? key}) : super(key: key);

  @override
  _RemarkBoxState createState() => _RemarkBoxState();
}

class _RemarkBoxState extends State<RemarkBox> {
  TextEditingController shippingRemarkTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextField(
          controller: shippingRemarkTextEditingController,
          autocorrect: false,
          onChanged: (value) {},
          maxLines: 5,
          textAlign: TextAlign.left,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            hintText: 'Shipping Remark',
          ),
        ),
      ),
    );
  }
}
