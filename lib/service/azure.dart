import 'dart:io';

import 'package:azure_ad_authentication/azure_ad_authentication.dart';
import 'package:azure_ad_authentication/model/user_ad.dart';
import 'package:odms/app_config.dart';
import 'package:odms/locator.dart';

class Tokens {
  String? idToken;

  Tokens({this.idToken});
}

class AdAuthResult {
  Tokens tokens;

  AdAuthResult({required this.tokens});
}

class AzureAuthService {
  static final String _authority = locate<AppConfig>().adAuthority!;
  static final String _redirectUriIos = locate<AppConfig>().redirectUriIos!;
  static final String _redirectUriAndroid = locate<AppConfig>().redirectUriAndroid!;
  static final String _clientId = locate<AppConfig>().clientId!;

  static const List<String> kScopes = [
    "https://graph.microsoft.com/user.read",
  ];

  static AzureAdAuthentication? pca;

  static Future<UserAdModel?> login() async {
    // Determine the appropriate redirect URI based on the platform (iOS or Android)
    var _redirectUri = Platform.isIOS ? _redirectUriIos : _redirectUriAndroid;

    // Create a public client application instance with the specified parameters
    pca = await AzureAdAuthentication.createPublicClientApplication(
      clientId: _clientId,
      authority: _authority,
      redirectUri: _redirectUri,
    );
    // Acquire a token using the specified scopes
    return await pca!.acquireToken(scopes: kScopes);
  }

  static Future<UserAdModel?> get idToken async {
    if (pca == null) {
      await login();
    }
    // Acquire a token silently using the specified scopes
    return await pca!.acquireTokenSilent(scopes: kScopes);
  }

  static void logout() {
    // Clear the current user's session and logout
    pca?.logout();
    pca = null;
  }
}
