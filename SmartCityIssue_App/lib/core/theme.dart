import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Primary Brand (Green — matches wireframe) ────────────────────
  static const Color primary = Color(0xFF1D5E3F);
  static const Color primaryDark = Color(0xFF0F3D27);
  static const Color primaryLight = Color(0xFF2D7A55);
  static const Color accentLight = Color(0xFFE6F4ED);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF166534);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFB45309);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFB91C1C);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF1E40AF);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Aliases used by old screens (keep these!) ────────────────────
  static const Color secondary = primaryLight;
  static const Color surface = cardBg;

  // ── Status Colors ─────────────────────────────────────────────────
  static const Color pendingColor = Color(0xFFB45309);
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color inProgressColor = Color(0xFF1E40AF);
  static const Color inProgressBg = Color(0xFFDBEAFE);
  static const Color resolvedColor = Color(0xFF166534);
  static const Color resolvedBg = Color(0xFFDCFCE7);

  // ── Neutrals ──────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F4F0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E0D8);
  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF6B6A64);
  static const Color textMuted = Color(0xFF9B9A94);

  // ── Status Helpers ────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return pendingColor;
      case 'In Progress':
        return inProgressColor;
      case 'Resolved':
        return resolvedColor;
      default:
        return textSecondary;
    }
  }

  static Color statusBgColor(String status) {
    switch (status) {
      case 'Pending':
        return pendingBg;
      case 'In Progress':
        return inProgressBg;
      case 'Resolved':
        return resolvedBg;
      default:
        return border;
    }
  }

  // ── Light Theme ───────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: primaryLight,
          surface: cardBg,
          error: error,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            textStyle:
                GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F2EE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: error),
          ),
          labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
          hintStyle: const TextStyle(color: textMuted, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardBg,
          selectedItemColor: primary,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
        dividerTheme: const DividerThemeData(color: border, space: 1),
        chipTheme: ChipThemeData(
          backgroundColor: cardBg,
          selectedColor: accentLight,
          labelStyle: const TextStyle(color: textSecondary, fontSize: 12),
          side: const BorderSide(color: border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
      );

  // Use light as default (no dark switching)
  static ThemeData get dark => light;
}
