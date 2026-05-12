import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';

/// Gradient background that adapts to dark mode.
/// Wrap the Scaffold body with this instead of the raw gradient Container.
/// Normal: blue-dark | Dark mode: AMOLED near-black
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({required this.child, super.key});

  static const _normalColors = [Color(0xFF004E92), Color(0xFF000428)];
  static const _darkColors = [Color(0xFF0B0F1E), Color(0xFF000000)];

  static Color scaffoldColor(bool isDark) =>
      isDark ? const Color(0xFF000000) : const Color(0xFF000428);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final colors = isDark ? _darkColors : _normalColors;
    final orbColor =
        isDark ? const Color(0xFF1A1F3A) : const Color(0xFF004E92);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    orbColor.withValues(alpha: isDark ? 0.3 : 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.02 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
