import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/coin_model.dart';
import '../../providers/coin_details_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/websocket_provider.dart';
import '../../widgets/error_view.dart';
import 'widgets/coin_chart.dart';
import 'widgets/coin_header.dart';
import 'widgets/market_stats_grid.dart';
import 'widgets/price_section.dart';
import 'widgets/timeframe_selector.dart';

class CoinDetailsScreen extends StatefulWidget {
  const CoinDetailsScreen({
    super.key,
    required this.symbol,
    this.initialCoin,
  });

  final String symbol;
  final CoinModel? initialCoin;

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen> {
  WebSocketProvider? _wsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _wsProvider = Provider.of<WebSocketProvider>(context, listen: false);
    } catch (_) {
      _wsProvider = null;
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[LIFECYCLE] CoinDetailsScreen initState');
    debugPrint('[LIFECYCLE] symbol=${widget.symbol}');
    debugPrint('[LIFECYCLE] CoinDetailsScreen INIT');
    debugPrint('[WS] CONNECT');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detailsProvider = context.read<CoinDetailsProvider>();
      detailsProvider.loadCoinDetails(
        widget.symbol,
        initialCoin: widget.initialCoin,
      );

      _wsProvider?.connect(
        widget.symbol,
        onPriceUpdate: (price) {
          if (mounted) {
            detailsProvider.updateLivePrice(price);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    debugPrint('[LIFECYCLE] CoinDetailsScreen DISPOSE');
    debugPrint('[WS] disconnect requested');
    _wsProvider?.disconnect();
    super.dispose();
  }

  WebSocketConnectionStatus _getWsStatus(BuildContext context) {
    try {
      final ws = Provider.of<WebSocketProvider>(context);
      return ws.status;
    } catch (_) {
      return WebSocketConnectionStatus.disconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<CoinDetailsProvider, WatchlistProvider>(
          builder: (context, provider, watchlist, _) {
            final coin = provider.coin;

            // Full screen loading when no coin data is available yet
            if (provider.isLoading && coin == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            // Full screen error when initial coin fetch fails
            if (provider.errorMessage != null && coin == null) {
              return ErrorView(
                title: 'Failed to load ${widget.symbol}',
                message: provider.errorMessage!,
                onRetry: () => provider.loadCoinDetails(
                  widget.symbol,
                  initialCoin: widget.initialCoin,
                ),
              );
            }

            if (coin == null) {
              return const Center(
                child: Text('No coin data available'),
              );
            }

            final isFav = watchlist.isFavorite(coin.symbol);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.loadCoinDetails(widget.symbol),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back navigation and favorite action
                    CoinHeader(
                      coin: coin.copyWith(isFavorite: isFav),
                      onFavoriteToggle: () {
                        watchlist.toggleFavorite(coin.symbol);
                        provider.updateFavorite(!isFav);
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
                    ),

                    // Price Section with 24h change and live WebSocket status
                    Builder(
                      builder: (context) {
                        final wsStatus = _getWsStatus(context);
                        return PriceSection(
                          coin: coin,
                          currentPrice: provider.currentPrice,
                          connectionStatus: wsStatus,
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    // Timeframe Selector
                    TimeframeSelector(
                      selectedTimeframe: provider.selectedTimeframe,
                      isLoading: provider.isChartLoading,
                      onSelect: provider.setTimeframe,
                    ),

                    // Interactive Kline Chart
                    CoinChart(
                      klines: provider.klines,
                      timeframe: provider.selectedTimeframe,
                      isLoading: provider.isChartLoading,
                      errorMessage: provider.chartErrorMessage,
                      onRetry: () =>
                          provider.setTimeframe(provider.selectedTimeframe),
                    ),

                    const SizedBox(height: 12),

                    // 24h Market Statistics Grid
                    MarketStatsGrid(coin: coin),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
