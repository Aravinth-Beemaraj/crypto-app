import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Provides themed SnackBar methods using [ScaffoldMessenger].
///
/// All methods clear any currently visible SnackBar before showing a new one
/// to prevent stacking.
class SnackBarHelper {
  SnackBarHelper._();

  // ── Duration Constants ──────────────────────────────────────────────────
  static const _shortDuration = Duration(milliseconds: 1800);
  static const _defaultDuration = Duration(seconds: 3);

  // ── Public API ──────────────────────────────────────────────────────────

  /// Show a success SnackBar (e.g. "Added to Watchlist").
  static void showSuccess(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
  }) {
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: AppColors.priceUp,
      duration: _shortDuration,
    );
  }

  /// Show an informational SnackBar (e.g. "Removed from Watchlist").
  static void showInfo(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline_rounded,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFF37474F),
      duration: _shortDuration,
    );
  }

  /// Show a warning SnackBar (e.g. WebSocket reconnecting).
  static void showWarning(
    BuildContext context,
    String message, {
    IconData icon = Icons.warning_amber_rounded,
  }) {
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: AppColors.primaryDark,
      textColor: const Color(0xFF1E2329),
      duration: _defaultDuration,
    );
  }

  /// Show an error SnackBar (e.g. API failure, network issue).
  static void showError(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline_rounded,
    VoidCallback? onRetry,
  }) {
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: AppColors.priceDown,
      duration: _defaultDuration,
      action: onRetry != null
          ? SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  // ── Internal Builder ────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    // Clear any existing SnackBar first.
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        elevation: 4,
        dismissDirection: DismissDirection.horizontal,
        action: action,
      ),
    );
  }
}
