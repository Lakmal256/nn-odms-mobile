import 'dart:ui';

import 'package:flutter/foundation.dart';

class AppLocaleNotifier extends ValueNotifier<Locale>{
  AppLocaleNotifier(Locale locale): super(locale);

  setLocale(Locale locale){
    value = locale;
    notifyListeners();
  }
}