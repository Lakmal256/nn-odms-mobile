import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class PaymentSetoffListServiceData {
  List<PaymentSetoffListDto> setoffList;

  PaymentSetoffListServiceData({
    required this.setoffList,
  });
}

class PaymentSetoffListService extends ValueNotifier<PaymentSetoffListServiceData> {
  PaymentSetoffListService() : super(PaymentSetoffListServiceData(setoffList: []));
  late SelectedCustomerController controller;
  Future<PaymentSetoffListService> fetchCustomerSetoffList() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;

    value.setoffList =
        await locate<RestService>().fetchPaymentSetoffList(soldToCode: soldToCode??"") ?? [];
    notifyListeners();
    return this;
  }
}
