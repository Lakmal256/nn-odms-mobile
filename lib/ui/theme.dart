import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  /// Insee Primary Text Color
  /// Larger texts has a bluish tint
  static const _tintedForegroundColorLight = Color(0xff1D1B23);

  static const _appBarTheme = AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    backgroundColor: Colors.transparent,
  );

  static final light = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    fontFamily: "Poppins",
    appBarTheme: _appBarTheme,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColors.red,
      accentColor: AppColors.blue,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _tintedForegroundColorLight),
      displayMedium: TextStyle(color: _tintedForegroundColorLight),
      displaySmall: TextStyle(color: _tintedForegroundColorLight),
      headlineLarge: TextStyle(color: _tintedForegroundColorLight),
      headlineMedium: TextStyle(color: _tintedForegroundColorLight),
      headlineSmall: TextStyle(color: _tintedForegroundColorLight),
      labelLarge: TextStyle(color: Colors.grey),
      labelMedium: TextStyle(color: Colors.grey),
      labelSmall: TextStyle(color: Colors.grey),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Poppins",
  );
}
