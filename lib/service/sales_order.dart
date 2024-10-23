import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import '../ui/ui.dart';

class SalesOrderViewServiceData {
  List<SalesOrderCreateDto> salesOrders;

  SalesOrderViewServiceData({
    required this.salesOrders,
  });
}

class SalesOrderViewService extends ValueNotifier<SalesOrderViewServiceData> {
  SalesOrderViewService() : super(SalesOrderViewServiceData(salesOrders: []));
  late SelectedCustomerController controller;

  Future<SalesOrderViewService> fetchSalesOrder() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;

    value.salesOrders = await locate<RestService>().fetchAllSalesOrders(soldToCode: soldToCode??'');
    notifyListeners();
    return this;
  }

  List<SalesOrderCreateDto> filterByStatus(String? status, String? internalStatus) {
    return value.salesOrders.where((element) {
      if (element.status == status && element.internalStatus == internalStatus) {
        return true;
      }
      return false;
    }).toList();
  }
}
