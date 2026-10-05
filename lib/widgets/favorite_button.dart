import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    this.onToggle,
    this.size = 22.0,
  });

  final bool isFavorite;
  final VoidCallback? onToggle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return IconButton(
      iconSize: size,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      splashRadius: 20,
      icon: Icon(
        isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
        color: isFavorite ? AppColors.primary : defaultColor,
      ),
      onPressed: onToggle,
    );
  }
}
