import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/coin_card.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/glass_floating_nav_bar.dart';
import '../../widgets/loading_widgets.dart';
import '../coin_details/coin_details_screen.dart';
import '../statistics/market_statistics_screen.dart';
import '../watchlist/watchlist_screen.dart';
import 'widgets/market_header.dart';
import 'widgets/market_search_bar.dart';
import 'widgets/market_sort_sheet.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[MARKET] screen opened');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketProvider = context.read<MarketProvider>();
      if (marketProvider.status == MarketStatus.initial) {
        marketProvider.loadMarketData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: switch (_currentIndex) {
        1 => const MarketStatisticsScreen(isEmbedded: true),
        2 => const WatchlistScreen(isEmbedded: true),
        _ => _buildMarketContent(context),
      },
      bottomNavigationBar: GlassFloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildMarketContent(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // App Header
          Consumer<MarketProvider>(
            builder: (context, market, _) => MarketHeader(
              onRefresh: () => market.loadMarketData(isRefresh: true),
              onSort: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => MarketSortSheet(
                    selectedOption: market.sortOption,
                    onSelect: market.setSort,
                  ),
                );
              },
            ),
          ),

          // Search Bar
          Consumer<MarketProvider>(
            builder: (context, market, _) => MarketSearchBar(
              searchQuery: market.searchQuery,
              onChanged: market.search,
              onClear: market.clearSearch,
            ),
          ),

          // Main Market List / State Views
          Expanded(
            child: Consumer2<MarketProvider, WatchlistProvider>(
              builder: (context, market, watchlist, _) {
                return switch (market.status) {
                  MarketStatus.initial || MarketStatus.loading =>
                    const LoadingWidgets(),
                  MarketStatus.error => ErrorView(
                      message: market.errorMessage ??
                          'Unable to load market data.',
                      onRetry: () => market.loadMarketData(),
                    ),
                  MarketStatus.empty => EmptyView(
                      title: market.searchQuery.isNotEmpty
                          ? 'No coins found'
                          : (market.favoritesOnly
                              ? 'No favorites yet'
                              : 'No market data available'),
                      message: market.searchQuery.isNotEmpty
                          ? 'No results matching "${market.searchQuery}"'
                          : (market.favoritesOnly
                              ? 'Tap the star icon on any coin to add it to your watchlist.'
                              : 'Check your internet connection and pull to refresh.'),
                      icon: market.favoritesOnly
                          ? Icons.star_border_rounded
                          : Icons.search_off_rounded,
                      actionLabel: market.searchQuery.isNotEmpty
                          ? 'Clear Search'
                          : (market.favoritesOnly
                              ? 'Show All Coins'
                              : 'Refresh'),
                      onAction: market.searchQuery.isNotEmpty
                          ? market.clearSearch
                          : (market.favoritesOnly
                              ? () => market.setFavoritesOnly(false)
                              : () => market.loadMarketData()),
                    ),
                  MarketStatus.success => RefreshIndicator(
                      onRefresh: () => market.loadMarketData(isRefresh: true),
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 6, 0, 100),
                        itemCount: market.coins.length,
                        itemBuilder: (context, index) {
                          final coin = market.coins[index];
                          final isFav = watchlist.isFavorite(coin.symbol);

                          return CoinCard(
                            coin: coin.copyWith(isFavorite: isFav),
                            onTap: () {
                              debugPrint('[UI] Coin selected');
                              debugPrint('[UI] symbol=${coin.symbol}');
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CoinDetailsScreen(
                                    symbol: coin.symbol,
                                  ),
                                ),
                              );
                            },
                            onFavoriteToggle: () {
                              watchlist.toggleFavorite(coin.symbol);
                              market.updateFavoriteStatus(
                                coin.symbol,
                                !isFav,
                              );
                              if (isFav) {
                                SnackBarHelper.showInfo(
                                  context,
                                  '${coin.baseAsset} removed from Watchlist',
                                  icon: Icons.star_outline_rounded,
                                );
                              } else {
                                SnackBarHelper.showSuccess(
                                  context,
                                  '${coin.baseAsset} added to Watchlist',
                                  icon: Icons.star_rounded,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
