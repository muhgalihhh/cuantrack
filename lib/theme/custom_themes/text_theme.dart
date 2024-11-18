import 'package:flutter/material.dart';

class CTTextTheme {
  CTTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    //heading Styles
    headlineLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
      fontFamily: 'Montserrat',
    ),
    headlineMedium: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
      fontFamily: 'Montserrat',
    ),
    headlineSmall: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
      fontFamily: 'Montserrat',
    ),

    // Title Styles
    titleLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF212121),
      fontFamily: 'LeagueSpartan',
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF212121),
      fontFamily: 'LeagueSpartan',
    ),
    titleSmall: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'LeagueSpartan',
      color: Color(0xFF212121),
    ),

    // body Styles
    bodyLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF212121),
      fontFamily: 'LeagueSpartan',
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF212121),
      fontFamily: 'LeagueSpartan',
    ),
    bodySmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(255, 67, 66, 66),
      fontFamily: 'LeagueSpartan',
    ),

    // label Styles
    labelLarge: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF212121),
      fontFamily: 'LeagueSpartan',
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'LeagueSpartan',
      color: Color.fromARGB(255, 67, 66, 66),
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    // heading styles
    headlineLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFFEEEEEE),
      fontFamily: 'Montserrat',
    ),
    headlineMedium: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFFEEEEEE),
      fontFamily: 'Montserrat',
    ),
    headlineSmall: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Color(0xFFEEEEEE),
      fontFamily: 'Montserrat',
    ),

    // Title Styles
    titleLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFFEEEEEE),
      fontFamily: 'LeagueSpartan',
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFFEEEEEE),
      fontFamily: 'LeagueSpartan',
    ),
    titleSmall: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'LeagueSpartan',
      color: Color(0xFFEEEEEE),
    ),

    // body Styles
    bodyLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFEEEEEE),
      fontFamily: 'LeagueSpartan',
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFFEEEEEE),
      fontFamily: 'LeagueSpartan',
    ),
    bodySmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(255, 193, 193, 193),
      fontFamily: 'LeagueSpartan',
    ),

    // label Styles
    labelLarge: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFFEEEEEE),
      fontFamily: 'LeagueSpartan',
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'LeagueSpartan',
      color: Color.fromARGB(255, 182, 182, 182),
    ),
  );
}
