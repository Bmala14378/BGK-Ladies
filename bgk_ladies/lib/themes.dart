import 'package:flutter/material.dart';

class AppTheme {
  // 1. Core Brand Colors (Extracted from your files)
  static const Color primaryPurple = Colors.purple;
  static final Color primaryDark = Colors.purple[800]!;
  static final Color primaryDeep = Colors.purple[900]!;
  static final Color primaryLight = Colors.purple[50]!;

  // 2. Background Colors
  static const Color backgroundWhite = Colors.white;
  static final Color backgroundGrey = Colors.grey[50]!;

  // 3. Status Colors (For Attendance/State)
  static const Color statusPresent = Colors.green;
  static final Color statusLate = Colors.yellow[800]!;
  static const Color statusAbsent = Colors.red;

  // 4. Main Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: backgroundGrey, // Used in EventManagement
      // Color Scheme maps your colors to built-in Material components
      colorScheme: ColorScheme.light(
        primary: primaryDark,
        secondary: primaryPurple,
        surface: backgroundWhite,
        error: statusAbsent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),

      // AppBar Theme (Standardized across Dashboard, Appoint, Attend, Event)
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Elevated Button Theme (Used in Login, Register, Appoint, Event Mgmt)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55), // From Auth screens
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // From Auth/Appoint
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      // Floating Action Button Theme (Used in Event Mgmt, Attend)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Text Field / Input Decoration Theme (Used in Login, Register, Appoint)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryLight.withAlpha(200), // From Auth screens
        prefixIconColor: primaryPurple,
        hintStyle: TextStyle(color: Colors.grey[500]),
        labelStyle: const TextStyle(color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),

      // Card Theme (Used in Dashboard, Attend, Appoint)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.purple,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
