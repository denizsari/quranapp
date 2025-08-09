import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF2563EB); // blue-600
  const success = Color(0xFF059669); // emerald-600
  const warning = Color(0xFFF59E0B); // amber-500
  const error = Color(0xFFDC2626); // red-600

  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      secondary: success,
      error: error,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    // Minimal card styling (removed to avoid version mismatch errors)
    extensions: <ThemeExtension<dynamic>>[
      const AppSemanticColors(
          primary: primary, success: success, warning: warning, error: error),
    ],
  );
}

class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;
  const AppSemanticColors(
      {required this.primary,
      required this.success,
      required this.warning,
      required this.error});

  @override
  ThemeExtension<AppSemanticColors> copyWith(
      {Color? primary, Color? success, Color? warning, Color? error}) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<AppSemanticColors> lerp(
      ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
