import 'package:flutter/material.dart';

class CTAppBarTheme {
  CTAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF212121),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Montserrat',
      color: Color(0xFF212121),
    ),
    iconTheme: IconThemeData(
      color: Color(0xFF1565C0),
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFFEEEEEE),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w600,
      color: Color(0xFFEEEEEE),
    ),
    iconTheme: IconThemeData(
      color: Color(0xFFE0F2F1),
    ),
  );
}
