import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand
  static const Color primary = Color(0xFFF0B90B);
  static const Color primaryDark = Color(0xFFD4A30A);
  static const Color primaryLight = Color(0xFFFCD535);

  // ── Dark Theme Colors
  static const Color scaffoldDark = Color(0xFF0B0E11);
  static const Color cardDark = Color(0xFF1E2329);
  static const Color surfaceDark = Color(0xFF2B3139);
  static const Color inputDark = Color(0xFF2B3139);

  static const Color textPrimaryDark = Color(0xFFEAECEF);
  static const Color textSecondaryDark = Color(0xFF848E9C);
  static const Color textHintDark = Color(0xFF5E6673);
  static const Color dividerDark = Color(0xFF2B3139);
  static const Color borderDark = Color(0xFF2B3139);

  // ── Light Theme Colors
  static const Color scaffoldLight = Color(0xFFF5F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFEEF2F6);
  static const Color inputLight = Color(0xFFEEF2F6);

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textHintLight = Color(0xFF9CA3AF);
  static const Color dividerLight = Color(0xFFE6EBF1);
  static const Color borderLight = Color(0xFFE6EBF1);

  // ── Semantic Market Colors
  static const Color priceUp = Color(0xFF0ECB81);
  static const Color priceDown = Color(0xFFF6465D);
  static const Color priceUpBackground = Color(0x1F0ECB81);
  static const Color priceDownBackground = Color(0x1FF6465D);
  static const Color priceUpBackgroundLight = Color(0xFFE8F9F1);
  static const Color priceDownBackgroundLight = Color(0xFFFEECEE);

  // ── Shimmer & Skeleton
  static const Color shimmerBaseDark = Color(0xFF1E2329);
  static const Color shimmerHighlightDark = Color(0xFF2B3139);
  static const Color shimmerBaseLight = Color(0xFFE6EBF1);
  static const Color shimmerHighlightLight = Color(0xFFF5F7FA);

  // Backward-compatible aliases
  static const Color scaffoldBackground = scaffoldDark;
  static const Color cardBackground = cardDark;
  static const Color surfaceBackground = surfaceDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textHint = textHintDark;
  static const Color divider = dividerDark;
  static const Color error = priceDown;
}
