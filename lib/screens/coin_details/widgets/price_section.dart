import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/coin_model.dart';
import '../../../providers/websocket_provider.dart';
import '../../../widgets/price_change_badge.dart';

class PriceSection extends StatelessWidget {
  const PriceSection({
    super.key,
    required this.coin,
    required this.currentPrice,
    this.connectionStatus = WebSocketConnectionStatus.disconnected,
  });

  final CoinModel coin;
  final double currentPrice;
  final WebSocketConnectionStatus connectionStatus;

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercent >= 0;
    final changeColor = isPositive ? AppColors.priceUp : AppColors.priceDown;
    final absChange = currentPrice * (coin.priceChangePercent / 100);
    final sign = isPositive ? '+' : '';
    debugPrint('[UI] currentPrice=${currentPrice.toStringAsFixed(2)}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current price & real-time connection status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  Formatters.formatCurrency(currentPrice),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              _buildConnectionBadge(context, connectionStatus),
            ],
          ),
          const SizedBox(height: 6),

          // Price change and percentage badge row
          Row(
            children: [
              Text(
                '$sign${Formatters.formatCurrency(absChange)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: changeColor,
                ),
              ),
              const SizedBox(width: 8),
              PriceChangeBadge(
                changePercent: coin.priceChangePercent,
              ),
              const SizedBox(width: 8),
              const Text(
                '24h',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBadge(
    BuildContext context,
    WebSocketConnectionStatus status,
  ) {
    final (Color dotColor, String label) = switch (status) {
      WebSocketConnectionStatus.connected => (
          AppColors.priceUp,
          'Live',
        ),
      WebSocketConnectionStatus.connecting => (
          AppColors.primary,
          'Connecting...',
        ),
      WebSocketConnectionStatus.reconnecting => (
          AppColors.primary,
          'Reconnecting...',
        ),
      WebSocketConnectionStatus.error => (
          AppColors.priceDown,
          'Offline',
        ),
      WebSocketConnectionStatus.disconnected => (
          AppColors.textSecondary,
          'Disconnected',
        ),
    };

    final bg = dotColor.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}
