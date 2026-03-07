import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/utils/responsive.dart';

/// Payment / Razorpay config. Override key via --dart-define=RAZORPAY_KEY=your_key
class PaymentConfig {
  static String get razorpayKey => const String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_1DP5mmOlF5G5ag',
  );
}

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
  static Color blue = Color(0xFF2196F3); // Blue color
  static Color purple = Color(0xFF9C27B0); // Purple color
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
      dividerColor: Colors.grey.shade300,
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
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: Mycolors.basecolor,
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
      colorScheme: base.colorScheme.copyWith(
        primary: Mycolors.basecolor,
        secondary: Mycolors.orange,
        surface: Color(0xFF1E1E1E),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
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
      dialogTheme: DialogThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class AppSettings {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);
}

class ResponsiveTextStyles {
  static TextStyle getTitleStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 24,
        tablet: 28,
        desktop: 32,
      ),
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle getSubtitleStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 16,
        tablet: 18,
        desktop: 20,
      ),
      color: Mycolors.gray,
    );
  }

  static TextStyle getCardTitleStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 18,
        tablet: 20,
        desktop: 22,
      ),
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle getCardSubtitleStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 14,
        tablet: 16,
        desktop: 18,
      ),
      color: Colors.white.withOpacity(0.9),
    );
  }

  static TextStyle getFeatureTextStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 14,
        tablet: 15,
        desktop: 16,
      ),
      color: Colors.white.withOpacity(0.9),
    );
  }

  static TextStyle getNavLabelStyle(BuildContext context, bool isActive) {
    return GoogleFonts.poppins(
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        mobile: 12,
        tablet: 13,
        desktop: 14,
      ),
      color: isActive ? Mycolors.basecolor : Colors.grey,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
    );
  }
}

class ResponsiveSpacing {
  static double getSmallSpacing(BuildContext context) {
    return ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );
  }

  static double getMediumSpacing(BuildContext context) {
    return ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );
  }

  static double getLargeSpacing(BuildContext context) {
    return ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 24,
      tablet: 32,
      desktop: 40,
    );
  }

  static double getExtraLargeSpacing(BuildContext context) {
    return ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 32,
      tablet: 40,
      desktop: 48,
    );
  }
}

// EmailJS configuration - replace these with values from your EmailJS account
class EmailJsConfig {
  // Public (user) id from EmailJS Dashboard → Account → API Keys
  static const String userId = 'DUxMvuZFPNxopEw8A';
  // Private API Key from EmailJS Dashboard → Account → API Keys
  // IMPORTANT: This is required for REST API calls from non-browser apps.
  // Go to: https://dashboard.emailjs.com/admin/account/security
  static const String privateKey =
      '4zCGFHzpCyG_h24BmScBE'; // <-- Replace this!
  // Email service ID from EmailJS Dashboard → Email Services
  static const String serviceId = 'service_418nip9';
  // Template ID for driver approval emails
  static const String approvalTemplateId =
      'template_2hvhyzd'; // Your approval template
  // Template ID for driver rejection emails (can be same or different template)
  static const String rejectionTemplateId =
      'template_2hvhyzd'; // Change if you have a separate rejection template
  // Legacy alias kept for backward compatibility
  static const String templateId = approvalTemplateId;
}
