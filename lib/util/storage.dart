import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  saveValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Future<String?> readValue(String key) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(key);
  // }

  eraseValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<Map<String, String>> readTokens() async {
    String? rawTokenData = await readValue("tokens");
    if (rawTokenData != null) {
      Map<String, dynamic> jsonData = jsonDecode(rawTokenData);
      return {
        "accessToken": jsonData['accessToken'],
        "refreshToken": jsonData['refreshToken'],
      };
    }
    return {};
  }
}
