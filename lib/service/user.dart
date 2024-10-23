import 'package:flutter/foundation.dart';

import '../locator.dart';
import 'dto.dart';
import 'rest.dart';

class UserData {
  String email;
  String mobile;

  UserData({required this.email, required this.mobile});

  UserData.empty() : email = "", mobile = "";
}

class User {
  UserData data;

  User({required this.data,
  });
}

class UserService extends ValueNotifier<User> {
  UserService(super.value);

  setUser(User user){
    user = user;
    notifyListeners();
  }
}



