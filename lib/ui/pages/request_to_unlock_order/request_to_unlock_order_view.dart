import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui.dart';

class RequestToUnblockOrderView extends StatefulWidget {
  final String? salesOrderNumber;
  final String? requestReferenceCode;
  final String? outstandingAmount;
  const RequestToUnblockOrderView({Key? key, required this.salesOrderNumber, required this.requestReferenceCode, required this.outstandingAmount}) : super(key: key);

  @override
  State<RequestToUnblockOrderView> createState() => _RequestToUnblockOrderViewState();
}

class _RequestToUnblockOrderViewState extends State<RequestToUnblockOrderView> {
  int? _selectedOption;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithTM(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 0.7,
                child: BackButton(
                  onPressed: ()=> GoRouter.of(context).push("/view-sales-orders"),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF4A7A36),
                      width: 2.0,
                    ),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Request To Unblock Order",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A7A36),
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Select the option below to submit the unblock\nrequest",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF929292),
                    ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedOption = 0;
                });
              },
              child: Row(
                children: [
                  Radio(
                    value: 0,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    activeColor: const Color(0xFF4A7A36),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Upload Deposit Slip for payment already made.",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedOption = 1;
                });
              },
              child: Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    activeColor: const Color(0xFF4A7A36),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Submit a payment plan for outstanding amount.",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          UnblockOrderNextButton(
            onPressed: _selectedOption == null
                ? null // Disable the button when no option is selected
                : () {
                    // Navigate to the appropriate screen based on the selected option
                    if (_selectedOption == 0) {
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadPaymentConfirmationView(
                              salesOrderNumber: widget.salesOrderNumber,
                                requestReferenceCode: widget.requestReferenceCode,
                            ),
                          ),
                        );
                      }
                    } else if (_selectedOption == 1) {
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubmitPaymentPlanView(
                              outstandingAmount: widget.outstandingAmount,
                              requestReferenceCode: widget.requestReferenceCode,
                            ),
                          ),
                        );
                      }
                    }
                  },
            selectedOption: _selectedOption,
          ),
        ],
      ),
    );
  }
}

class UnblockOrderNextButton extends StatelessWidget {
  final void Function()? onPressed;
  final int? selectedOption;

  const UnblockOrderNextButton({Key? key, required this.onPressed, required this.selectedOption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = selectedOption == null ? Colors.grey : const Color(0xFF4A7A36);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
          backgroundColor: MaterialStateProperty.all(buttonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          elevation: MaterialStateProperty.all(3),
        ),
        child: Text(
          "NEXT",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
