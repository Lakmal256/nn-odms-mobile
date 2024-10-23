import 'package:flutter/material.dart';

class AppConfig {
  final String? appName;
  final String? flavor;
  final String? authority;
  final String? apimDomain;
  final String? swaggerDomain;
  final String? tenantId;
  final String? adAuthority;
  final String? redirectUriIos;
  final String? redirectUriAndroid;
  final String? clientId;
  final String? termsAndConditionUri;
  AppConfig(
      {@required this.appName,
      @required this.flavor,
      @required this.authority,
      @required this.apimDomain,
      @required this.swaggerDomain,
      @required this.tenantId,
      @required this.adAuthority,
      @required this.redirectUriIos,
      @required this.redirectUriAndroid,
      @required this.clientId,
      @required this.termsAndConditionUri});
}
