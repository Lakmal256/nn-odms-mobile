import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
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
        return  FirebaseOptions(
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
  await dotenv.load(fileName: 'dotenv/.env.dev');

  AppConfig appConfig = AppConfig(
      appName: "INSEE PRO",
      flavor: "development",
      authority: "prep-apim-portal.inseepro.lk",
      apimDomain: "",
      swaggerDomain: "prep-",
      tenantId: Platform.isIOS ? "0ba7727c-fc0d-4444-907c-0329417719af" : "ee231c33-0bc8-4864-b040-ed4131ec73aa",
      adAuthority: Platform.isIOS
          ? "https://login.microsoftonline.com/0ba7727c-fc0d-4444-907c-0329417719af"
          : 'https://login.microsoftonline.com/ee231c33-0bc8-4864-b040-ed4131ec73aa',
      redirectUriIos: 'msauth.com.insee.odms://auth',
      redirectUriAndroid: 'msauth://com.insee.odms/0Sr3GNF6XbcFteNewfnRWF85wQY%3D',
      clientId: Platform.isIOS ? "6ec94de0-aac7-4461-961f-5324fa89cef2" : '49eedfc3-10e3-4e87-8a06-340df6b2d604',
      termsAndConditionUri: "https://prep.inseepro.lk/html/so_create_confirm_tnc.html");

  Widget app = await initializeApp(appConfig);

  await Firebase.initializeApp(options: PlatformFirebaseOptions.currentPlatform, name: 'inseepro-77eeb');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(app);
}
