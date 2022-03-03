import 'package:flutter/material.dart';

class GlobalTheme {
  static ThemeData bitlogTheme() {
    return ThemeData(
      colorScheme: const ColorScheme(
        primary: Color(0xff005aaa),
        primaryVariant: Color(0xff505050),
        secondary: Color(0xff004789),
        secondaryVariant: Color(0xffffffff),
        brightness: Brightness.light,
        background: Color(0xfff3f3f3),
        error: Colors.red,
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        surface: Color(0xffffffff)
      ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            fontFamily: 'SofiaProSoft'
        )
      )
    );
  }
}