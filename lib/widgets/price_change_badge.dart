import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

class PriceChangeBadge extends StatelessWidget {
  const PriceChangeBadge({
    super.key,
    required this.changePercent,
    this.includeSign = true,
  });

  final double changePercent;
  final bool includeSign;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = changePercent >= 0;
    final color = isPositive ? AppColors.priceUp : AppColors.priceDown;
    final bgColor = isPositive
        ? (isDark ? AppColors.priceUpBackground : const Color(0xFFE8F9F1))
        : (isDark ? AppColors.priceDownBackground : const Color(0xFFFEECEE));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 16,
            color: color,
          ),
          Text(
            Formatters.formatPercentage(
              changePercent,
              includeSign: includeSign,
            ),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
