import 'package:flutter/material.dart';


final Color backgroundColor = Color(0xFF1D1E22);
final Color whiteColor = Colors.white;
final Color primaryColor = Colors.tealAccent;



final Color whiteColor2 = Colors.white70;
final Color greyColor = Colors.grey.shade700;
final Color darkGreyColor = Colors.grey.shade800;
final Color darkColor = Color(0xFF2A2C31);

final Color redColor = Colors.red;
final Color greenColor = Colors.green;



ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,

    primaryColor: primaryColor,
    hintColor: whiteColor2,

    textTheme: TextTheme(
      bodyMedium: TextStyle(color: whiteColor),
      bodyLarge: TextStyle(color: whiteColor),
      titleLarge: TextStyle(color: whiteColor),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGreyColor,
      labelStyle: TextStyle(color: whiteColor2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: greyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkColor,
      foregroundColor: whiteColor,
      elevation: 0,
      centerTitle: true,
    ),

    cardColor: darkColor,

    highlightColor: primaryColor.withOpacity(0.2),
    splashColor: primaryColor.withOpacity(0.1),

    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      onPrimary: backgroundColor,
      surface: darkColor,
      onSurface: whiteColor,
      secondary: primaryColor,
    ),
  );
}
