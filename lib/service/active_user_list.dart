import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';
import 'package:odms/ui/pages/dashboard.dart';

class ActiveUserListServiceData {
  List<ActiveUserDto> activeUserList;

  ActiveUserListServiceData({
    required this.activeUserList,
  });
}

class ActiveUserListService extends ValueNotifier<ActiveUserListServiceData> {
  ActiveUserListService() : super(ActiveUserListServiceData(activeUserList: []));
  late SelectedCustomerController controller;
  Future<ActiveUserListService> fetchCustomerActiveUserList() async {
    final selectedCustomerController = locate<SelectedCustomerController>();
    String? soldToCode = selectedCustomerController.value.soldToCode;

    value.activeUserList = await locate<RestService>().fetchActiveUserList(customerCode: soldToCode ?? "") ?? [];
    notifyListeners();
    return this;
  }
}
