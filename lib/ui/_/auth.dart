import 'package:azure_ad_authentication/azure_ad_authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AADTestPage extends StatefulWidget {
  const AADTestPage({super.key});

  /// Insee AD
  // static const String _authority = "https://login.microsoftonline.com/8e9a02ca-d0ea-4763-900c-ac6ee988b360";
  // static const String _redirectUriIos = "msauth.com.insee.odms://auth";
  // static const String _clientId = "11b6005d-08df-46b6-8a75-261c910ea27e";

  /// Test AD
  static const String _authority = "https://login.microsoftonline.com/0ba7727c-fc0d-4444-907c-0329417719af";
  static const String _redirectUriIos = "msauth.com.insee.odms://auth";
  static const String _clientId = "6ec94de0-aac7-4461-961f-5324fa89cef2";

  static const List<String> kScopes = [
    "https://graph.microsoft.com/user.read",
  ];

  @override
  State<AADTestPage> createState() => _AADTestPageState();
}

class _AADTestPageState extends State<AADTestPage> {
  getResult({bool isAcquireToken = true}) async {

    // inseepro_ba@outlook.com
    // May@2023

    AzureAdAuthentication pca = await AzureAdAuthentication.createPublicClientApplication(
      clientId: AADTestPage._clientId,
      authority: AADTestPage._authority,
      redirectUri: AADTestPage._redirectUriIos,
    );

    try {
      final response = await pca.acquireToken(scopes: AADTestPage.kScopes);
      if (kDebugMode) {
        print(response);
      }
    } catch(err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              getResult();
            },
            child: const Text("Acquire Token"),
          ),
        ],
      ),
    );
  }
}
