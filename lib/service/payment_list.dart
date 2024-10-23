import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class PaymentListServiceData {
  List<PaymentListDto> paymentList;

  PaymentListServiceData({
    required this.paymentList,
  });
}

class PaymentListService extends ValueNotifier<PaymentListServiceData> {
  PaymentListService() : super(PaymentListServiceData(paymentList: []));
  late SelectedCustomerController controller;
  Future<PaymentListService> fetchCustomerPaymentList() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;
    String? salesOrganizationCode = selectedCustomerController.value.salesOrganizationCode;
    String? openAtKeyDays = DateFormat('dd-MM-yyyy').format(DateTime.now());
    value.paymentList =
        await locate<RestService>().fetchPaymentList(customerCode: soldToCode??"", companyCode: salesOrganizationCode??"", openAtKeyDays: openAtKeyDays) ?? [];
    notifyListeners();
    return this;
  }
}
