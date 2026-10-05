import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class GlassFloatingNavBar extends StatelessWidget {
  const GlassFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassColor = isDark
        ? AppColors.cardDark.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.95);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.borderLight;

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.05);

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: glassColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: BottomNavigationBar(
                      currentIndex: currentIndex,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      selectedFontSize: 11,
                      unselectedFontSize: 11,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      type: BottomNavigationBarType.fixed,
                      onTap: onTap,
                      items: [
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(
                            icon: Icons.candlestick_chart_outlined,
                            isActive: false,
                            isDark: isDark,
                          ),
                          activeIcon: _buildNavIcon(
                            icon: Icons.candlestick_chart_rounded,
                            isActive: true,
                            isDark: isDark,
                          ),
                          label: 'Markets',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(
                            icon: Icons.analytics_outlined,
                            isActive: false,
                            isDark: isDark,
                          ),
                          activeIcon: _buildNavIcon(
                            icon: Icons.analytics_rounded,
                            isActive: true,
                            isDark: isDark,
                          ),
                          label: 'Statistics',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(
                            icon: Icons.star_outline_rounded,
                            isActive: false,
                            isDark: isDark,
                          ),
                          activeIcon: _buildNavIcon(
                            icon: Icons.star_rounded,
                            isActive: true,
                            isDark: isDark,
                          ),
                          label: 'Watchlist',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required bool isActive,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: 20,
        color: isActive
            ? AppColors.primary
            : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
      ),
    );
  }
}
