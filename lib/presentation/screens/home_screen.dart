import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/presentation/widgets/daily_inspiration_widget.dart';
import 'package:islamic_library_flutter/presentation/widgets/spiritual_moods_widget.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

import 'package:islamic_library_flutter/presentation/widgets/home_header_widget.dart';
import 'package:islamic_library_flutter/presentation/widgets/feature_grid_widget.dart';
import 'package:islamic_library_flutter/presentation/widgets/smart_khatma_widget.dart';
import 'package:islamic_library_flutter/presentation/providers/khatma_provider.dart';
import 'package:islamic_library_flutter/core/utils/quran_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🏠 HomeScreen: build started');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow header to go behind status bar
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Premium Header
            const HomeHeaderWidget(),

            // 2. Main Content
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 100), // Spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spiritual Moods - MOVED TO TOP
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SpiritualMoodsWidget(),
                  ),

                  const SizedBox(height: 32),

                  // Feature Grid
                  const FeatureGridWidget(),

                  const SizedBox(height: 32),

                  // Reading Progress (Dynamic)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle(
                      context,
                      l10n.khatmaProgress,
                      l10n,
                      onPressed: () {
                        final khatmaState = ref.read(khatmaProvider);
                        final surahNum = QuranUtils.getSurahNumberByPage(
                          khatmaState.currentPage,
                        );
                        context.push('/quran-text?surah=$surahNum');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SmartKhatmaWidget(),
                  ),

                  const SizedBox(height: 32),

                  // Daily Inspiration Carousel
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: DailyInspirationWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    AppLocalizations l10n, {
    VoidCallback? onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (onPressed != null)
          TextButton(
            onPressed: onPressed,
            child: Text(
              l10n.viewAll,
              style: GoogleFonts.cairo(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
