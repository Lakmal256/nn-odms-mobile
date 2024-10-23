import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class LatestInvoicesViewServiceData {
  List<RecentPaymentsDto> latestInvoices;

  LatestInvoicesViewServiceData({
    required this.latestInvoices,
  });
}

class LatestInvoiceViewService extends ValueNotifier<LatestInvoicesViewServiceData> {
  LatestInvoiceViewService() : super(LatestInvoicesViewServiceData(latestInvoices: []));
  late SelectedCustomerController controller;
  Future<LatestInvoiceViewService> fetchLatestInvoices() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;
    String? salesOrganizationCode = selectedCustomerController.value.salesOrganizationCode;

    value.latestInvoices = await locate<RestService>()
        .fetchAllLatestInvoices(customerCode: soldToCode ?? "", companyCode: salesOrganizationCode ?? "") ??
        [];
    notifyListeners();
    return this;
  }
}
