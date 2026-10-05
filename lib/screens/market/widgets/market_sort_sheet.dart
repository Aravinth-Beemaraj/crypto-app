import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/market_provider.dart';

class MarketSortSheet extends StatelessWidget {
  const MarketSortSheet({
    super.key,
    required this.selectedOption,
    required this.onSelect,
  });

  final MarketSortOption selectedOption;
  final ValueChanged<MarketSortOption> onSelect;

  static const List<_SortItem> _items = [
    _SortItem(
      option: MarketSortOption.volumeDesc,
      label: '24h Volume: High to Low',
      icon: Icons.bar_chart_rounded,
    ),
    _SortItem(
      option: MarketSortOption.priceDesc,
      label: 'Price: High to Low',
      icon: Icons.arrow_downward_rounded,
    ),
    _SortItem(
      option: MarketSortOption.priceAsc,
      label: 'Price: Low to High',
      icon: Icons.arrow_upward_rounded,
    ),
    _SortItem(
      option: MarketSortOption.changeDesc,
      label: 'Top Gainers (24h Change)',
      icon: Icons.trending_up_rounded,
    ),
    _SortItem(
      option: MarketSortOption.changeAsc,
      label: 'Top Losers (24h Change)',
      icon: Icons.trending_down_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final handleColor = isDark
        ? AppColors.surfaceDark
        : AppColors.dividerLight;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sort Markets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ..._items.map((item) {
              final isSelected = item.option == selectedOption;
              return ListTile(
                leading: Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : textSecondary,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)
                        : textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSelect(item.option);
                  Navigator.of(context).pop();
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SortItem {
  const _SortItem({
    required this.option,
    required this.label,
    required this.icon,
  });

  final MarketSortOption option;
  final String label;
  final IconData icon;
}
