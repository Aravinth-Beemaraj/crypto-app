import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({
    super.key,
    required this.selectedTimeframe,
    required this.onSelect,
    this.isLoading = false,
  });

  final String selectedTimeframe;
  final ValueChanged<String> onSelect;
  final bool isLoading;

  static const List<String> timeframes = ['1H', '4H', '1D', '7D'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(10),
          border: isDark ? null : Border.all(color: AppColors.borderLight, width: 0.8),
        ),
        child: Row(
          children: timeframes.map((tf) {
            final isSelected =
                selectedTimeframe.toUpperCase() == tf.toUpperCase();

            return Expanded(
              child: GestureDetector(
                onTap: isLoading ? null : () => onSelect(tf),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tf,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.black : textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
