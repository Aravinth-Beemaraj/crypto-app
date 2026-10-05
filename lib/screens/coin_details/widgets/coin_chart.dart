import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/kline_model.dart';

class CoinChart extends StatelessWidget {
  const CoinChart({
    super.key,
    required this.klines,
    required this.timeframe,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.height = 240,
  });

  final List<KlineModel> klines;
  final String timeframe;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: _buildChartContent(context, textSecondary, isDark),
    );
  }

  Widget _buildChartContent(
    BuildContext context,
    Color textSecondary,
    bool isDark,
  ) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 28, color: textSecondary),
            const SizedBox(height: 6),
            Text(
              'Failed to load chart data',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (klines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded, size: 28, color: textSecondary),
            const SizedBox(height: 6),
            Text(
              'No chart data available',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var i = 0; i < klines.length; i++) {
      final price = klines[i].close;
      spots.add(FlSpot(i.toDouble(), price));
      if (price < minY) minY = price;
      if (price > maxY) maxY = price;
    }

    final priceRange = (maxY - minY).abs();
    final padding = priceRange > 0 ? priceRange * 0.08 : minY * 0.05;
    final chartMinY = max(0.0, minY - padding);
    final chartMaxY = maxY + padding;

    final isPriceUp = klines.last.close >= klines.first.close;
    final lineColor = isPriceUp ? AppColors.priceUp : AppColors.priceDown;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (klines.length - 1).toDouble(),
        minY: chartMinY,
        maxY: chartMaxY,
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                isDark ? AppColors.surfaceDark : AppColors.cardLight,
            tooltipBorder: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= klines.length) return null;
                final kline = klines[index];
                final dateStr = Formatters.formatChartTimestamp(
                  kline.openTime,
                  timeframe,
                );

                return LineTooltipItem(
                  '${Formatters.formatCurrency(spot.y)}\n',
                  TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  children: [
                    TextSpan(
                      text: dateStr,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (chartMaxY - chartMinY) / 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            strokeWidth: 0.8,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    Formatters.formatCompact(value),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: max(1, (klines.length / 4)).toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= klines.length) {
                  return const SizedBox.shrink();
                }
                final kline = klines[index];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    Formatters.formatChartTimestamp(
                      kline.openTime,
                      timeframe,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: lineColor,
            barWidth: 2.2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
