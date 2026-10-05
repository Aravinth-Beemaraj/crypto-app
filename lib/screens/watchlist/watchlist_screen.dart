import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/coin_card.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_widgets.dart';
import '../coin_details/coin_details_screen.dart';

/// Watchlist screen displaying the user's saved cryptocurrencies.
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final body = Consumer2<WatchlistProvider, MarketProvider>(
      builder: (context, watchlist, market, _) {
        final favoriteSymbols = watchlist.favoriteSymbols;

        if (market.isLoading && favoriteSymbols.isNotEmpty) {
          return const LoadingWidgets();
        }

        final favoriteCoins = market.allCoins
            .where((c) => favoriteSymbols.contains(c.symbol.toUpperCase()))
            .toList();

        if (favoriteCoins.isEmpty) {
          return EmptyView(
            title: 'Your Watchlist is Empty',
            message:
                'Tap the star icon on any coin in the Market screen to add it to your watchlist.',
            icon: Icons.star_border_rounded,
            actionLabel: 'Explore Market',
            onAction: () => Navigator.of(context).maybePop(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          itemCount: favoriteCoins.length,
          itemBuilder: (context, index) {
            final coin = favoriteCoins[index];
            return CoinCard(
              coin: coin.copyWith(isFavorite: true),
              onTap: () {
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
                market.updateFavoriteStatus(coin.symbol, false);
                SnackBarHelper.showInfo(
                  context,
                  '${coin.baseAsset} removed from Watchlist',
                  icon: Icons.star_outline_rounded,
                );
              },
            );
          },
        );
      },
    );

    if (isEmbedded) {
      return SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Watchlist',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your saved cryptocurrencies & price tracking',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      ),
      body: body,
    );
  }
}
