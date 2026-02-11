import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/daily_verse_provider.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/presentation/providers/locale_provider.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';

final _dailyHadithProvider = FutureProvider<HadithModel?>((ref) async {
  final hadithService = ref.watch(hadithServiceProvider);
  return hadithService.getRandomHadith();
});

class DailyInspirationWidget extends ConsumerStatefulWidget {
  const DailyInspirationWidget({super.key});

  @override
  ConsumerState<DailyInspirationWidget> createState() =>
      _DailyInspirationWidgetState();
}

class _DailyInspirationWidgetState
    extends ConsumerState<DailyInspirationWidget> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          height: 320, // Increased height to accommodate longer texts
          child: PageView(
            controller: _pageController,
            children: [
              _VerseCard(l10n: l10n),
              _HadithCard(l10n: l10n),
              _AdhkarCard(l10n: l10n),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: 3,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppTheme.primaryColor,
            dotColor: Colors.white.withValues(alpha: 0.2),
            expansionFactor: 3,
            spacing: 8,
          ),
        ),
      ],
    );
  }
}

class _VerseCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _VerseCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final dailyVerse = ref.watch(dailyVerseProvider);

    final verse = isArabic ? dailyVerse.text : dailyVerse.translation;
    final surah = isArabic
        ? dailyVerse.surah
        : 'Surah ${dailyVerse.surah.replaceAll('سورة ', '')}';

    return _BaseCard(
      title: l10n.verseOfTheDay,
      icon: Icons.auto_awesome,
      color: const Color(0xFFC2185B),
      content: verse,
      subtitle: surah,
      isArabicContent: isArabic,
    );
  }
}

class _HadithCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _HadithCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyHadithAsync = ref.watch(_dailyHadithProvider);

    return dailyHadithAsync.when(
      data: (hadith) {
        if (hadith == null) return const SizedBox.shrink();
        final content = hadith.arab ?? hadith.english ?? '';
        return _BaseCard(
          title: l10n.hadithOfTheDay,
          icon: Icons.format_quote_rounded,
          color: const Color(0xFF9C27B0), // Brand: Hadith Purple
          content: content,
          subtitle: '${hadith.book} - ${hadith.number}',
          isArabicContent: true,
        );
      },
      loading: () => _LoadingCard(title: l10n.hadithOfTheDay),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _AdhkarCard extends ConsumerWidget {
  final AppLocalizations l10n;
  const _AdhkarCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BaseCard(
      title: l10n.adhkarOfTheDay,
      icon: Icons.favorite_rounded,
      color: const Color(0xFF2196F3), // Brand: Adhkar Blue
      content: 'أَلا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      subtitle: 'سورة الرعد - آية ٢٨',
      isArabicContent: true,
    );
  }
}

class _BaseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;
  final String subtitle;
  final bool isArabicContent;

  const _BaseCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
    required this.subtitle,
    required this.isArabicContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        borderRadius: 24,
        blur: 20,
        opacity: 0.1,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    textAlign: TextAlign.center,
                    style: isArabicContent
                        ? GoogleFonts.amiri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          )
                        : GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String title;
  const _LoadingCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        borderRadius: 24,
        blur: 20,
        opacity: 0.1,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: Colors.white10,
            ),
            const Spacer(),
            Container(
              width: 100,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
