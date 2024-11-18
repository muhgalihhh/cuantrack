import 'package:cuantrack/theme/appcolors.dart';
import 'package:cuantrack/theme/custom_themes/appbar_theme.dart';
import 'package:cuantrack/theme/custom_themes/elevated_button_theme.dart';
import 'package:cuantrack/theme/custom_themes/outlined_button_theme.dart';
import 'package:cuantrack/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class CTAppTheme {
  // Private Constructor
  CTAppTheme._();

  // Static Function
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: AppColors.lightColorScheme,

    // Custom Theme
    textTheme: CTTextTheme.lightTextTheme,
    appBarTheme: CTAppBarTheme.lightAppBarTheme,
    elevatedButtonTheme: CTElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: CTOutlinedButtonTheme.lightOutlinedButtonTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: AppColors.darkColorScheme,

    // Custom Theme
    textTheme: CTTextTheme.darkTextTheme,
    appBarTheme: CTAppBarTheme.darkAppBarTheme,
    elevatedButtonTheme: CTElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: CTOutlinedButtonTheme.darkOutlinedButtonTheme,
  );
}
