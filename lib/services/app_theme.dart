import 'package:flutter/material.dart';

class AppTheme {
  // Warna dasar untuk tema terang pink
  static const Color primaryColor = Color(0xFFFF69B4); // Hot Pink
  static const Color secondaryColor = Color(0xFFFFC0CB); // Light Pink
  static const Color backgroundColor = Color(0xFFFFF0F5); // Lavender Blush
  static const Color cardColor = Color(0xFFFFFFFF); // Putih
  static const Color textColorDark = Color(0xFF4A4A4A);
  static const Color accentColor = Color(0xFFFF1493); // Deep Pink

  // Warna dasar untuk tema gelap pink
  static const Color darkPrimaryColor = Color(0xFF8B008B); // Dark Magenta
  static const Color darkSecondaryColor = Color(0xFF9932CC); // Dark Orchid
  static const Color darkBackgroundColor = Color(0xFF2C001E); // Dark Purple
  static const Color darkCardColor = Color(0xFF4B0082); // Indigo
  static const Color textColorLight = Color(0xFFFFF0F5);
  static const Color darkAccentColor = Color(0xFFFF69B4); // Hot Pink

  // Tema Terang Pink
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    fontFamily: 'Montserrat',

    // ColorScheme untuk tema terang
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textColorDark,
      onSurface: textColorDark,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'LeagueSpartan',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 2),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: textColorDark.withOpacity(0.7)),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: secondaryColor.withOpacity(0.2),
      labelStyle: TextStyle(color: primaryColor),
      selectedColor: primaryColor,
      checkmarkColor: Colors.white,
      elevation: 2,
    ),

    // TabBar Theme
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: textColorDark.withOpacity(0.6),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: cardColor,
      titleTextStyle: TextStyle(
        color: textColorDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: textColorDark,
        fontSize: 16,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: primaryColor.withOpacity(0.3),
      thickness: 1,
    ),

    // Text Theme
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'LeagueSpartan',
        color: textColorDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textColorDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: textColorDark.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
    ),
  );

  // Tema Gelap Pink
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    fontFamily: 'Montserrat',
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      background: darkBackgroundColor,
      surface: darkCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textColorLight,
      onSurface: textColorLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkPrimaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'LeagueSpartan',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkSecondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkAccentColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: darkAccentColor),
      ),
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'LeagueSpartan',
        color: textColorLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textColorLight,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: textColorLight.withOpacity(0.7),
        fontSize: 14,
      ),
    ),
  );
}
