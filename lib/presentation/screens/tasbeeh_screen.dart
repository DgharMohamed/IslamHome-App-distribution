import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/presentation/widgets/aurora_background.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _totalCount = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _counter++;
      _totalCount++;
    });
    _animationController.forward().then((_) => _animationController.reverse());
    HapticFeedback.lightImpact();
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: AuroraBackground(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  context.canPop()
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        )
                      : Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => GlobalScaffoldService.openDrawer(),
                          ),
                        ),
                  Text(
                    l10n.electronicTasbeeh,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),
            const Spacer(),

            // Total Stats
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Text(
                    l10n.totalTasbeehs,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    '$_totalCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Main Counter
            GestureDetector(
              onTap: _increment,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: GlassContainer(
                    borderRadius: 125,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Text(
                        '$_counter',
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              l10n.tapToCount,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white38,
                fontFamily: 'Cairo',
              ),
            ),

            const Spacer(),

            // Actions
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(Icons.refresh, l10n.reset, _reset),
                  const SizedBox(width: 40),
                  _buildActionButton(Icons.history, l10n.history, () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: GlassContainer(
            borderRadius: 50,
            padding: const EdgeInsets.all(15),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
