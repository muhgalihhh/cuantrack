import 'package:flutter/material.dart';

class CTOutlinedButtonTheme {
  CTOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Color(0xFF26A69A),
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: Color(0xFF26A69A),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Color(0xFF80CBC4),
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: Color(0xFF80CBC4),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
