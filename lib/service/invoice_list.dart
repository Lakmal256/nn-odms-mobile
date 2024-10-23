import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class InvoiceListServiceData {
  List<InvoiceListDto> invoiceList;

  InvoiceListServiceData({
    required this.invoiceList,
  });
}

class InvoiceListService extends ValueNotifier<InvoiceListServiceData> {
  InvoiceListService() : super(InvoiceListServiceData(invoiceList: []));
  late SelectedCustomerController controller;
  Future<InvoiceListService> fetchCustomerInvoiceList() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;
    String? salesOrganizationCode = selectedCustomerController.value.salesOrganizationCode;
    String? openAtKeyDays = DateFormat('dd-MM-yyyy').format(DateTime.now());

    value.invoiceList =
        await locate<RestService>().fetchInvoiceList(customerCode: soldToCode??"", companyCode: salesOrganizationCode??"", openAtKeyDays: openAtKeyDays) ?? [];
    notifyListeners();
    return this;
  }
}
