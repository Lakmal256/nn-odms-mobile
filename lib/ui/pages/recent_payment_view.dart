import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class RecentPaymentsView extends StatefulWidget {
  const RecentPaymentsView({Key? key}) : super(key: key);

  @override
  State<RecentPaymentsView> createState() => _RecentPaymentsViewState();
}

class _RecentPaymentsViewState extends State<RecentPaymentsView> {
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<RecentPaymentsViewService>().fetchRecentPayments();
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
                      "Recent Payments",
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
                  valueListenable: locate<RecentPaymentsViewService>(),
                  builder: (context, snapshot, _) {
                    if (snapshot.recentPayments.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Recent Payments.")),
                      );
                    }
                    snapshot.recentPayments.sort((a, b) {
                      DateTime dateA = DateFormat("dd-MM-yyyy").parse(a.date!);
                      DateTime dateB = DateFormat("dd-MM-yyyy").parse(b.date!);
                      return dateB.compareTo(dateA); // Descending order
                    });
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.recentPayments
                          .map(
                            (recentPayments) => RecentPaymentCard(
                              salesOrderNo: recentPayments.soNumber ?? "N/A",
                              date: recentPayments.date ?? "N/A",
                              orderValue: recentPayments.amount.toString(),
                              referenceNo: recentPayments.referenceNumber ?? "N/A",
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

class RecentPaymentCard extends StatelessWidget {
  const RecentPaymentCard({
    Key? key,
    required this.salesOrderNo,
    required this.date,
    required this.orderValue,
    required this.referenceNo,
  }) : super(key: key);

  final String salesOrderNo;
  final String date;
  final String orderValue;
  final String referenceNo;

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
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          salesOrderNo,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: const Color(0xFF1D1B23),
                              ),
                        ),
                      ),
                      const Spacer(),
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
                            "Reference No",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            referenceNo,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFF1D1B23),
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
                                      .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: formatAmount(orderValue),
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
