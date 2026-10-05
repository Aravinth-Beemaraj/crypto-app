import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../models/coin_model.dart';
import '../../providers/market_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widgets.dart';
import '../../widgets/price_change_badge.dart';
import '../coin_details/coin_details_screen.dart';

/// Dedicated Market Statistics screen.
///
/// Computes comprehensive 24h market metrics, breadth indicators,
/// and leaderboards directly from real Binance market data already loaded
/// in [MarketProvider], with zero redundant API calls.
class MarketStatisticsScreen extends StatefulWidget {
  const MarketStatisticsScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<MarketStatisticsScreen> createState() => _MarketStatisticsScreenState();
}

class _MarketStatisticsScreenState extends State<MarketStatisticsScreen> {
  int _selectedLeaderboardIndex = 0; // 0: Gainers, 1: Losers, 2: Volume

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Consumer<MarketProvider>(
      builder: (context, market, _) {
        if (market.isLoading && market.allCoins.isEmpty) {
          return const LoadingWidgets();
        }

        if (market.status == MarketStatus.error && market.allCoins.isEmpty) {
          return ErrorView(
            message: market.errorMessage ?? 'Unable to load market statistics.',
            onRetry: () => market.loadMarketData(),
          );
        }

        if (market.allCoins.isEmpty) {
          return EmptyView(
            title: 'No Statistics Available',
            message: 'Check your internet connection and pull to refresh.',
            onAction: () => market.loadMarketData(),
          );
        }

        final coins = market.allCoins;

        // 1. Total Volume
        final totalVolume = coins.fold<double>(
          0.0,
          (sum, c) => sum + c.quoteVolume,
        );

        // 2. Market Sentiment (Gainers vs Losers)
        final gainers = coins.where((c) => c.priceChangePercent > 0).toList()
          ..sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));

        final losers = coins.where((c) => c.priceChangePercent < 0).toList()
          ..sort((a, b) => a.priceChangePercent.compareTo(b.priceChangePercent));

        final volumeSorted = List<CoinModel>.from(coins)
          ..sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));

        final totalCount = coins.length;
        final gainersCount = gainers.length;
        final losersCount = losers.length;
        final neutralCount = totalCount - gainersCount - losersCount;
        final gainerRatio = totalCount > 0 ? gainersCount / totalCount : 0.5;

        // 3. Average Change
        final avgChange = totalCount > 0
            ? coins.fold<double>(0.0, (sum, c) => sum + c.priceChangePercent) /
                totalCount
            : 0.0;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => market.loadMarketData(isRefresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              // Screen Title Header (if embedded)
              if (widget.isEmbedded) ...[
                Text(
                  'Market Statistics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-time 24h Binance market breadth & volume',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Key Market Metric Cards (2x2 Grid) ───────────────
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: '24h Total Volume',
                      value: '\$${Formatters.formatCompact(totalVolume)}',
                      subtitle: 'Across USDT pairs',
                      icon: Icons.pie_chart_rounded,
                      iconColor: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Active Markets',
                      value: '$totalCount Pairs',
                      subtitle: 'Binance Spot',
                      icon: Icons.candlestick_chart_rounded,
                      iconColor: Colors.blueAccent,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 0, height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Market Sentiment',
                      value: '${(gainerRatio * 100).toStringAsFixed(0)}% Bullish',
                      subtitle: '$gainersCount Up / $losersCount Down',
                      icon: Icons.trending_up_rounded,
                      iconColor: gainerRatio >= 0.5
                          ? AppColors.priceUp
                          : AppColors.priceDown,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: '24h Avg Change',
                      value:
                          '${avgChange >= 0 ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                      subtitle: 'Market average',
                      icon: Icons.insights_rounded,
                      iconColor: avgChange >= 0
                          ? AppColors.priceUp
                          : AppColors.priceDown,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Market Breadth Visual Ratio Bar ──────────────────
              _buildBreadthBar(
                context,
                gainers: gainersCount,
                losers: losersCount,
                neutral: neutralCount,
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // ── Leaderboard Section ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Leaders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Top 5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Segment Selector
              _buildLeaderboardSelector(isDark),

              const SizedBox(height: 12),

              // Leaderboard Coin List
              ..._buildSelectedLeaderboard(
                gainers: gainers.take(5).toList(),
                losers: losers.take(5).toList(),
                volume: volumeSorted.take(5).toList(),
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );

    if (widget.isEmbedded) {
      return SafeArea(
        bottom: false,
        child: SizedBox.expand(
          child: content,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      ),
      body: content,
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadthBar(
    BuildContext context, {
    required int gainers,
    required int losers,
    required int neutral,
    required bool isDark,
  }) {
    final total = (gainers + losers + neutral);
    final gainerFlex = total > 0 ? (gainers / total * 100).round() : 50;
    final loserFlex = total > 0 ? (losers / total * 100).round() : 50;
    final neutralFlex = 100 - gainerFlex - loserFlex;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.priceUp,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$gainers Gainers',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.priceUp,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '$losers Losers',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.priceDown,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.priceDown,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: gainerFlex > 0 ? gainerFlex : 1,
                    child: Container(color: AppColors.priceUp),
                  ),
                  if (neutralFlex > 0)
                    Expanded(
                      flex: neutralFlex,
                      child: Container(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                  Expanded(
                    flex: loserFlex > 0 ? loserFlex : 1,
                    child: Container(color: AppColors.priceDown),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSelector(bool isDark) {
    final chipBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'Top Gainers', Icons.trending_up_rounded, isDark),
          _buildTabButton(1, 'Top Losers', Icons.trending_down_rounded, isDark),
          _buildTabButton(2, '24h Volume', Icons.bar_chart_rounded, isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedLeaderboardIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLeaderboardIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.cardDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectedLeaderboard({
    required List<CoinModel> gainers,
    required List<CoinModel> losers,
    required List<CoinModel> volume,
    required bool isDark,
  }) {
    final list = switch (_selectedLeaderboardIndex) {
      0 => gainers,
      1 => losers,
      _ => volume,
    };

    if (list.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No coins found in this category',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ),
      ];
    }

    return list.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final coin = entry.value;
      return _buildLeaderboardTile(rank, coin, isDark);
    }).toList();
  }

  Widget _buildLeaderboardTile(int rank, CoinModel coin, bool isDark) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CoinDetailsScreen(
                  symbol: coin.symbol,
                  initialCoin: coin,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Rank number
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : (isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: rank == 1 ? AppColors.primary : textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Coin icon
                ClipOval(
                  child: Container(
                    width: 34,
                    height: 34,
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    child: Image.network(
                      Helpers.getCoinIconUrl(coin.baseAsset),
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          coin.baseAsset.isNotEmpty ? coin.baseAsset[0] : '?',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and volume
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.baseAsset,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vol \$${Formatters.formatCompact(coin.quoteVolume)}',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),

                // Price & percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(coin.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PriceChangeBadge(
                      changePercent: coin.priceChangePercent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
