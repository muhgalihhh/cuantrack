import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary Colors
    primary: Color(0xFF1E88E5), // Biru yang professional
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE3F2FD),
    onPrimaryContainer: Color(0xFF1565C0),

    // Secondary Colors
    secondary: Color(0xFF26A69A), // Tosca untuk aksen
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE0F2F1),
    onSecondaryContainer: Color(0xFF00796B),

    // Background Colors
    background: Color(0xFFFFFFFF),
    onBackground: Color(0xFF212121),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF212121),

    // Error Colors
    error: Color(0xFFE53935), // Merah untuk peringatan/error
    onError: Colors.white,
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFB71C1C),

    // Success Colors (Custom)
    outline: Color(0xFF4CAF50), // Hijau untuk indikator positif/sukses
  );

  // Dark Mode Colors
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary Colors
    primary: Color(0xFF90CAF9), // Biru yang lebih soft
    onPrimary: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF1976D2),
    onPrimaryContainer: Color(0xFFE3F2FD),

    // Secondary Colors
    secondary: Color(0xFF80CBC4), // Tosca yang lebih soft
    onSecondary: Color(0xFF004D40),
    secondaryContainer: Color(0xFF00796B),
    onSecondaryContainer: Color(0xFFE0F2F1),

    // Background Colors
    background: Color(0xFF121212), // Dark grey untuk background
    onBackground: Color(0xFFEEEEEE),
    surface: Color(0xFF1E1E1E), // Sedikit lebih terang dari background
    onSurface: Color(0xFFEEEEEE),

    // Error Colors
    error: Color(0xFFEF9A9A), // Merah yang lebih soft
    onError: Color(0xFF212121),
    errorContainer: Color(0xFFB71C1C),
    onErrorContainer: Color(0xFFFFEBEE),

    // Success Colors (Custom)
    outline: Color(0xFF81C784), // Hijau yang lebih soft
  );

  // Custom Colors untuk Fitur Keuangan
  static const moneyPositive = Color(0xFF4CAF50); // Hijau untuk saldo positif
  static const moneyNegative = Color(0xFFE53935); // Merah untuk saldo negatif
  static const moneyNeutral =
      Color(0xFF757575); // Abu-abu untuk transaksi normal

  // Gradient Colors
  static const gradientStart = Color(0xFF1E88E5);
  static const gradientEnd = Color(0xFF26A69A);

  // Opacity Colors
  static Color shadowColor = Colors.black.withOpacity(0.1);
  static Color overlayColor = Colors.black.withOpacity(0.5);
}
