import 'package:flutter/material.dart';

class CTTextField {
  CTTextField._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Color(0xFF1565C0),
    suffixIconColor: Color(0xFF1565C0),
    labelStyle: const TextStyle().copyWith(
      fontFamily: 'LeagueSpartan',
      color: Color(0xFF1565C0),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: const TextStyle().copyWith(
      color: Color(0xFF1565C0),
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'LeagueSpartan',
    ),
    errorStyle: const TextStyle().copyWith(
      color: Color(0xFFB71C1C),
      fontSize: 14,
      fontFamily: 'LeagueSpartan',
      fontWeight: FontWeight.w600,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: Color(0xFF1565C0),
      fontSize: 14,
      fontFamily: 'LeagueSpartan',
      fontWeight: FontWeight.w600,
    ),
    border: const OutlineInputBorder().copyWith(
      borderSide: BorderSide(
        color: Color(0xFF1565C0),
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderSide: BorderSide(
        color: Color(0xFF1565C0),
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderSide: BorderSide(
        color: Color(0xFF1565C0),
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Color(0xFFE0F2F1),
    suffixIconColor: Color(0xFFE0F2F1),
    labelStyle: const TextStyle().copyWith(
      fontFamily: 'LeagueSpartan',
      color: Color(0xFFE0F2F1),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: const TextStyle().copyWith(
      color: Color(0xFFE0F2F1),
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'LeagueSpartan',
    ),
    errorStyle: const TextStyle().copyWith(
      color: Color(0xFFB71C1C),
      fontSize: 14,
      fontFamily: 'LeagueSpartan',
      fontWeight: FontWeight.w600,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: Color(0xFFE0F2F1),
      fontSize: 14,
      fontFamily: 'LeagueSpartan',
      fontWeight: FontWeight.w600,
    ),
    border: const OutlineInputBorder().copyWith(
      borderSide: BorderSide(
        color: Color(0xFFE0F2F1),
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderSide: BorderSide(
        color: Color(0xFFE0F2F1),
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderSide: BorderSide(
        color: Color(0xFFE0F2F1),
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
  );
}
