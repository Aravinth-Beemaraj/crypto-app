import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/coin_model.dart';
import '../../../widgets/market_stat_card.dart';

class MarketStatsGrid extends StatelessWidget {
  const MarketStatsGrid({
    super.key,
    required this.coin,
  });

  final CoinModel coin;

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercent >= 0;
    final changeColor = isPositive ? AppColors.priceUp : AppColors.priceDown;
    final absChange = coin.price * (coin.priceChangePercent / 100);
    final sign = isPositive ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final crossAxisCount = isWide ? 3 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 2.4 : 2.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  MarketStatCard(
                    label: '24h High',
                    value: Formatters.formatCurrency(coin.high24h),
                  ),
                  MarketStatCard(
                    label: '24h Low',
                    value: Formatters.formatCurrency(coin.low24h),
                  ),
                  MarketStatCard(
                    label: '24h Volume',
                    value:
                        '${Formatters.formatCompact(coin.volume)} ${coin.baseAsset}',
                  ),
                  MarketStatCard(
                    label: 'Quote Volume',
                    value: Formatters.formatVolume(
                      coin.quoteVolume,
                      prefix: '\$',
                    ),
                  ),
                  MarketStatCard(
                    label: '24h Price Change',
                    value: '$sign${Formatters.formatCurrency(absChange)}',
                    valueColor: changeColor,
                  ),
                  MarketStatCard(
                    label: '24h Change %',
                    value: Formatters.formatPercentage(coin.priceChangePercent),
                    valueColor: changeColor,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
