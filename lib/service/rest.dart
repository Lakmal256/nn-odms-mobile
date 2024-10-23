import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'service.dart';

class RestErrorHandler {
  handleClientError(String message, Uri? uri) {
    throw UnimplementedError();
  }

  handleHttpError(String message, Uri? uri) {
    throw UnimplementedError();
  }

  handleAuthError() {
    throw UnimplementedError();
  }

  handleUnknownError() {
    throw UnimplementedError();
  }
}

enum OtpMethod { email, mobile }

class RestService {
  String authority;
  String apimDomain;
  String swaggerDomain;
  TokenProvider tokenProvider;

  RestService({
    required this.authority,
    required this.apimDomain,
    required this.swaggerDomain,
    required this.tokenProvider,
  });

  Future<UserResponseDto?> getUserByEmail(String value) async {
    String email = value.toLowerCase();
    String encodedEmail = Uri.encodeComponent(email);
    final token = await tokenProvider.getToken('');
    String path = "/${apimDomain}systemcore/v1.0.0/identity/user/email/$encodedEmail";
    final response = await http.get(
      Uri.parse("https://$authority$path"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      final decodedJson = json.decode(response.body);
      final errorMessage = decodedJson['message'] ?? 'Unauthorised';
      throw UnauthorizedException(errorMessage);
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<bool> userExist(String email) async {
    String email0 = email.toLowerCase();
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/identity/user/email/exist", {
        "email": email0,
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      var result = decodedJson["result"];
      return result ?? (throw Exception());
    }

    throw Exception();
  }

  Future<bool> updateUser({
    int? id,
    String? firstName,
    String? lastName,
  }) async {
    final token = await tokenProvider.getToken('');
    final response = await http.put(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/identity/user/profile/$id"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "identityId": tokenProvider.identityId!,
      }),
    );
    return response.statusCode == HttpStatus.accepted;
  }

  Future<String> sendOtp(String email, {String type = "rp"}) async {
    String email0 = email.toLowerCase();
    String encodedEmail = Uri.encodeComponent(email0);
    String path = "/${apimDomain}systemcore/v1.0.0/utility/sendotp/$encodedEmail/$type";
    final response = await http.post(
      Uri.parse("https://$authority$path"),
    );

    if (response.statusCode == HttpStatus.accepted) {
      final decodedJson = json.decode(response.body);
      var result = decodedJson["result"];
      return result ?? (throw Exception());
    } else if (response.statusCode == HttpStatus.unauthorized) {
      final decodedJson = json.decode(response.body);
      final errorMessage = decodedJson['message'] ?? 'Unauthorized';
      throw UnauthorizedException(errorMessage);
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }
    throw Exception();
  }

  Future<String> verifyOtp(String email, String otp) async {
    String email0 = email.toLowerCase();
    String encodedEmail = Uri.encodeComponent(email0);
    String path = "/${apimDomain}systemcore/v1.0.0/utility/verifyotp/$encodedEmail/$otp";
    final response = await http.post(
      Uri.parse("https://$authority$path"),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      var result = decodedJson["result"];
      return result ?? (throw Exception());
    }

    throw Exception();
  }

  Future<bool> resetPasswordWithAuthorizationCode(String code, {required String password}) async {
    try {
      final response = await http.post(
        Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/identity/user/resetpassword/$code"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"password": password}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return true;
      } else if (response.statusCode == HttpStatus.badRequest) {
        final decodedJson = json.decode(response.body);
        final errorMessage = decodedJson['result'] ?? 'Invalid Password';
        throw PasswordResetException(errorMessage);
      } else if (response.statusCode == HttpStatus.permanentRedirect) {
        // Handle the redirect explicitly if needed
        final newUri = response.headers['location'];
        if (newUri != null) {
          // You can make a new request using the new URI
          final newResponse = await http.post(Uri.parse(newUri),
              headers: {'Content-Type': 'application/json'}, body: jsonEncode({"password": password}));

          if (newResponse.statusCode == HttpStatus.ok) {
            return true;
          }
        }
      }

      throw Exception('Request failed with status: ${response.statusCode}');
    } catch (e) {
      // Handle other exceptions
      throw Exception('Failed to reset password');
    }
  }

  Future<bool> initUpdateMobile(String mobileNumber) async {
    final token = await tokenProvider.getToken('');
    final response = await http.put(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/identity/user/mobile/init/$mobileNumber"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
        'user-iam-id': tokenProvider.identityId!,
      },
    );

    if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    return response.statusCode == HttpStatus.accepted;
  }

  Future<bool> completeUpdateMobile(String mobileNumber, String authorizationCode) async {
    final token = await tokenProvider.getToken('');
    final response = await http.put(
      Uri.https(
        authority,
        "/${apimDomain}systemcore/v1.0.0/identity/user/mobile/complete/$mobileNumber",
        {"authorizationCode": authorizationCode},
      ),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
        'user-iam-id': tokenProvider.identityId!,
      },
    );
    return response.statusCode == HttpStatus.accepted;
  }

  Future<List<SalesOrderCreateDto>> fetchAllSalesOrders({required String soldToCode}) async {
    final token = await tokenProvider.getToken('');
    List<SalesOrderCreateDto> allSalesOrders = [];

    int pageNumber = 0;
    int pageSize = 10;
    bool hasNextPage = true;

    while (hasNextPage) {
      final response = await http.get(
        Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/customer", {
          "soldToCode": soldToCode,
          "pageSize": '$pageSize',
          "pageNumber": '$pageNumber',
        }),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == HttpStatus.ok) {
        final decodedJson = json.decode(response.body);
        final pageSalesOrders =
            (decodedJson['salesOrderResponses'] as List).map((data) => SalesOrderCreateDto.fromJson(data)).toList();
        allSalesOrders.addAll(pageSalesOrders);

        if (pageSalesOrders.length < pageSize) {
          hasNextPage = false;
        } else {
          pageNumber++; // Move to the next page
        }
      } else {
        // Handle errors here if needed
        hasNextPage = false;
      }
    }

    return allSalesOrders;
  }

  Future<List<LastDeliveryDto>?> fetchAllLastDeliveries(
      {required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/deliveries", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<LastDeliveryDto> lastDelivery = [];
      for (var userJson in jsonBody ?? []) {
        LastDeliveryDto lastDeliveryDto = LastDeliveryDto.fromJson(userJson);
        lastDelivery.add(lastDeliveryDto);
      }
      return lastDelivery;
    }
    return [];
  }

  Future<List<RecentSalesOrderDto>?> fetchAllRecentSalesOrders(
      {required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/so-recent", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<RecentSalesOrderDto> recentSalesOrders = [];
      for (var userJson in jsonBody ?? []) {
        RecentSalesOrderDto salesOrderDto = RecentSalesOrderDto.fromJson(userJson);
        recentSalesOrders.add(salesOrderDto);
      }
      return recentSalesOrders;
    }
    return [];
  }

  Future<List<RecentPaymentsDto>?> fetchAllRecentPayments(
      {required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/payments", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<RecentPaymentsDto> recentPayments = [];
      for (var userJson in jsonBody ?? []) {
        RecentPaymentsDto recentPaymentsDto = RecentPaymentsDto.fromJson(userJson);
        recentPayments.add(recentPaymentsDto);
      }
      return recentPayments;
    }
    return [];
  }

  Future<List<PaymentsDto>?> fetchPayments({required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/payments", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<PaymentsDto> payments = [];
      for (var userJson in jsonBody ?? []) {
        PaymentsDto paymentsDto = PaymentsDto.fromJson(userJson);
        payments.add(paymentsDto);
      }
      return payments;
    }
    return [];
  }

  Future<List<PaymentListDto>?> fetchPaymentList(
      {required String customerCode, required String companyCode, required String openAtKeyDays}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/payment", {
        "CustomerCode": customerCode,
        "CompanyCode": companyCode,
        "OpenatKeydays": openAtKeyDays,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      final customerPaymentList = jsonBody["customerPaymentList"] as List<dynamic>;

      List<PaymentListDto> paymentList = [];
      for (var userJson in customerPaymentList) {
        PaymentListDto paymentListDto = PaymentListDto.fromJson(userJson);
        paymentList.add(paymentListDto);
      }
      return paymentList;
    }
    return [];
  }

  Future<List<InvoiceListDto>?> fetchInvoiceList(
      {required String customerCode, required String companyCode, required String openAtKeyDays}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/payment", {
        "CustomerCode": customerCode,
        "CompanyCode": companyCode,
        "OpenatKeydays": openAtKeyDays,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      final customerInvoiceList = jsonBody["customerInvoiceList"] as List<dynamic>;

      List<InvoiceListDto> invoiceList = [];
      for (var userJson in customerInvoiceList) {
        InvoiceListDto invoiceListDto = InvoiceListDto.fromJson(userJson);
        invoiceList.add(invoiceListDto);
      }
      return invoiceList;
    }
    return [];
  }

  Future<List<PaymentSetoffListDto>?> fetchPaymentSetoffList({required String soldToCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/payment/setoff", {
        "soldToCode": soldToCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      final customerPaymentList = jsonBody["paymentSetoffList"] as List<dynamic>;

      List<PaymentSetoffListDto> paymentSetoffList = [];
      for (var userJson in customerPaymentList) {
        PaymentSetoffListDto paymentSetoffListDto = PaymentSetoffListDto.fromJson(userJson);
        paymentSetoffList.add(paymentSetoffListDto);
      }
      return paymentSetoffList;
    }
    return [];
  }

  Future<List<LastDeliveryDto>?> fetchAllRecentDeliveries(
      {required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/deliveries", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<LastDeliveryDto> recentDeliveries = [];
      for (var userJson in jsonBody ?? []) {
        LastDeliveryDto lastDeliveryDto = LastDeliveryDto.fromJson(userJson);
        recentDeliveries.add(lastDeliveryDto);
      }
      return recentDeliveries;
    }
    return [];
  }

  Future<CustomerDetailsDto> fetchCustomerDetails({required String soldToCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/customer/soldto/$soldToCode"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = convert.jsonDecode(response.body);
      return CustomerDetailsDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      return throw Exception();
    }
    throw Exception();
  }

  Future<List<CustomerSearchDto>?> searchCustomerDetails({required String searchText}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/customer/search/$searchText"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = convert.jsonDecode(response.body);
      final customerList =
          (decodedJson["customerList"] as List).map((data) => CustomerSearchDto.fromJson(data)).toList();
      return customerList;
    }
    return [];
  }

  Future<List<DetailDto>?> getCustomerDetailsBySoldToCode({required String soldToCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/customer/details/soldto/$soldToCode"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = convert.jsonDecode(response.body);
      return (decodedJson["detailsList"] as List).map((data) => DetailDto.fromJson(data)).toList();
    }
    return [];
  }

  Future<DashboardSummaryResponseDto>? fetchDashboardSummary(
      {required String soldToCode, required String salesOrganizationCode, required String divisionCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/so-summary",
          {"soldToCode": soldToCode, "salesOrganizationCode": salesOrganizationCode, "divisionCode": divisionCode}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = jsonDecode(response.body);
      return DashboardSummaryResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      return throw Exception();
    } else if (response.statusCode == HttpStatus.internalServerError) {
      return DashboardSummaryResponseDto.empty();
    }
    throw Exception();
  }

  Future<List<ShipToListDto>?> getShipToListByCustomer({required String soldToCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/customer/shipping/soldto/$soldToCode"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<ShipToListDto> shipToCodeList = [];
      for (var userJson in jsonBody ?? []) {
        ShipToListDto shipToListDto = ShipToListDto.fromJson(userJson);
        shipToCodeList.add(shipToListDto);
      }
      return shipToCodeList;
    }
    return [];
  }

  Future<List<SoldToCodeSummaryDto>?> getSoldToCodeSummary(
      {required String soldToCode, required String divisionCode, required String salesOrgCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/customer/shipping/summary",
          {"soldToCode": soldToCode, "divisionCode": divisionCode, "salesOrgCode": salesOrgCode}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<SoldToCodeSummaryDto> soldToCodeSummary = [];
      for (var userJson in jsonBody ?? []) {
        SoldToCodeSummaryDto soldToCodeSummaryDto = SoldToCodeSummaryDto.fromJson(userJson);
        soldToCodeSummary.add(soldToCodeSummaryDto);
      }
      return soldToCodeSummary;
    }
    return [];
  }

  Future<List<PlantListDto>?> getAvailablePlants({
    required String salesOrgCode,
    required String distributionChannelCode,
    required String divisionCode,
    required String shipToCode,
    required String shippingCondition,
  }) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/plants", {
        "salesOrgCode": salesOrgCode,
        "distributionChannelCode": distributionChannelCode,
        "divisionCode": divisionCode,
        "shipToCode": shipToCode,
        "shippingCondition": shippingCondition
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<PlantListDto> plantList = [];
      for (var userJson in jsonBody ?? []) {
        PlantListDto plantListDto = PlantListDto.fromJson(userJson);
        plantList.add(plantListDto);
      }
      return plantList;
    }
    return [];
  }

  Future<List<ProductDto>?> getProductsByPlant(
      {required String plantCode,
      required String divisionCode,
      required String salesOrgCode,
      required String distributionChannelCode,
      required String shippingCondition,
      required String shipToCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/product/shipping/availability", {
        "plantCode": plantCode,
        "salesOrgCode": salesOrgCode,
        "distributionChannelCode": distributionChannelCode,
        "divisionCode": divisionCode,
        "shipToCode": shipToCode,
        "shippingCondition": shippingCondition
      }),
      headers: {'Content-Type': 'application/json', "Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<ProductDto> productList = [];
      for (var userJson in jsonBody ?? []) {
        ProductDto productDto = ProductDto.fromJson(userJson);
        productList.add(productDto);
      }
      return productList;
    }
    return [];
  }

  Future<List<AssignmentNoDto>?> getAssignmentNoList(
      {required String customerCode, required String companyCode, required String openatKeydays}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/assignment-numbers",
          {"CustomerCode": customerCode, "CompanyCode": companyCode, "OpenatKeydays": openatKeydays}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson['result'] as List).map((data) => AssignmentNoDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }
    return [];
  }

  Future<List<QueryCreditAvailabilityReportDto>?> getQueryCreditAvailabilityReport({
    required String customerCode,
    required String companyCode,
  }) async {
    final body = json.encode({
      "Query": {
        "CustomerCode": customerCode,
        "CompanyCode": companyCode,
      }
    });

    final token = await tokenProvider.getToken('');
    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/sap/v1.0.0/QueryCreditAvailabilityReport"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == HttpStatus.ok) {
      // Check for a successful response
      final decodedJson = json.decode(response.body);

      // Check if the response contains the expected data structure
      if (decodedJson.containsKey('RES_Records') && decodedJson['RES_Records'] is List) {
        return (decodedJson['RES_Records'] as List)
            .map((data) => QueryCreditAvailabilityReportDto.fromJson(data))
            .toList();
      } else {
        // Handle unexpected response format
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == HttpStatus.conflict) {
      throw Exception('Conflict');
    } else {
      // Handle other error cases
      return null;
    }
  }

  Future<ChequeDto>? getCheque({
    required String bankCountry,
    required String customerCode,
    required String bankNumber,
  }) async {
    final body = json.encode({
      "Bank_Country": bankCountry,
      "Customer_Code": customerCode,
      "Bank_Number": bankNumber,
    });

    final token = await tokenProvider.getToken('');
    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/sap/v1.0.0/Cheque"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return ChequeDto.fromJson(decodedJson["MT_Cheque_Responce_Inseepro"]);
    } else {
      throw Exception();
    }
  }

  Future<SimulateSalesOrderDto>? simulateSalesOrder({
    String? referenceID,
    String? refDocumentNo,
    String? salesOrderType,
    String? salesOrganization,
    String? distributionChannel,
    String? division,
    String? soldToParty,
    String? requestDeliveryDate,
    String? shippingCondition,
    String? shippingType,
    String? specialProcessingID,
    String? paymentTerm,
    String? shipToNumber,
    List<Map<String, dynamic>>? items,
  }) async {
    final token = await tokenProvider.getToken('');

    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/sap/v1.0.0/SimulateSalesOrder"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "HEADER": {"Sender": "INSEEPRO", "ReferenceID": referenceID},
        "INPUT": {
          "Header": {
            "RequestID": referenceID,
            "RefDocumentNo": refDocumentNo,
            "SalesOrderType": salesOrderType,
            "SalesOrganization": salesOrganization,
            "DistributionChannel": distributionChannel,
            "Division": division,
            "SoldToParty": soldToParty,
            "RequestDeliveryDate": requestDeliveryDate,
            "ShippingCondition": shippingCondition,
            "ShippingType": shippingType,
            "SpecialProcessingID": specialProcessingID,
            "PaymentTerm": paymentTerm
          },
          "PartnerFunction": {"ShipToNumber": shipToNumber},
          "Items": items,
        }
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      // Check for a successful response
      final decodedJson = json.decode(response.body);

      // Check if the response contains the expected data structure
      if (decodedJson != null && decodedJson is Map<String, dynamic>) {
        return SimulateSalesOrderDto.fromJson(decodedJson);
      } else {
        // Handle unexpected response format
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == HttpStatus.conflict) {
      throw Exception('Conflict');
    } else {
      // Handle other error cases
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<RequestReferenceCodeDto> createSalesOrder({
    String? salesOrderDate,
    String? email,
    String? firstName,
    int? userId,
    bool? internal,
    String? lastName,
    String? mobileNo,
    String? soldToCode,
    String? shipToCode,
    String? channelCode,
    String? divisionCode,
    String? orderType,
    String? plantCode,
    String? poDocumentUrl,
    String? poNumber,
    String? salesOrgCode,
    String? shippingCondition,
    double? ssclTax,
    double? tax,
    double? valueAfterTax,
    double? valueBeforeTax,
    double? vat,
    List<String>? salesOrderPaymentDetails,
    List<Map<String, dynamic>>? salesOrderItems,
  }) async {
    final token = await tokenProvider.getToken('');
    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "salesOrderDate": salesOrderDate,
        "customer": {"soldToCode": soldToCode},
        "division": {"divisionCode": divisionCode},
        "salesOrganization": {"salesOrgCode": salesOrgCode},
        "distributionChannel": {"channelCode": channelCode},
        "customerShippingLocation": {"shipToCode": shipToCode},
        "plant": {"plantCode": plantCode},
        "shippingCondition": shippingCondition,
        "orderType": orderType,
        "poDocumentUrl": poDocumentUrl,
        "poNumber": poNumber,
        "salesOrderPaymentDetails": salesOrderPaymentDetails,
        "salesOrderItems": salesOrderItems,
        "valueBeforeTax": valueBeforeTax,
        "tax": tax,
        "vat": vat,
        "ssclTax": ssclTax,
        "valueAfterTax": valueAfterTax,
        "createdBy": {
          "id": userId,
          "identityId": tokenProvider.identityId,
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "mobileNo": mobileNo,
          "internal": internal
        }
      }),
    );
    if (response.statusCode == HttpStatus.accepted) {
      return RequestReferenceCodeDto.fromJson(json.decode(response.body));
    } else {
      throw Exception();
    }
  }

  Future<SalesOrderStatusDto?>? getSalesOrderStatus(String requestReferenceCode) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/$requestReferenceCode"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return SalesOrderStatusDto.fromJson(decodedJson);
    } else {
      throw Exception();
    }
  }

  Future<String?>? fileUpload(String value) async {
    final token = await tokenProvider.getToken('');
    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/utility/files/upload"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: value,
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson["result"];
    } else {
      throw Exception();
    }
  }

  Future<String> getFullFilePath(String fileName) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/utility/files/$fileName"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson['result'];
    }

    throw Exception();
  }

  Future<OrderVolumeGraphDto>? orderVolumeGraph(
      {required String soldToCode, required String salesOrganizationCode, required String divisionCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/order-volume-summary",
          {"soldToCode": soldToCode, "salesOrganizationCode": salesOrganizationCode, "divisionCode": divisionCode}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes));
      return OrderVolumeGraphDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      return throw Exception();
    }
    throw Exception();
  }

  Future<ReportDataDto>? fetchReportData(
      {required String soldToCode, required String salesOrganizationCode, required String divisionCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/report-data",
          {"soldToCode": soldToCode, "salesOrganizationCode": salesOrganizationCode, "divisionCode": divisionCode}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes));
      return ReportDataDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.notFound) {
      return throw Exception();
    }
    throw Exception();
  }

  Future<SOReportDto>? soReportSearchData({
    String? startDate,
    String? endDate,
    String? shipToCode,
    String? orderType,
    String? soNumber,
    String? poNumber,
    String? plant,
    String? shippingCondition,
    String? material,
    String? materialGroup,
    String? soStatus,
  }) async {
    final token = await tokenProvider.getToken('');

    // Remove null or empty body items
    Map<String, dynamic> requestBody = {
      "startDate": startDate,
      "endDate": endDate,
      "shipToCode": shipToCode,
      "orderType": orderType,
      "soNumber": soNumber,
      "poNumber": poNumber,
      "plant": plant,
      "shippingCondition": shippingCondition,
      "material": material,
      "materialGroup": materialGroup,
      "soStatus": soStatus,
    };

    // Remove null or empty values from the request body
    requestBody.removeWhere((key, value) => value == null || value == '');

    final Uri uri = Uri.https(
      authority,
      "/${apimDomain}systemcore/v1.0.0/sales-order/report",
    );
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == HttpStatus.ok) {
      // Check for a successful response
      final decodedJson = json.decode(response.body);

      // Check if the response contains the expected data structure
      if (decodedJson != null && decodedJson is Map<String, dynamic>) {
        return SOReportDto.fromJson(decodedJson);
      } else {
        // Handle unexpected response format
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == HttpStatus.conflict) {
      throw Exception('Conflict');
    } else {
      // Handle other error cases
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<void>? setoffSalesOrder({
    List<Map<String, dynamic>>? customerInvoiceList,
    List<Map<String, dynamic>>? customerPaymentList,
  }) async {
    final token = await tokenProvider.getToken('');

    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/payment/setoff"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({"customerInvoiceList": customerInvoiceList, "customerPaymentList": customerPaymentList}),
    );

    if (response.statusCode == HttpStatus.ok) {
      return;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw Exception('Conflict');
    } else if (response.statusCode == HttpStatus.notAcceptable) {
      final decodedJson = json.decode(response.body);
      final errorMessage = decodedJson['result'] ?? 'Not Acceptable';
      throw NotAcceptedException(errorMessage);
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<void>? unblockRequestWithSlip({
    String? type,
    String? requestReferenceCode,
    String? remarks,
    List<Map<String, dynamic>>? uploadList,
  }) async {
    final token = await tokenProvider.getToken('');

    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/unblock-request"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "type": type,
        "salesOrder": {"requestReferenceCode": requestReferenceCode},
        "paymentSlipDetailList": uploadList,
        "remarks": remarks
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      return;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw Exception('Conflict');
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<void>? unblockRequestWithPlan({
    String? type,
    String? requestReferenceCode,
    String? remarks,
    List<Map<String, dynamic>>? planList,
  }) async {
    final token = await tokenProvider.getToken('');

    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/unblock-request"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "type": type,
        "remarks": remarks,
        "paymentPlanDetailList": planList,
        "salesOrder": {"requestReferenceCode": requestReferenceCode}
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      return;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw Exception('Conflict');
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<String> salesOrderReportExport(
      {String? startDate,
      String? endDate,
      String? shipToCode,
      String? orderType,
      String? soNumber,
      String? poNumber,
      String? plant,
      String? shippingCondition,
      String? material,
      String? materialGroup,
      String? soStatus,
      String? fileType}) async {
    final token = await tokenProvider.getToken('');

    // Remove null or empty body items
    Map<String, dynamic> requestBody = {
      "startDate": startDate,
      "endDate": endDate,
      "shipToCode": shipToCode,
      "orderType": orderType,
      "soNumber": soNumber,
      "poNumber": poNumber,
      "plant": plant,
      "shippingCondition": shippingCondition,
      "material": material,
      "materialGroup": materialGroup,
      "soStatus": soStatus,
    };

    // Remove null or empty values from the request body
    requestBody.removeWhere((key, value) => value == null || value == '');

    final response = await http.post(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/sales-order/report/export", {"type": fileType}),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson['result'];
    }

    throw Exception();
  }

  Future<String> invoiceReportExport({required String? invoiceNo}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/payment/invoice/export", {
        "invoiceNo": invoiceNo,
      }),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson['result'];
    }

    throw Exception();
  }

  Future<List<ActiveUserDto>?> fetchActiveUserList({required String customerCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/identity/user/customer", {"soldToCode": customerCode}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<ActiveUserDto> activeUserList = [];
      for (var userJson in jsonBody ?? []) {
        ActiveUserDto activeUserDto = ActiveUserDto.fromJson(userJson);
        activeUserList.add(activeUserDto);
      }
      return activeUserList;
    }
    return [];
  }

  Future<List<RecentPaymentsDto>?> fetchAllLatestInvoices(
      {required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/invoices", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<RecentPaymentsDto> recentInvoices = [];
      for (var userJson in jsonBody ?? []) {
        RecentPaymentsDto recentInvoicesDto = RecentPaymentsDto.fromJson(userJson);
        recentInvoices.add(recentInvoicesDto);
      }
      return recentInvoices;
    }
    return [];
  }

  Future<List<RecentBlockedSalesOrderDto>?> fetchAllRecentBlockedSalesOrders(
      {required String customerCode, required String companyCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/stats/blocked-recent", {
        "customerCode": customerCode,
        "companyCode": companyCode,
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<RecentBlockedSalesOrderDto> recentBlockedSalesOrders = [];
      for (var userJson in jsonBody ?? []) {
        RecentBlockedSalesOrderDto recentBlockedSalesOrderDto = RecentBlockedSalesOrderDto.fromJson(userJson);
        recentBlockedSalesOrders.add(recentBlockedSalesOrderDto);
      }
      return recentBlockedSalesOrders;
    }
    return [];
  }

  Future<List<BannerDto>?> fetchDashboardBanners({required String soldToCode}) async {
    final token = await tokenProvider.getToken('');
    final response = await http.get(
      Uri.https(authority, "/${apimDomain}systemcore/v1.0.0/customer/soldto/$soldToCode"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == HttpStatus.ok) {
      final jsonBody = convert.jsonDecode(response.body);
      List<BannerDto> bannerList = [];

      if (jsonBody.containsKey("bannerList")) {
        for (var bannerJson in jsonBody["bannerList"] ?? []) {
          BannerDto bannerDto = BannerDto.fromJson(bannerJson);
          bannerList.add(bannerDto);
        }
        return bannerList;
      }
    }
    return [];
  }

  Future<bool> termsAndConditions(int userId, bool value) async {
    final token = await tokenProvider.getToken('');
    final response = await http.put(
      Uri.https(
        authority,
        "/${apimDomain}systemcore/v1.0.0/identity/user/terms/$userId",
        {"termsAndConditions": value.toString()},
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return response.statusCode == HttpStatus.accepted;
  }
}
