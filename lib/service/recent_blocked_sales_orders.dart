import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class RecentBlockedSalesOrderViewServiceData {
  List<RecentBlockedSalesOrderDto> recentBlockedSalesOrders;

  RecentBlockedSalesOrderViewServiceData({
    required this.recentBlockedSalesOrders,
  });
}

class RecentBlockedSalesOrderViewService extends ValueNotifier<RecentBlockedSalesOrderViewServiceData> {
  RecentBlockedSalesOrderViewService() : super(RecentBlockedSalesOrderViewServiceData(recentBlockedSalesOrders: []));
  late SelectedCustomerController controller;
  Future<RecentBlockedSalesOrderViewService> fetchRecentBlockedSalesOrders() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;
    String? salesOrganizationCode = selectedCustomerController.value.salesOrganizationCode;

    value.recentBlockedSalesOrders = await locate<RestService>()
        .fetchAllRecentBlockedSalesOrders(customerCode: soldToCode ?? "", companyCode: salesOrganizationCode ?? "") ??
        [];
    notifyListeners();
    return this;
  }
}
