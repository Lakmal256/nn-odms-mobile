import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class RecentSalesOrderViewServiceData {
  List<RecentSalesOrderDto> recentSalesOrders;

  RecentSalesOrderViewServiceData({
    required this.recentSalesOrders,
  });
}

class RecentSalesOrderViewService extends ValueNotifier<RecentSalesOrderViewServiceData> {
  RecentSalesOrderViewService() : super(RecentSalesOrderViewServiceData(recentSalesOrders: []));
  late SelectedCustomerController controller;
  Future<RecentSalesOrderViewService> fetchRecentSalesOrders() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;
    String? salesOrgCode = selectedCustomerController.value.salesOrganizationCode;

    value.recentSalesOrders = await locate<RestService>()
        .fetchAllRecentSalesOrders(customerCode: soldToCode ?? "", companyCode: salesOrgCode ?? "") ??
        [];
    notifyListeners();
    return this;
  }

  List<RecentSalesOrderDto> filterByStatus(String status) {
    return value.recentSalesOrders.where((element) => element.status == status).toList();
  }
}
