import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/coin_model.dart';
import '../../../widgets/favorite_button.dart';

class CoinHeader extends StatelessWidget {
  const CoinHeader({
    super.key,
    required this.coin,
    this.onBack,
    this.onFavoriteToggle,
  });

  final CoinModel coin;
  final VoidCallback? onBack;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final avatarBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),

          // Coin avatar
          ClipOval(
            child: Container(
              width: 36,
              height: 36,
              color: avatarBg,
              child: Image.network(
                Helpers.getCoinIconUrl(coin.baseAsset),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    coin.baseAsset.isNotEmpty ? coin.baseAsset[0] : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Asset title and pair subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  coin.baseAsset,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${coin.baseAsset} / ${coin.quoteAsset}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Favorite toggle button
          FavoriteButton(
            isFavorite: coin.isFavorite,
            onToggle: onFavoriteToggle,
            size: 24,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
