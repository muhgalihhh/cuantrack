import 'package:flutter/material.dart';

class CTElevatedButtonTheme {
  CTElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF26A69A),
      disabledBackgroundColor: Color(0xFFE0F2F1),
      disabledForegroundColor: Color(0xFF00796B),
      side: const BorderSide(
        color: Colors.white,
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

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF80CBC4),
      disabledBackgroundColor: Color(0xFF00796B),
      disabledForegroundColor: Color(0xFFE0F2F1),
      side: const BorderSide(
        color: Colors.white,
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
