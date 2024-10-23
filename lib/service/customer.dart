import 'package:flutter/foundation.dart';
import 'package:odms/locator.dart';
import 'package:odms/service/dto.dart';
import 'package:odms/service/rest.dart';

class ShipToCodeListServiceData {
  List<ShipToListDto> shipToCodeList;

  ShipToCodeListServiceData({
    required this.shipToCodeList,
  });
}

class ShipToCodeListService extends ValueNotifier<ShipToCodeListServiceData> {
  ShipToCodeListService() : super(ShipToCodeListServiceData(shipToCodeList: []));

  Future<ShipToCodeListService> fetchShipToList({required String soldToCode}) async {

    value.shipToCodeList =
        await locate<RestService>().getShipToListByCustomer(soldToCode: soldToCode) ?? [];
    notifyListeners();
    return this;
  }
}