import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/market_provider.dart';
import 'market_sort_sheet.dart';

class MarketFilterBar extends StatelessWidget {
  const MarketFilterBar({
    super.key,
    required this.selectedQuoteAsset,
    required this.favoritesOnly,
    required this.selectedSort,
    required this.onQuoteAssetChanged,
    required this.onFavoritesOnlyChanged,
    required this.onSortChanged,
  });

  final String selectedQuoteAsset;
  final bool favoritesOnly;
  final MarketSortOption selectedSort;
  final ValueChanged<String> onQuoteAssetChanged;
  final ValueChanged<bool> onFavoritesOnlyChanged;
  final ValueChanged<MarketSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All USDT',
                    isSelected: !favoritesOnly,
                    onTap: () => onFavoritesOnlyChanged(false),
                    chipBg: chipBg,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Watchlist',
                    icon: Icons.star_rounded,
                    isSelected: favoritesOnly,
                    onTap: () => onFavoritesOnlyChanged(true),
                    chipBg: chipBg,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Sort button
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => MarketSortSheet(
                  selectedOption: selectedSort,
                  onSelect: onSortChanged,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.chipBg,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color chipBg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isSelected
        ? Border.all(color: AppColors.primary, width: 0.8)
        : Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : chipBg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.black
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.black
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
