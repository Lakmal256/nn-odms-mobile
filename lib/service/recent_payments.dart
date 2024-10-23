import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class RecentPaymentsViewServiceData {
  List<RecentPaymentsDto> recentPayments;

  RecentPaymentsViewServiceData({
    required this.recentPayments,
  });
}

class RecentPaymentsViewService extends ValueNotifier<RecentPaymentsViewServiceData> {
  RecentPaymentsViewService() : super(RecentPaymentsViewServiceData(recentPayments: []));
late SelectedCustomerController controller;
  Future<RecentPaymentsViewService> fetchRecentPayments() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;
    String? salesOrganizationCode = selectedCustomerController.value.salesOrganizationCode;

    value.recentPayments =
        await locate<RestService>().fetchAllRecentPayments(customerCode: soldToCode??"", companyCode: salesOrganizationCode??"") ?? [];
    notifyListeners();
    return this;
  }
}
