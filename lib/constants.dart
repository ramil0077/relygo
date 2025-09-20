import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Mycolors {
  static Color textcolor = Colors.white;
  static Color basecolor = Color(0xFF8B4513); // Brown color
  static Color lightBrown = Color(0xFFD2B48C); // Light brown
  static Color darkBrown = Color(0xFF654321); // Dark brown
  static Color orange = Color(0xFFFF6B35); // Orange for call icons
  static Color red = Color(0xFFDC143C); // Red for error states
  static Color green = Color(0xFF228B22); // Green for success
  static Color gray = Color(0xFF808080); // Gray for text
  static Color lightGray = Color(0xFFF5F5F5); // Light gray background
  static Color gradient = Color.fromARGB(55, 150, 103, 86);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.brown,
      primaryColor: Mycolors.basecolor,
      fontFamily: 'Poppins',
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Mycolors.basecolor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Mycolors.basecolor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
      ),
    );
  }
}
