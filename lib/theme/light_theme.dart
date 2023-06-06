import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Museo Sans Rounded',
  //primaryColor: Color(0xB3BE6105),
  primaryColor: Color(0xFF59a52c),
  secondaryHeaderColor: Color(0xff6d0005),
  disabledColor: Color(0xFFBABFC4),
  brightness: Brightness.light,
  //hintColor: Color(0xFF9F9F9F),
  hintColor: Color(0xFFf77f00),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Color(0xFFEF7822))), colorScheme: ColorScheme.light(primary: Color(0xFFEF7822), secondary: Color(0xFFEF7822)).copyWith(background: Color(0xFFF3F3F3)).copyWith(error: Color(0xFFE84D4F)),
);