import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Colors
  static const Color primaryColor = Color(0xFFD4AF37); // Moinc gold
  static const Color secondaryColor = Color(0xFF001A36); // Moinc navy blue
  static const Color backgroundColor = Color(0xFF001A36); // Navy background
  static const Color darkBackgroundColor = Color(
    0xFF001A36,
  ); // Dark navy background
  static const Color textColor = Color(0xFF333333); // Dark text
  static const Color lightTextColor = Color(0xFF7A7A7A); // Light text
  static const Color errorColor = Color(0xFFE53935); // Error red
  static const Color successColor = Color(0xFF43A047); // Success green
  static const Color warningColor = Color(0xFFFFB300); // Warning yellow
  static const Color cardColor = Color(0xFF001A36); // Card dark navy
  static const Color dividerColor = Color(0xFFE0E0E0); // Divider grey

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFFC4A030)], // Gold gradient
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFF00142A)], // Navy blue gradient
  );

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textColor,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textColor,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: lightTextColor,
  );

  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: primaryColor),
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      // labelText: labelText,
      hintText: hintText,

      prefixIcon:
          prefixIcon != null
              ? IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: prefixIcon,
              )
              : null,
      suffixIcon:
          suffixIcon != null
              ? IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: suffixIcon,
              )
              : null,
      filled: true,
      fillColor: secondaryColor,

      labelStyle: bodyMedium.copyWith(color: Colors.white),
      hintStyle: bodyMedium.copyWith(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    );
  }

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingSmall.copyWith(color: primaryColor),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryColor,
        labelStyle: bodyMedium.copyWith(color: Colors.white),
        hintStyle: bodyMedium.copyWith(color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: darkBackgroundColor,
        surface: const Color(0xFF00142A),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF00142A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingSmall.copyWith(color: primaryColor),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        labelStyle: bodyMedium.copyWith(color: Colors.white),
        hintStyle: bodyMedium.copyWith(color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3E3E3E),
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: headingLarge.copyWith(color: Colors.white),
        displayMedium: headingMedium.copyWith(color: Colors.white),
        displaySmall: headingSmall.copyWith(color: Colors.white),
        bodyLarge: bodyLarge.copyWith(color: Colors.white),
        bodyMedium: bodyMedium.copyWith(color: Colors.white),
        bodySmall: bodySmall.copyWith(color: Colors.white70),
      ),
    );
  }
}
