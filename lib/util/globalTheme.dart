import 'package:flutter/material.dart';

class GlobalTheme {
  static ThemeData bitlogTheme() {
    return ThemeData(
      colorScheme: const ColorScheme(
        primary: Color(0xff3C1B43),
        secondary: Color(0xff501537),
        tertiary: Color(0xff922D50),
        brightness: Brightness.dark,
        background: Color(0xff4F7CAC),
        error: Colors.red,
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        surface: Color(0xffC0E0DE)
      )
    );
  }
}