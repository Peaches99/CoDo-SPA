import 'package:flutter/material.dart';

class GlobalTheme {
  static ThemeData bitlogTheme() {
    return ThemeData(
      colorScheme: const ColorScheme(
        primary: Color(0xff005aaa),
        secondary: Color(0xff004789),
        tertiary: Color(0xffb4e5ff),
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
            fontFamily: 'SofiaPro'
          ),
          headline1: TextStyle(
              fontSize: 20,
              fontFamily: "SofiaPro"
          ),
          bodyText2: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontFamily: "SofiaPro"
          )
        )
    );
  }
}