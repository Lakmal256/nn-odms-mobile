import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import '../ui/ui.dart';

class LastDeliveryViewServiceData {
  List<LastDeliveryDto> lastDeliveries;

  LastDeliveryViewServiceData({
    required this.lastDeliveries,
  });
}

class LastDeliveryViewService extends ValueNotifier<LastDeliveryViewServiceData> {
  LastDeliveryViewService() : super(LastDeliveryViewServiceData(lastDeliveries: []));
  late SelectedCustomerController controller;
  Future<LastDeliveryViewService> fetchLastDelivery() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? customerCode = selectedCustomerController.value.soldToCode;
    String? companyCode = selectedCustomerController.value.salesOrganizationCode;

    value.lastDeliveries =
        await locate<RestService>().fetchAllLastDeliveries(customerCode: customerCode!, companyCode: companyCode!) ?? [];
    notifyListeners();
    return this;
  }

  List<LastDeliveryDto> filterByStatus(String status) {
    return value.lastDeliveries.where((element) => element.status == status).toList();
  }
}

class RecentDeliveriesViewServiceData {
  List<LastDeliveryDto> recentDeliveries;

  RecentDeliveriesViewServiceData({
    required this.recentDeliveries,
  });
}

class RecentDeliveriesViewService extends ValueNotifier<RecentDeliveriesViewServiceData> {
  RecentDeliveriesViewService() : super(RecentDeliveriesViewServiceData(recentDeliveries: []));
  late SelectedCustomerController controller;
  Future<RecentDeliveriesViewService> fetchRecentDeliveries() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? customerCode = selectedCustomerController.value.soldToCode;
    String? companyCode = selectedCustomerController.value.salesOrganizationCode;

    value.recentDeliveries =
        await locate<RestService>().fetchAllRecentDeliveries(customerCode: customerCode??'', companyCode: companyCode??'') ??
            [];
    notifyListeners();
    return this;
  }
}
