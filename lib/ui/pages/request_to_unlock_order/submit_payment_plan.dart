import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../locator.dart';
import '../../../service/service.dart';
import '../../ui.dart';

class SubmitPaymentPlanView extends StatefulWidget {
  final String? outstandingAmount;
  final String? requestReferenceCode;
  const SubmitPaymentPlanView({Key? key, required this.outstandingAmount, required this.requestReferenceCode})
      : super(key: key);

  @override
  State<SubmitPaymentPlanView> createState() => _SubmitPaymentPlanViewState();
}

class _SubmitPaymentPlanViewState extends State<SubmitPaymentPlanView> {
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController remarkTextEditingController = TextEditingController();

  List<Plans> addedRecords = [];

  String formatAmount(String amount) {
    double numericAmount = double.tryParse(amount) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,###.00');
    return formatter.format(numericAmount);
  }

  @override
  void initState() {
    super.initState();
    paymentAmountController.addListener(_updateButtonState);
    paymentDateController.addListener(_updateButtonState);
  }

  bool isButtonEnabled = false;
  final Color enabledButtonColor = const Color(0xFF4A7A36);
  final Color disabledButtonColor = Colors.grey;

  void _updateButtonState() {
    bool isAmountNotEmpty = paymentAmountController.text.isNotEmpty;
    bool isDateNotEmpty = paymentDateController.text.isNotEmpty;
    double paymentAmount = double.tryParse(paymentAmountController.text) ?? 0.0;
    bool isAmountValid = paymentAmount > 0.0;
    setState(() {
      isButtonEnabled = isAmountNotEmpty && isDateNotEmpty && isAmountValid;
    });
  }

  Future<void> unblockRequestWithPlan(List<Plans> plans) async {
    List<Map<String, dynamic>> planList = plans.map((plans) {
      return {
        "amount": plans.amount,
        "date": plans.date,
      };
    }).toList();

    try {
      if (remarkTextEditingController.text.isEmpty) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Remarks is required",
            subtitle: "Please enter remarks",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      } else if (addedRecords.isEmpty) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "No Payment Plan Added",
            subtitle: "Please enter at least one payment plan",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }
      locate<LoadingIndicatorController>().show();
      await locate<RestService>().unblockRequestWithPlan(
        planList: planList,
        requestReferenceCode: widget.requestReferenceCode,
        remarks: remarkTextEditingController.text,
        type: "PLAN",
      );
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Payment Plan Submit Successfully",
          subtitle: "Successfully submitted payment plans",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
      GoRouter.of(context).push("/view-sales-orders");
    } catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithTM(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            color: const Color(0xFF4A7A36).withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Submit Payment Plan",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF4A7A36)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Outstanding: ${widget.outstandingAmount}",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, color: Colors.red.withOpacity(0.8)),
                  ),
                  const Divider(
                    color: Color(0xFF4A7A36),
                    height: 20,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Please create a plan below with payment\namount and date to cover the outstanding\nabove.",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF929292),
                          ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: remarkTextEditingController,
                      autocorrect: false,
                      onChanged: (value) {},
                      maxLines: 3,
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        hintText: 'Remarks..',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Payment Amount (LKR)",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
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
                      controller: paymentAmountController,
                      autocorrect: false,
                      onChanged: (value) {},
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        hintText: '0.0',
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
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Payment Date",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
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
                      controller: paymentDateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != DateTime.now()) {
                          paymentDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                        }
                      },
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF000000)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        hintText: 'Select Payment Date',
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
                const SizedBox(height: 20),
                PaymentPlanAddButton(
                  onPressed: isButtonEnabled
                      ? () {
                          String paymentAmount = paymentAmountController.text;
                          String paymentDate = paymentDateController.text;
                          if (paymentAmount.isNotEmpty && paymentDate.isNotEmpty) {
                            setState(() {
                              addedRecords.add(Plans(amount: paymentAmount, date: paymentDate));
                              paymentAmountController.text = '';
                              paymentDateController.text = '';
                            });
                          }
                        }
                      : null,
                  buttonColor: isButtonEnabled ? enabledButtonColor : disabledButtonColor,
                ),
                const SizedBox(height: 20),
                DataTable(
                  columns: [
                    DataColumn(
                      label: Flexible(
                        child: FittedBox(
                          child: MediaQuery.of(context).size.width >= 360 ? Text(
                            "Payment Date",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                ),
                          ) : Text(
                            "Payment Date",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Flexible(
                        child: FittedBox(
                          child: MediaQuery.of(context).size.width >= 360 ? Text(
                            "Payment (LKR)",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                ),
                          ) : Text(
                            "Payment (LKR)",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: addedRecords.map((record) {
                    List<String> data = [record.date ?? '', record.amount ?? ''];
                    return DataRow(
                      cells: [
                        DataCell(Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.zero,
                              child: IconButton(
                                icon: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    addedRecords.remove(record);
                                  });
                                },
                              ),
                            ),
                            Text(data[0]),
                          ],
                        )),
                        DataCell(
                          Text(formatAmount(data[1])),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                if (addedRecords.isEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "No Payment Plan Added",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF929292),
                            ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UploadPlanConfirmationButton(
                        onPressed: () {
                          unblockRequestWithPlan(addedRecords);
                        },
                      ),
                      UploadPlanCancelButton(onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPlanAddButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color buttonColor;

  const PaymentPlanAddButton({Key? key, required this.onPressed, required this.buttonColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          minimumSize: MediaQuery.of(context).size.width >= 360
              ? MaterialStateProperty.all(const Size.fromHeight(50))
              : MaterialStateProperty.all(const Size.fromHeight(40)),
          backgroundColor: MaterialStateProperty.all(buttonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          elevation: MaterialStateProperty.all(3),
        ),
        child: Text(
          "ADD",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

class UploadPlanConfirmationButton extends StatelessWidget {
  final void Function()? onPressed;

  const UploadPlanConfirmationButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width >= 360 ? 160 : 130,
        height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
        child: FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            elevation: MaterialStateProperty.all(3),
          ),
          child: Text(
            "Submit",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class UploadPlanCancelButton extends StatelessWidget {
  final void Function()? onPressed;

  const UploadPlanCancelButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width >= 360 ? 160 : 130,
        height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
        child: FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: MaterialStateProperty.all(Colors.grey),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            elevation: MaterialStateProperty.all(3),
          ),
          child: Text(
            "Cancel",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class Plans {
  String? amount;
  String? date;

  Plans({
    this.amount,
    this.date,
  });
}
