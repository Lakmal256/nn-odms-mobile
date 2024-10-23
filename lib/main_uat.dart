import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:odms/app_config.dart';
import '../app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PlatformFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'FIREBASE_API_KEY Not found',
          appId: '1:245945224135:android:4acd35b0b4780c687c27e2',
          messagingSenderId: '245945224135',
          projectId: 'inseepro-77eeb',
          storageBucket: 'inseepro-77eeb.appspot.com',
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'FIREBASE_API_KEY Not found',
          appId: '1:245945224135:ios:41abe561fd2806e37c27e2',
          messagingSenderId: '245945224135',
          projectId: 'inseepro-77eeb',
          storageBucket: 'inseepro-77eeb.appspot.com',
          iosBundleId: 'com.insee.odms',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}

void main() async {
  await dotenv.load(fileName: 'dotenv/.env.uat');

  AppConfig appConfig = AppConfig(
      appName: "INSEE PRO",
      flavor: "uat",
      authority: "prep-apim-portal.inseepro.lk",
      apimDomain: "uat-",
      swaggerDomain: "uat-",
      tenantId: "8e9a02ca-d0ea-4763-900c-ac6ee988b360",
      adAuthority: 'https://login.microsoftonline.com/8e9a02ca-d0ea-4763-900c-ac6ee988b360',
      redirectUriIos: 'msauth.com.insee.odms://auth',
      redirectUriAndroid: 'msauth://com.insee.odms/HkmMfzUHAuz2mJanqyzEhj3CV38%3D',
      clientId: '11b6005d-08df-46b6-8a75-261c910ea27e',
      termsAndConditionUri: "https://uat.inseepro.lk/html/so_create_confirm_tnc.html");

  Widget app = await initializeApp(appConfig);

  await Firebase.initializeApp(options: PlatformFirebaseOptions.currentPlatform, name: 'inseepro-77eeb');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(app);
}
