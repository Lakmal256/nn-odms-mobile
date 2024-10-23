import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:odms/app_config.dart';

import 'service/service.dart';

import 'ui/ui.dart';

GetIt getIt = GetIt.instance;

setupServiceLocator(AppConfig config) async {
  LocalTokenHandler localTokenHandler = LocalTokenHandler();
  String? refreshToken = await localTokenHandler.readRefreshToken();

  AuthService authService = StandardAuthService(
      authority: config.authority!, apimDomain: config.apimDomain!, swaggerDomain: config.swaggerDomain!);
  TokenProvider tokenProvider = TokenProvider(
    service: authService,
    refreshToken: refreshToken,
  );

  getIt.registerSingleton(tokenProvider);
  getIt.registerSingleton(config);
  getIt.registerSingleton(RestService(
      authority: config.authority!,
      apimDomain: config.apimDomain!,
      swaggerDomain: config.swaggerDomain!,
      tokenProvider: tokenProvider));
  getIt.registerSingleton(UserService(User(data: UserData.empty())));
  getIt.registerSingleton(OrdersRepo());
  getIt.registerSingleton(DeliveryRepo());
  getIt.registerSingleton(SalesOrderViewService());
  getIt.registerSingleton(LastDeliveryViewService());
  getIt.registerSingleton(RecentPaymentsViewService());
  getIt.registerSingleton(PaymentListService());
  getIt.registerSingleton(InvoiceListService());
  getIt.registerSingleton(PaymentSetoffListService());
  getIt.registerSingleton(RecentSalesOrderViewService());
  getIt.registerSingleton(RecentDeliveriesViewService());
  getIt.registerSingleton(ShipToCodeListService());
  getIt.registerSingleton(ActiveUserListService());
  getIt.registerSingleton(LatestInvoiceViewService());
  getIt.registerSingleton(RecentBlockedSalesOrderViewService());

  getIt.registerSingleton(AppLocaleNotifier(const Locale("en")));
  getIt.registerSingleton(PopupController());
  getIt.registerLazySingleton(() => LoadingIndicatorController());
  getIt.registerSingleton<SelectedCustomerController>(SelectedCustomerController());
  getIt.registerSingleton<FileUploadController>(FileUploadController());
  getIt.registerSingleton(CloudMessagingHelperService(
      restService: RestService(
          authority: config.authority!,
          apimDomain: config.apimDomain!,
          swaggerDomain: config.swaggerDomain!,
          tokenProvider: tokenProvider)));
}

T locate<T extends Object>() => GetIt.instance<T>();
