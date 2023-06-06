import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Museo Sans Rounded',
  //primaryColor: Color(0xB3BE6105),
  primaryColor: Color(0xFF59a52c),
  secondaryHeaderColor: Color(0xff6d0005),
  disabledColor: Color(0xffa2a7ad),
  brightness: Brightness.dark,
  //hintColor: Color(0xFFbebebe),
  hintColor: Color(0xFFf77f00),
  cardColor: Color(0xff12141a),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Color(0xFFffbd5c))), colorScheme: ColorScheme.dark(primary: Color(0xFFffbd5c), secondary: Color(0xFFffbd5c)).copyWith(background: Color(0xFF343636)).copyWith(error: Color(0xFFdd3135)),
);
