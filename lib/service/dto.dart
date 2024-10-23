class UserResponseDto {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  bool? internal;
  bool? status;
  String? expiryDate;
  String? defaultLanguage;
  String? lastModifiedDate;
  String? sapEmployeeCode;
  String? lastLoginTimeStamp;
  bool? soConsentGiven;
  bool? changePasswordNextLogin;
  List<RoleDto>? roles;
  List<CustomerDto>? customers;
  List<ShipToListDto>? shipToList;
  dynamic profilePicture;
  bool? termsAccepted;

  UserResponseDto.fromJson(Map<String, dynamic>? value)
      : id = value?["id"],
        identityId = value?["identityId"],
        firstName = value?["firstName"],
        lastName = value?["lastName"],
        email = value?["email"],
        mobileNo = value?["mobileNo"],
        internal = value?["internal"],
        status = value?["status"],
        expiryDate = value?["expiryDate"],
        defaultLanguage = value?["defaultLanguage"],
        lastModifiedDate = value?["lastModifiedDate"],
        sapEmployeeCode = value?["sapEmployeeCode"],
        lastLoginTimeStamp = value?["lastLoginTimeStamp"],
        soConsentGiven = value?["soConsentGiven"],
        changePasswordNextLogin = value?["changePasswordNextLogin"],
        roles = (value?["roles"] as List<dynamic>?)?.map((roleData) => RoleDto.fromJson(roleData)).toList(),
        customers =
            (value?["customers"] as List<dynamic>?)?.map((customerData) => CustomerDto.fromJson(customerData)).toList(),
        shipToList = (value?["shipToList"] as List<dynamic>?)
            ?.map((shipToListData) => ShipToListDto.fromJson(shipToListData))
            .toList(),
        profilePicture = value?["profilePicture"],
        termsAccepted = value?["termsAccepted"];
}

class RoleDto {
  String? roleIdentityId;
  String? roleName;
  String? roleType;

  RoleDto.fromJson(Map<String, dynamic> value)
      : roleIdentityId = value["roleIdentityId"],
        roleName = value["roleName"],
        roleType = value["roleType"];
}

class CustomerDto {
  String? name;
  String? soldToCode;
  String? address1;
  String? address2;
  String? district;
  String? postalCode;
  String? province;
  String? email1;
  String? email2;
  bool? deleted;
  dynamic blocked;

  CustomerDto.fromJson(Map<String, dynamic> value)
      : name = value["name"],
        soldToCode = value["soldToCode"],
        address1 = value["address1"],
        address2 = value["address2"],
        district = value["district"],
        postalCode = value["postalCode"],
        province = value["province"],
        email1 = value["email1"],
        email2 = value["email2"],
        deleted = value["deleted"] {
    if (value["blocked"] is bool) {
      blocked = value["blocked"];
    } else {
      blocked = value["blocked"].toString();
    }
  }
}

class ShipToListDto {
  String? shipToCode;
  String? shipToName;

  ShipToListDto.fromJson(Map<String, dynamic> value)
      : shipToCode = value["shipToCode"],
        shipToName = value["shipToName"];
}

class SalesOrderCreateDto {
  String? requestReferenceCode;
  String? salesOrderNo;
  String? salesOrderDate;
  String? shippingCondition;
  String? status;
  String? orderType;
  String? blockStatus;
  String? internalStatus;
  bool? deliveryBlocked;
  String? rejectStatus;
  String? deliveryStatus;
  String? poNumber;
  String? poDocumentUrl;
  String? paymentTerm;
  double? valueBeforeTax;
  double? tax;
  double? vat;
  double? ssclTax;
  double? valueAfterTax;
  String? workflowStatus;
  String? cancelReason;
  CustomerShippingLocationDto? customerShippingLocation;
  List<SalesOrderItemsDto>? salesOrderItems;
  PlantListDto? plant;

  SalesOrderCreateDto.fromJson(Map<String, dynamic> value)
      : requestReferenceCode = value["requestReferenceCode"],
        salesOrderNo = value["salesOrderNo"],
        salesOrderDate = value["salesOrderDate"],
        shippingCondition = value["shippingCondition"],
        status = value["status"],
        orderType = value["orderType"],
        blockStatus = value["blockStatus"],
        internalStatus = value["internalStatus"],
        deliveryBlocked = value["deliveryBlocked"],
        rejectStatus = value["rejectStatus"],
        deliveryStatus = value["deliveryStatus"],
        poNumber = value["poNumber"],
        poDocumentUrl = value["poDocumentUrl"],
        paymentTerm = value["paymentTerm"],
        valueBeforeTax = value["valueBeforeTax"],
        tax = value["tax"],
        vat = value["vat"],
        ssclTax = value["ssclTax"],
        valueAfterTax = value["valueAfterTax"],
        workflowStatus = value["workflowStatus"],
        cancelReason = value["cancelReason"],
        customerShippingLocation = CustomerShippingLocationDto.fromJson(value["customerShippingLocation"]),
        salesOrderItems = ((value["salesOrderItems"] ?? []) as List<dynamic>)
            .map((salesOrderItemData) => SalesOrderItemsDto.fromJson(salesOrderItemData))
            .toList(),
        plant = PlantListDto.fromJson(value["plant"]);
}

class SalesOrderItemsDto {
  dynamic quantity;
  double? tax;
  double? totalZSSCAmount;
  double? unitPrice;
  double? valueAfterTax;
  double? valueBeforeTax;
  ProductDto? product;

  SalesOrderItemsDto.fromJson(Map<String, dynamic> value)
      : quantity = value["quantity"],
        tax = value["tax"],
        totalZSSCAmount = value["totalZSSCAmount"],
        unitPrice = value["unitPrice"],
        valueAfterTax = value["valueAfterTax"],
        valueBeforeTax = value["valueBeforeTax"],
        product = ProductDto.fromJson(value["product"]);
}

class RecentSalesOrderDto {
  String? orderDate;
  String? soNumber;
  double? amount;
  String? status;
  String? internalStatus;

  RecentSalesOrderDto.fromJson(Map<String, dynamic> value)
      : orderDate = value["orderDate"],
        soNumber = value["soNumber"],
        amount = value["amount"],
        status = value["status"],
        internalStatus = value["internalStatus"];
}

class RecentBlockedSalesOrderDto {
  String? orderDate;
  String? soNumber;
  double? amount;
  String? status;

  RecentBlockedSalesOrderDto.fromJson(Map<String, dynamic> value)
      : orderDate = value["orderDate"],
        soNumber = value["soNumber"],
        amount = value["amount"],
        status = value["status"];
}

class LastDeliveryDto {
  String? date;
  String? doNumber;
  String? truckNumber;
  String? status;

  LastDeliveryDto.fromJson(Map<String, dynamic> value)
      : date = value["date"],
        doNumber = value["doNumber"],
        truckNumber = value["truckNumber"],
        status = value["status"];
}

class RecentPaymentsDto {
  String? date;
  String? soNumber;
  double? amount;
  String? referenceNumber;

  RecentPaymentsDto.fromJson(Map<String, dynamic> value)
      : date = value["date"],
        soNumber = value["soNumber"],
        amount = value["amount"],
        referenceNumber = value["referenceNumber"];
}

class PaymentsDto {
  String? date;
  String? soNumber;
  double? amount;
  String? referenceNumber;

  PaymentsDto.fromJson(Map<String, dynamic> value)
      : date = value["date"],
        soNumber = value["soNumber"],
        amount = value["amount"],
        referenceNumber = value["referenceNumber"];
}

class CustomerDetailsDto {
  int? id;
  String? name;
  String? soldToCode;
  String? address1;
  String? address2;
  String? district;
  String? postalCode;
  String? province;
  String? email1;
  String? email2;
  bool? deleted;
  String? blocked;
  bool? soConsent;
  List<BankInfoDto>? customerBankInfos;
  List<dynamic>? details;
  List<dynamic>? customerShippingLocations;
  String? type;
  List<PoDto>? poRecordList;

  CustomerDetailsDto.fromJson(Map<String, dynamic> value) {
    id = value["customer"]["id"];
    name = value["customer"]["name"];
    soldToCode = value["customer"]["soldToCode"];
    address1 = value["customer"]["address1"];
    address2 = value["customer"]["address2"];
    district = value["customer"]["district"];
    postalCode = value["customer"]["postalCode"];
    province = value["customer"]["province"];
    email1 = value["customer"]["email1"];
    email2 = value["customer"]["email2"];
    deleted = value["customer"]["deleted"];
    blocked = value["customer"]["blocked"];
    soConsent = value["customer"]["soConsent"];
    type = value["customer"]["type"];
    // Check if "customerBankInfos" key exists before accessing it
    if (value["customer"] != null && value["customer"]["customerBankInfos"] != null) {
      customerBankInfos = ((value["customer"]["customerBankInfos"] as List<dynamic>) ?? [])
          .map((bankData) => BankInfoDto.fromJson(bankData))
          .toList();
    } else {
      customerBankInfos = [];
    }

    details = ((value["details"] ?? []) as List<dynamic>).map((detailsData) => RoleDto.fromJson(detailsData)).toList();

    // Check if "customerShippingLocations" key exists before accessing it
    if (value["customerShippingLocations"] != null) {
      customerShippingLocations = ((value["customerShippingLocations"] as List<dynamic>) ?? [])
          .map((customerShippingLocationsData) => RoleDto.fromJson(customerShippingLocationsData))
          .toList();
    } else {
      customerShippingLocations = [];
    }

    // Check if "poRecordList" key exists before accessing it
    if (value["poRecordList"] != null) {
      poRecordList = ((value["poRecordList"] as List<dynamic>) ?? []).map((poData) => PoDto.fromJson(poData)).toList();
    } else {
      poRecordList = [];
    }
  }
}

class PoDto {
  int? id;
  String? poNumber;
  List<PoNumberDetailsDto>? poNumberDetailList;
  SalesOrderDto? salesOrder;

  PoDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        poNumber = value["poNumber"],
        poNumberDetailList = ((value["poNumberDetailList"] as List<dynamic>) ?? []).map((poData) => PoNumberDetailsDto.fromJson(poData)).toList(),
        salesOrder = SalesOrderDto.fromJson(value["salesOrder"]);
}

class PoNumberDetailsDto {
  int? id;
  dynamic poQuantity;
  dynamic remainingQuantity;
  ProductDto? product;

  PoNumberDetailsDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        poQuantity = value["poQuantity"],
        product = ProductDto.fromJson(value["product"]){
        final poQuantityValue = value["poQuantity"];
          if (poQuantityValue is int) {
            poQuantity = poQuantityValue.toInt();
          } else if (poQuantityValue is double) {
            poQuantity = poQuantityValue.toDouble();
          }
        final remainingQuantityValue = value["remainingQuantity"];
        if (remainingQuantityValue is int) {
          remainingQuantity = remainingQuantityValue.toInt();
        } else if (remainingQuantityValue is double) {
          remainingQuantity = remainingQuantityValue.toDouble();
        }
      }
}

class BankInfoDto {
  String? lastModifiedDate;
  String? createdDate;
  String? bankKey;
  String? bankName;
  String? bankBranch;

  BankInfoDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        bankKey = value["bankKey"],
        bankName = value["bankName"],
        bankBranch = value["bankBranch"];
}

class CustomerSearchDto {
  int? id;
  String? name;
  String? soldToCode;
  String? address1;
  String? address2;
  String? district;
  String? postalCode;
  String? province;
  String? email1;
  String? email2;
  bool? deleted;
  bool? blocked;
  bool? soConsent;
  String? type;

  CustomerSearchDto.fromJson(Map<String, dynamic> value) {
    id = value["id"];
    name = value["name"];
    soldToCode = value["soldToCode"];
    address1 = value["address1"];
    address2 = value["address2"];
    district = value["district"];
    postalCode = value["postalCode"];
    province = value["province"];
    email1 = value["email1"];
    email2 = value["email2"];
    deleted = value["deleted"];
    blocked = value["blocked"];
    soConsent = value["soConsent"];
    type = value["type"];
  }
}

class DetailDto {
  String? lastModifiedDate;
  String? createdDate;
  String? lastModifiedDateSalesOrg;
  String? createdDateSalesOrg;
  String? salesOrgCode;
  String? salesOrgName;
  String? lastModifiedDateDivision;
  String? createdDateDivision;
  String? divisionCode;
  String? divisionName;
  String? lastModifiedDateChannel;
  String? createdDateChannel;
  String? channelCode;
  String? channelName;
  dynamic salesEmployee;
  bool? deleted;
  String? blockCode;
  String? customerType;

  DetailDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        lastModifiedDateSalesOrg = value['salesOrganization']['lastModifiedDate'],
        createdDateSalesOrg = value['salesOrganization']['createdDate'],
        salesOrgCode = value['salesOrganization']['salesOrgCode'],
        salesOrgName = value['salesOrganization']['salesOrgName'],
        lastModifiedDateDivision = value['division']['lastModifiedDate'],
        createdDateDivision = value['division']['createdDate'],
        divisionCode = value['division']['divisionCode'],
        divisionName = value['division']['divisionName'],
        lastModifiedDateChannel = value['channel']['lastModifiedDate'],
        createdDateChannel = value['channel']['createdDate'],
        channelCode = value['channel']['channelCode'],
        channelName = value['channel']['channelName'],
        salesEmployee = value["salesEmployee"],
        deleted = value["deleted"],
        blockCode = value["blockCode"],
        customerType = value["customerType"];
}

class SalesOrderDto {
  String? lastModifiedDate;
  String? createdDate;
  int? id;
  String? requestReferenceCode;
  String? salesOrderNo;
  String? salesOrderDate;
  CustomerDto? customer;
  DivisionDto? division;
  SalesOrganizationDto? salesOrganization;
  DistributionChannelDto? distributionChannel;
  CustomerShippingLocationDto? customerShippingLocation;
  PlantListDto? plant;
  String? shippingCondition;
  String? status;
  String? orderType;
  String? blockStatus;
  String? internalStatus;
  bool? deliveryBlocked;
  String? rejectStatus;
  String? deliveryStatus;
  String? poNumber;
  String? poDocumentUrl;
  String? poDocument;
  dynamic paymentTerm;
  double? valueBeforeTax;
  double? tax;
  double? vat;
  double? ssclTax;
  double? valueAfterTax;
  dynamic workflowStatus;
  dynamic cancelReason;
  dynamic commentNote;
  dynamic salesOrderItems;
  List<SalesOrderCalloutStatusDto>? salesOrderCalloutStatuses;
  List<dynamic>? salesOrderPaymentDetails;
  dynamic doCount;

  SalesOrderDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        id = value["id"],
        requestReferenceCode = value["requestReferenceCode"],
        salesOrderNo = value["salesOrderNo"],
        salesOrderDate = (value["createdDate"]),
        customer = CustomerDto.fromJson(value["customer"]),
        division = DivisionDto.fromJson(value["division"]),
        salesOrganization = SalesOrganizationDto.fromJson(value["salesOrganization"]),
        distributionChannel = DistributionChannelDto.fromJson(value["distributionChannel"]),
        customerShippingLocation = CustomerShippingLocationDto.fromJson(value["customerShippingLocation"]),
        plant = PlantListDto.fromJson(value["plant"]),
        shippingCondition = value["shippingCondition"],
        status = value["status"],
        orderType = value["orderType"],
        blockStatus = value["blockStatus"],
        internalStatus = value["internalStatus"],
        deliveryBlocked = value["deliveryBlocked"],
        rejectStatus = value["rejectStatus"],
        deliveryStatus = value["deliveryStatus"],
        poNumber = value["poNumber"],
        poDocumentUrl = value["poDocumentUrl"],
        poDocument = _extractFileName(value["poDocumentUrl"]),
        paymentTerm = value["paymentTerm"],
        valueBeforeTax = value["valueBeforeTax"]?.toDouble(),
        tax = value["tax"]?.toDouble(),
        vat = value["vat"]?.toDouble(),
        ssclTax = value["ssclTax"]?.toDouble(),
        valueAfterTax = value["valueAfterTax"]?.toDouble(),
        workflowStatus = value["workflowStatus"],
        cancelReason = value["cancelReason"],
        commentNote = value["commentNote"],
        salesOrderItems = value["salesOrderItems"],
        salesOrderCalloutStatuses = ((value["salesOrderCalloutStatuses"] ?? []) as List<dynamic>)
            .map((calloutStatusData) => SalesOrderCalloutStatusDto.fromJson(calloutStatusData))
            .toList(),
        salesOrderPaymentDetails = value["salesOrderPaymentDetails"],
        doCount = value["doCount"];
          static String? _extractFileName(String? url) {
            if (url == null) return null;
             Uri uri = Uri.parse(url);
              String path = uri.path;
          return path.split('/').last;
      }
}

class CreatedByDto {
  String? lastModifiedDate;
  String? createdDate;
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  dynamic password;
  bool? internal;
  List<dynamic>? roles;
  bool? status;
  dynamic expiryDate;
  List<int>? lastLoginTimeStamp;
  dynamic defaultLanguage;
  String? sapEmployeeCode;
  bool? soConsent;
  bool? changePasswordNextLogin;
  List<dynamic>? customers;
  List<dynamic>? shippingLocations;

  CreatedByDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        password = value["password"],
        internal = value["internal"],
        roles = value["roles"],
        status = value["status"],
        expiryDate = value["expiryDate"],
        lastLoginTimeStamp = (value["lastLoginTimeStamp"] as List<dynamic>).cast<int>(),
        defaultLanguage = value["defaultLanguage"],
        sapEmployeeCode = value["sapEmployeeCode"],
        soConsent = value["soConsent"],
        changePasswordNextLogin = value["changePasswordNextLogin"],
        customers = value["customers"],
        shippingLocations = value["shippingLocations"];
}

class SalesOrderCalloutStatusDto {
  String? statusCode;
  String? statusMessage;

  SalesOrderCalloutStatusDto.fromJson(Map<String, dynamic> value)
      : statusCode = value["statusCode"],
        statusMessage = value["statusMessage"];
}

class CustomerShippingLocationDto {
  String? lastModifiedDate;
  String? createdDate;
  String? shipToCode;
  String? shipToName;
  String? shipToAddress1;
  String? shipToAddress2;
  String? district;
  String? postalCode;
  String? province;
  dynamic details;

  CustomerShippingLocationDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        shipToCode = value["shipToCode"],
        shipToName = value["shipToName"],
        shipToAddress1 = value["shipToAddress1"],
        shipToAddress2 = value["shipToAddress2"],
        district = value["district"],
        postalCode = value["postalCode"],
        province = value["province"],
        details = value["details"];
}

class DashboardSummaryResponseDto {
  String? orderVolumeLabel;
  String? orderVolumeValue;
  String? dailyInvoicedVolumeLabel;
  String? dailyInvoicedVolumeValue;
  String? overDueAmountLabel;
  String? overDueAmountValue;
  String? totalOutstandingLabel;
  String? totalOutstandingValue;
  String? creditLimitLabel;
  String? creditLimitValue;
  List<CreditLimitValueDto> credit;

  DashboardSummaryResponseDto.fromJson(Map<String, dynamic> value)
      : orderVolumeLabel = value['todaysOrderVolume']['label'],
        orderVolumeValue = value['todaysOrderVolume']['value'],
        dailyInvoicedVolumeLabel = value['dailyInvoicedVolume']?['label'],
        dailyInvoicedVolumeValue = value['dailyInvoicedVolume']?['value'],
        overDueAmountLabel = value['overdueAmount']['label'],
        overDueAmountValue = value['overdueAmount']['value'],
        totalOutstandingLabel = value['totalOutstanding']['label'],
        totalOutstandingValue = value['totalOutstanding']['value'],
        credit = (value['creditLimit']['values'] as List)
            .map((creditData) => CreditLimitValueDto.fromJson(creditData))
            .toList();

  // Named constructor for creating an empty instance
  DashboardSummaryResponseDto.empty()
      : orderVolumeLabel = null,
        orderVolumeValue = null,
        dailyInvoicedVolumeLabel = null,
        dailyInvoicedVolumeValue = null,
        overDueAmountLabel = null,
        overDueAmountValue = null,
        totalOutstandingLabel = null,
        totalOutstandingValue = null,
        creditLimitLabel = null,
        creditLimitValue = null,
        credit = [];
}

class CreditLimitValueDto {
  String? creditLimitValue;
  bool? creditLimitLimitExceeded;

  CreditLimitValueDto.fromJson(Map<String, dynamic> value)
      : creditLimitValue = value['all'],
        creditLimitLimitExceeded = value['limitExceeded'];
}

class SoldToCodeSummaryDto {
  String? refId;
  String? channelCode;
  String? shipToCode;
  String? shipToName;
  String? customerType;
  List<String>? shippingConditions;
  List<String>? orderTypes;
  String? paymentTerm;

  SoldToCodeSummaryDto.fromJson(Map<String, dynamic> value)
      : refId = value["refId"],
        channelCode = value["channelCode"],
        shipToCode = value["shipToCode"],
        shipToName = value["shipToName"],
        customerType = value["customerType"],
        shippingConditions = (value["shippingConditions"] as List<dynamic>?)?.cast<String>(),
        orderTypes = (value["orderTypes"] as List<dynamic>?)?.cast<String>(),
        paymentTerm = value["paymentTerm"];
}

class PlantListDto {
  String? lastModifiedDate;
  String? createdDate;
  String? plantCode;
  String? plantName;
  String? weekdayPeakHourFrom;
  String? weekdayPeakHourTo;
  String? weekdaySurcharge;
  String? weekdayRebate;
  String? weekendPeakHourFrom;
  String? weekendPeakHourTo;
  String? weekendSurcharge;
  String? weekendRebate;
  bool display;

  PlantListDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        plantCode = value["plantCode"],
        plantName = value["plantName"],
        weekdayPeakHourFrom = value["weekdayPeakHourFrom"],
        weekdayPeakHourTo = value["weekdayPeakHourTo"],
        weekdaySurcharge = value["weekdaySurcharge"],
        weekdayRebate = value["weekdayRebate"],
        weekendPeakHourFrom = value["weekendPeakHourFrom"],
        weekendPeakHourTo = value["weekendPeakHourTo"],
        weekendSurcharge = value["weekendSurcharge"],
        weekendRebate = value["weekendRebate"],
        display = value["display"];
}

class ProductDto {
  String? lastModifiedDate;
  String? createdDate;
  String? productCode;
  String? productName;
  String? productMaskName;
  String? productDescription;
  String? uom;
  List<ProductImageDto?>? productImage;
  List<ProductDocumentDto?>? productDocument;
  bool deleted;
  double? price;
  String? productGroup;
  String? valueBeforeTax;

  ProductDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"] ?? "",
        createdDate = value["createdDate"] ?? "",
        productCode = value["productCode"] ?? "",
        productName = value["productName"] ?? "",
        productMaskName = value["productMaskName"],
        productDescription = value["productDescription"] ?? "",
        uom = value["uom"] ?? "",
        productImage = ((value["productImages"] ?? []) as List<dynamic>?)
            ?.map((productImageData) => ProductImageDto.fromJson(productImageData))
            .toList(),
        productDocument = (value["productDocuments"] as List<dynamic>?)
            ?.map((productDocumentData) => ProductDocumentDto.fromJson(productDocumentData))
            .toList(),
        deleted = value["deleted"] ?? false,
        price = value["price"]?.toDouble(),
        productGroup = value["productGroup"] ?? "",
        valueBeforeTax = value["valueBeforeTax"] ?? "";
}

class ProductImageDto {
  String? lastModifiedDate;
  String? createdDate;
  String? imageType;
  String? imageUrl;
  String? imageDisplayUrl;

  ProductImageDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"] ?? "",
        createdDate = value["createdDate"] ?? "",
        imageType = value["imageType"] ?? "",
        imageUrl = value["imageUrl"] ?? "",
        imageDisplayUrl = value["imageDisplayUrl"] ?? "";
}

class ProductDocumentDto {
  String? documentType;
  String? documentUrl;
  String? documentDisplayUrl;

  ProductDocumentDto.fromJson(Map<String, dynamic> value)
      : documentType = value["documentType"] ?? "",
        documentUrl = value["documentUrl"] ?? "",
        documentDisplayUrl = value["documentDisplayUrl"] ?? "";
}

class AssignmentNoDto {
  int? companyCode;
  String? customerCode;
  int? documentNoFI;
  dynamic billingDoc;
  String? postingDate;
  String? documentDate;
  String? netDueDate;
  String? lineItem;
  String? amountDocCurrency;
  String? docCurrency;
  String? documentType;
  String? customerPONumber;
  String? reference;
  String? overdueDays;
  String? overdueAmount;
  String? description;
  String? assignment;

  AssignmentNoDto.fromJson(Map<String, dynamic> value)
      : companyCode = value["CompanyCode"],
        customerCode = value["CustomerCode"],
        documentNoFI = value['DocumentNo_FI'],
        postingDate = value['PostingDate'],
        documentDate = value['DocumentDate'],
        netDueDate = value['NetDueDate'],
        lineItem = value['LineItem'],
        amountDocCurrency = value['AmountDocCurrency'],
        docCurrency = value['DocCurrency'],
        documentType = value['DocumentType'],
        customerPONumber = value['CustomerPONumber'],
        reference = value['Reference'],
        overdueDays = value['OverdueDays'],
        overdueAmount = value['OverdueAmount'],
        description = value['Description'],
        assignment = value['Assignment'] {
    final billingDocValue = value["BillingDoc"];
    if (billingDocValue is int) {
      billingDoc = billingDocValue.toInt();
    } else if (billingDocValue is String) {
      billingDoc = int.tryParse(billingDocValue) ?? 0;
    }
  }
}

class QueryCreditAvailabilityReportDto {
  String? customerCode;
  int? companyCode;
  int? creditControlArea;
  String? creditLimit;
  String? creditLimitUsed;
  dynamic creditLimitUsedAmount;
  dynamic outstandSalesOrders;
  String? outstandARBalance;
  dynamic CreditLimitAvailable;
  String? currency;
  String? errorMessage;

  QueryCreditAvailabilityReportDto.fromJson(Map<String, dynamic> value)
      : customerCode = value["CustomerCode"],
        companyCode = value["CompanyCode"],
        creditControlArea = value["CreditControlArea"],
        creditLimit = value["CreditLimit"],
        creditLimitUsed = value["CreditLimitUsed"],
        currency = value["Currency"],
        errorMessage = value["ErrorMessage"] {
    final creditLimitAvailable = value["CreditLimitAvailable"];
    double parsedCreditLimitAvailable = 0.0;

    if (creditLimitAvailable is double) {
      parsedCreditLimitAvailable = creditLimitAvailable;
    } else if (creditLimitAvailable is String) {
      // Remove trailing "-" if present
      String cleanedValue = creditLimitAvailable.replaceAll("-", "");

      // Attempt to parse the string as a double
      parsedCreditLimitAvailable = double.tryParse(cleanedValue) ?? 0.0;
    }

// Now you can use parsedCreditLimitAvailable wherever needed
    CreditLimitAvailable = parsedCreditLimitAvailable;
    // Parse CreditLimitUsedAmount based on its type
    final creditLimitUsedAmountValue = value["CreditLimitUsedAmount"];
    if (creditLimitUsedAmountValue is double) {
      creditLimitUsedAmount = creditLimitUsedAmountValue;
    } else if (creditLimitUsedAmountValue is String) {
      creditLimitUsedAmount = double.tryParse(creditLimitUsedAmountValue) ?? 0.0;
    }

    // Parse OutstandSalesOrders based on its type
    final outstandSalesOrdersValue = value["OutstandSalesOrders"];
    if (outstandSalesOrdersValue is double) {
      outstandSalesOrders = outstandSalesOrdersValue;
    } else if (outstandSalesOrdersValue is String) {
      outstandSalesOrders = double.tryParse(outstandSalesOrdersValue) ?? 0.0;
    }
  }
}

class ChequeDto {
  String? bankCountry;
  String? customerCode;
  String? bankNumber;
  String? chequeSeries;
  dynamic lastChequeNumber;

  ChequeDto.fromJson(Map<String, dynamic> value)
      : bankCountry = value["Bank_Country"],
        customerCode = value["Customer_Code"],
        bankNumber = value["Bank_Number"],
        chequeSeries = value["Cheque_Series"] {
    final billingDocValue = value["Last_Cheque_Number"];
    if (billingDocValue is int) {
      lastChequeNumber = billingDocValue.toInt();
    } else if (billingDocValue is String) {
      lastChequeNumber = int.tryParse(billingDocValue) ?? 0;
    }
  }
}

class SalesOrderResponseDto {
  String? lastModifiedDate;
  String? createdDate;
  int? id;
  String? requestReferenceCode;
  String? salesOrderNo;
  List<int?> salesOrderDate;
  CustomerDetailsDto? customer;
  DivisionDto? division;
  SalesOrganizationDto? salesOrganization;
  DistributionChannelDto? distributionChannel;
  CustomerShippingLocationsDto? customerShippingLocation;
  PlantListDto? plant;
  String? shippingCondition;
  String? status;
  String? orderType;
  String? blockStatus;
  String? internalStatus;
  String? deliveryBlocked;
  String? rejectStatus;
  String? deliveryStatus;
  String? poNumber;
  String? poDocumentUrl;
  String? paymentTerm;
  String? valueBeforeTax;
  String? tax;
  String? vat;
  String? ssclTax;
  String? valueAfterTax;
  String? workflowStatus;
  String? cancelReason;

  SalesOrderResponseDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        id = value["id"],
        requestReferenceCode = value["requestReferenceCode"],
        salesOrderNo = value["salesOrderNo"],
        salesOrderDate = value["salesOrderDate"],
        customer = value["customer"],
        division = value["division"],
        salesOrganization = value["salesOrganization"],
        customerShippingLocation = value["customerShippingLocation"],
        plant = value["plant"],
        shippingCondition = value["shippingCondition"],
        status = value["status"],
        orderType = value["orderType"],
        blockStatus = value["blockStatus"],
        internalStatus = value["internalStatus"],
        deliveryBlocked = value["deliveryBlocked"],
        rejectStatus = value["rejectStatus"],
        deliveryStatus = value["deliveryStatus"],
        poNumber = value["poNumber"],
        poDocumentUrl = value["poDocumentUrl"],
        paymentTerm = value["paymentTerm"],
        valueBeforeTax = value["valueBeforeTax"],
        tax = value["tax"],
        vat = value["vat"],
        ssclTax = value["ssclTax"],
        valueAfterTax = value["valueAfterTax"],
        workflowStatus = value["workflowStatus"],
        cancelReason = value["cancelReason"];
}

class DivisionDto {
  String? lastModifiedDate;
  String? createdDate;
  String? divisionCode;
  String? divisionName;

  DivisionDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        divisionCode = value["divisionCode"],
        divisionName = value["divisionName"];
}

class SalesOrganizationDto {
  String? lastModifiedDate;
  String? createdDate;
  String? salesOrgCode;
  String? salesOrgName;

  SalesOrganizationDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        salesOrgCode = value["salesOrgCode"],
        salesOrgName = value["salesOrgName"];
}

class DistributionChannelDto {
  String? lastModifiedDate;
  String? createdDate;
  String? channelCode;
  String? channelName;

  DistributionChannelDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        channelCode = value["channelCode"],
        channelName = value["channelName"];
}

class CustomerShippingLocationsDto {
  String? lastModifiedDate;
  String? createdDate;
  String? shipToCode;
  String? shipToName;
  String? shipToAddress1;
  String? shipToAddress2;
  String? district;
  String? postalCode;
  String? province;
  String? details;

  CustomerShippingLocationsDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        shipToCode = value["shipToCode"],
        shipToName = value["shipToName"],
        shipToAddress1 = value["shipToAddress1"],
        shipToAddress2 = value["shipToAddress2"],
        district = value["district"],
        postalCode = value["postalCode"],
        province = value["province"],
        details = value["details"];
}

class SimulateSalesOrderDto {
  PricingDto? pricing;
  List<PricingItemDto>? pricingItem;

  SimulateSalesOrderDto.fromJson(Map<String, dynamic> value)
      : pricing = value["Pricing"] != null ? PricingDto.fromJson(value["Pricing"]) : null,
        pricingItem = (value["PricingItem"] as List<dynamic>? ?? [])
            .where((item) => item != "") // Filter out empty strings
            .whereType<Map<String, dynamic>>() // Filter out non-Map items
            .map((pricingItemData) => PricingItemDto.fromJson(pricingItemData))
            .toList();
}

class PricingDto {
  dynamic NetPrice;
  dynamic Tax;
  dynamic Net_Price;
  dynamic Tax_LK;
  dynamic Net_Price_LK;

  PricingDto.fromJson(Map<String, dynamic> value) {
    final netPrice = value["NetPrice"];
    if (netPrice is double) {
      NetPrice = netPrice;
    }
    if (netPrice is String) {
      NetPrice = double.tryParse(netPrice) ?? 0.0;
    }
    if (netPrice is int) {
      NetPrice = netPrice.toInt();
    }
    final tax = value["Tax"];
    if (tax is double) {
      Tax = tax;
    }
    if (tax is int) {
      Tax = tax.toInt();
    }
    if (tax is String) {
      Tax = double.tryParse(tax) ?? 0.0;
    }
    final net_Price = value["Net_Price"];
    if (net_Price is double) {
      Net_Price = net_Price;
    }
    if (net_Price is int) {
      Net_Price = net_Price.toInt();
    }
    if (net_Price is String) {
      Net_Price = double.tryParse(net_Price) ?? 0.0;
    }
    final tax_LK = value["Tax_LK"];
    if (tax_LK is double) {
      Tax_LK = tax_LK;
    }
    if (tax_LK is int) {
      Tax_LK = tax_LK.toInt();
    }
    if (tax_LK is String) {
      Tax_LK = double.tryParse(tax_LK) ?? 0.0;
    }
    final net_Price_LK = value["Net_Price_LK"];
    if (net_Price_LK is double) {
      Net_Price_LK = net_Price_LK;
    }
    if (net_Price_LK is int) {
      Net_Price_LK = net_Price_LK.toInt();
    }
    if (net_Price_LK is String) {
      Net_Price_LK = double.tryParse(net_Price_LK) ?? 0.0;
    }
  }
}

class PricingItemDto {
  String? salesDocumentItem;
  String? materialNumber;
  dynamic amount;
  String? priceListCondition;
  int? discountAmount;
  int? cashDiscountAmount;
  int? cashDiscountCondition;
  String? reightChargeAmount;
  String? freightChargeCondition;
  int? extraChargeAmount;
  int? extraChargeCondition;
  dynamic zsscCondition;
  double? zsscAmount;
  int? vatAmount;
  dynamic vatCondition;
  dynamic totalAmount;
  String? totalCondition;
  String? currency;
  String? itemCategory;
  String? quantity;
  dynamic NetAfterVatRate;

  PricingItemDto.fromJson(Map<String, dynamic> value)
      : salesDocumentItem = value["SalesDocumentItem"],
        materialNumber = value["MaterialNumber"],
        priceListCondition = value["PriceListCondition"],
        discountAmount = value["DiscountAmount"],
        cashDiscountAmount = value["CashDiscountAmount"],
        cashDiscountCondition = value["CashDiscountCondition"],
        reightChargeAmount = value["FreightChargeAmount"],
        freightChargeCondition = value["FreightChargeCondition"],
        extraChargeAmount = value["ExtraChargeAmount"],
        extraChargeCondition = value["ExtraChargeCondition"],
        zsscAmount = value["ZSSC_Amount"],
        vatAmount = value["VATAmount"],
        vatCondition = value["VATCondition"],
        totalCondition = value["TotalCondition"],
        currency = value["Currency"],
        itemCategory = value["ItemCategory"],
        quantity = value["Quantity"] {
    final zsscConditionValue = value["ZSSC_Condition"];
    if (zsscConditionValue is double) {
      zsscCondition = zsscConditionValue;
    }
    if (zsscConditionValue is int) {
      zsscCondition = zsscConditionValue.toInt();
    }
    final vatConditionValue = value["vatCondition"];
    if (vatConditionValue is double) {
      vatCondition = vatConditionValue;
    }
    if (vatConditionValue is int) {
      vatCondition = vatConditionValue.toInt();
    }
    final amountValue = value["Amount"];
    if (amountValue is double) {
      amount = amountValue;
    }
    if (amountValue is int) {
      amount = amountValue.toInt();
    }
    final totalAmountValue = value["TotalAmount"];
    if (totalAmountValue is double) {
      totalAmount = totalAmountValue;
    }
    if (totalAmountValue is int) {
      totalAmount = totalAmountValue.toInt();
    }
    final netAfterVatRate = value["NetAfterVatRate"];
    if (netAfterVatRate is double) {
      NetAfterVatRate = netAfterVatRate;
    }
    if (netAfterVatRate is String) {
      NetAfterVatRate = double.tryParse(netAfterVatRate) ?? 0.0;
    }
  }
  List<String?>? getProductCodes() {
    return [materialNumber];
  }
}

class RequestReferenceCodeDto {
  String? requestReferenceCode;

  RequestReferenceCodeDto.fromJson(Map<String, dynamic> value) : requestReferenceCode = value["requestReferenceCode"];
}

class SalesOrderStatusDto {
  String? requestReferenceCode;
  String? status;
  String? internalStatus;
  List<SalesOrderCalloutStatusDto>? salesOrderCalloutStatuses;

  SalesOrderStatusDto.fromJson(Map<String, dynamic> value)
      : requestReferenceCode = value["requestReferenceCode"],
        status = value["status"],
        internalStatus = value["internalStatus"],
        salesOrderCalloutStatuses = ((value["salesOrderCalloutStatuses"] ?? []) as List<dynamic>)
            .map((calloutStatusData) => SalesOrderCalloutStatusDto.fromJson(calloutStatusData))
            .toList();
}

class OrderVolumeGraphDto {
  GraphResultDto? result;

  OrderVolumeGraphDto.fromJson(Map<String, dynamic> json)
      : result = json['result'] != null ? GraphResultDto.fromJson(json['result']) : null;
}

class GraphResultDto {
  MonthDataDto? ytd;
  MonthDataDto? mtd;

  GraphResultDto.fromJson(Map<String, dynamic> json)
      : ytd = json['ytd'] != null ? MonthDataDto.fromJson(json['ytd']) : null,
        mtd = json['mtd'] != null ? MonthDataDto.fromJson(json['mtd']) : null;
}

class MonthDataDto {
  String? total;
  List<DataItemDto>? data;

  MonthDataDto.fromJson(Map<String, dynamic> json)
      : total = json['total'],
        data = (json['data'] as List<dynamic>?)?.map((item) => DataItemDto.fromJson(item)).toList();
}

class DataItemDto {
  String? key;
  double? value;

  DataItemDto.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        value = (json['value'] as num?)?.toDouble();
}

class PaymentListDto {
  int? companyCode;
  String? customerCode;
  int? documentNo_FI;
  int? billingDoc;
  int? invoiceDoc;
  String? postingDate;
  String? documentDate;
  String? netDueDate;
  String? lineItem;
  String? amountDocCurrency;
  String? docCurrency;
  String? documentType;
  String? customerPONumber;
  String? reference;
  String? overdueDays;
  String? overdueAmount;
  String? description;
  String? assignment;
  String? name;
  String? documentType2;
  String? specialGL;

  PaymentListDto.fromJson(Map<String, dynamic> value)
      : companyCode = value["CompanyCode"],
        customerCode = value["CustomerCode"],
        documentNo_FI = value["DocumentNo_FI"],
        billingDoc = value["BillingDoc"],
        invoiceDoc = value["InvoiceDoc"],
        postingDate = value["PostingDate"],
        documentDate = value["DocumentDate"],
        netDueDate = value["NetDueDate"],
        lineItem = value["LineItem"],
        amountDocCurrency = value["AmountDocCurrency"],
        docCurrency = value["DocCurrency"],
        documentType = value["DocumentType"],
        customerPONumber = value["CustomerPONumber"],
        reference = value["Reference"],
        overdueDays = value["OverdueDays"],
        overdueAmount = value["OverdueAmount"],
        description = value["Description"],
        assignment = value["Assignment"],
        name = value["name"],
        documentType2 = value["DocumentType2"],
        specialGL = value["SpecialGL"];
}

class InvoiceListDto {
  String? svat;
  String? totalAfterSvat;
  int? companyCode;
  String? customerCode;
  int? documentNo_FI;
  int? billingDoc;
  int? invoiceDoc;
  String? postingDate;
  String? documentDate;
  String? netDueDate;
  String? lineItem;
  String? amountDocCurrency;
  String? docCurrency;
  String? documentType;
  String? documentType2;
  String? customerPONumber;
  String? reference;
  String? overdueDays;
  String? overdueAmount;
  String? description;
  String? assignment;
  String? name;
  String? specialGL;

  InvoiceListDto.fromJson(Map<String, dynamic> value)
      : svat = value["svat"],
        totalAfterSvat = value["totalAfterSvat"],
        companyCode = value["CompanyCode"],
        customerCode = value["CustomerCode"],
        documentNo_FI = value["DocumentNo_FI"],
        billingDoc = value["BillingDoc"],
        invoiceDoc = value["InvoiceDoc"],
        postingDate = value["PostingDate"],
        documentDate = value["DocumentDate"],
        netDueDate = value["NetDueDate"],
        lineItem = value["LineItem"],
        amountDocCurrency = value["AmountDocCurrency"],
        docCurrency = value["DocCurrency"],
        documentType = value["DocumentType"],
        documentType2 = value["DocumentType2"],
        customerPONumber = value["CustomerPONumber"],
        reference = value["Reference"],
        overdueDays = value["OverdueDays"],
        overdueAmount = value["OverdueAmount"],
        description = value["Description"],
        assignment = value["Assignment"],
        name = value["name"],
        specialGL = value["SpecialGL"];
}

class PaymentSetoffListDto {
  int? id;
  String? lastModifiedDate;
  String? createdDate;
  String? soldToCode;
  String? reference;
  String? status;
  double? totalInvoiceAmount;
  List<SetOffInvoiceListDto>? setOffInvoiceList;
  List<SetOffPaymentListDto>? setOffPaymentList;

  PaymentSetoffListDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        soldToCode = value["soldToCode"],
        reference = value["reference"],
        status = value["status"],
        totalInvoiceAmount = value["totalInvoiceAmount"],
        setOffInvoiceList = (value["setOffInvoiceList"] as List<dynamic>)
            .map((setOffInvoiceListData) => SetOffInvoiceListDto.fromJson(setOffInvoiceListData))
            .toList(),
        setOffPaymentList = (value["setOffPaymentList"] as List<dynamic>)
            .map((setOffPaymentListData) => SetOffPaymentListDto.fromJson(setOffPaymentListData))
            .toList();
}

class SetOffInvoiceListDto {
  int? id;
  String? lastModifiedDate;
  String? createdDate;
  String? type;
  String? documentNo;
  String? invoiceNo;
  double? amount;
  double? paidAmount;
  // String? salesOrder;

  SetOffInvoiceListDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        type = value["type"],
        documentNo = value["documentNo"],
        invoiceNo = value["invoiceNo"],
        amount = value["amount"],
        paidAmount = value["paidAmount"];
        // salesOrder = value["salesOrder"];
}

class SetOffPaymentListDto {
  int? id;
  String? lastModifiedDate;
  String? createdDate;
  String? type;
  String? documentNo;
  String? invoiceNo;
  double? amount;
  double? paidAmount;
  // String? salesOrder;

  SetOffPaymentListDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        lastModifiedDate = value["lastModifiedDate"],
        createdDate = value["createdDate"],
        type = value["type"],
        documentNo = value["documentNo"],
        invoiceNo = value["invoiceNo"],
        amount = value["amount"],
        paidAmount = value["paidAmount"];
        // salesOrder = value["salesOrder"];
}

class ReportDataDto {
  List<String>? soNumbers;
  List<String>? poNumbers;
  List<PlantDto>? plants;
  List<MaterialDto>? materials;
  List<String>? soStatuses;

  ReportDataDto.fromJson(Map<String, dynamic> value)
      : soNumbers = (value["soNumbers"] as List<dynamic>?)?.whereType<String>().cast<String>().toList(),
        poNumbers = (value["poNumbers"] as List<dynamic>?)?.whereType<String>().cast<String>().toList(),
        plants = (value["plants"] as List<dynamic>?)?.map((plantData) => PlantDto.fromJson(plantData)).toList(),
        materials =
            (value["materials"] as List<dynamic>?)?.map((materialData) => MaterialDto.fromJson(materialData)).toList(),
        soStatuses = (value["soStatuses"] as List<dynamic>?)?.whereType<String>().cast<String>().toList();
}

class PlantDto {
  String? code;
  String? name;

  PlantDto.fromJson(Map<String, dynamic> value)
      : code = value["code"],
        name = value["name"];
}

class MaterialDto {
  String? code;
  String? name;

  MaterialDto.fromJson(Map<String, dynamic> value)
      : code = value["code"],
        name = value["name"];
}

class SOReportDto {
  String? orderQuantity;
  String? totalValueWithoutVat;
  String? tax;
  String? totalValueWithVat;
  List<SalesOrderReportDto>? salesOrderReports;

  SOReportDto.fromJson(Map<String, dynamic> value)
      : orderQuantity = value["orderQuantity"],
        totalValueWithoutVat = value["totalValueWithoutVat"],
        tax = value["tax"],
        totalValueWithVat = value["totalValueWithVat"],
        salesOrderReports = (value["salesOrderReports"] as List<dynamic>)
            .map((reportData) => SalesOrderReportDto.fromJson(reportData))
            .toList();
}

class SalesOrderReportDto {
  String? salesOrderDate;
  String? soldToCode;
  String? soldToName;
  String? shipToCode;
  String? shipToName;
  String? orderType;
  String? soNumber;
  String? poNumber;
  double? orderQuantity;
  List<RemainingQtyDto>? remainingQuantity;
  String? plant;
  String? shippingCondition;
  String? material;
  String? materialGroup;
  String? unitPriceWithVat;
  String? unitPriceWithoutVat;
  double? totalValueWithoutVat;
  double? tax;
  double? totalValueWithVat;
  String? soStatus;

  SalesOrderReportDto.fromJson(Map<String, dynamic> value)
      : salesOrderDate = value["salesOrderDate"],
        soldToCode = value["soldToCode"],
        soldToName = value["soldToName"],
        shipToCode = value["shipToCode"],
        shipToName = value["shipToName"],
        orderType = value["orderType"],
        soNumber = value["soNumber"],
        poNumber = value["poNumber"],
        orderQuantity = value["orderQuantity"],
        remainingQuantity = (value["remainingPoQuantities"] as List<dynamic>?)
            ?.map((reportData) => RemainingQtyDto.fromJson(reportData))
            .toList(),
        plant = value["plant"],
        shippingCondition = value["shippingCondition"],
        material = value["material"],
        materialGroup = value["materialGroup"],
        unitPriceWithVat = value["unitPriceWithVat"],
        unitPriceWithoutVat = value["unitPriceWithoutVat"],
        totalValueWithoutVat = value["totalValueWithoutVat"],
        tax = value["tax"],
        totalValueWithVat = value["totalValueWithVat"],
        soStatus = value["soStatus"];
}

class RemainingQtyDto {
  dynamic remainingPoQuantity;
  String? productName;

  RemainingQtyDto.fromJson(Map<String, dynamic> value) : remainingPoQuantity = value["remainingPoQuantity"],
        productName = value["productName"];
}

class ActiveUserDto {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  String? sapEmployeeCode;
  List<RoleDto>? roles;

  ActiveUserDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        sapEmployeeCode = value["sapEmployeeCode"],
        roles = (value["roles"] as List<dynamic>).map((roleData) => RoleDto.fromJson(roleData)).toList();
}

class BannerDto {
  String? contentMobileImageUrl;

  BannerDto.fromJson(Map<String, dynamic> value) : contentMobileImageUrl = value["contentMobileImageUrl"];
}
