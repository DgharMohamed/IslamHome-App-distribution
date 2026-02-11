import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';

class AllSectionsScreen extends StatelessWidget {
  const AllSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final categories = [
      _CategoryData(
        title: l10n.quranMushaf,
        icon: Icons.bookmark_rounded,
        color: const Color(0xFFC2185B),
        route: '/quran-text',
      ),
      _CategoryData(
        title: l10n.mushaf,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFAD1457),
        route: '/mushaf',
      ),
      _CategoryData(
        title: l10n.propheticHadith,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF6A1B9A),
        route: '/hadith',
      ),
      _CategoryData(
        title: l10n.azkarDuas,
        icon: Icons.favorite_rounded,
        color: const Color(0xFF1565C0),
        route: '/azkar',
      ),
      _CategoryData(
        title: l10n.tasbeeh,
        icon: Icons.fingerprint_rounded,
        color: const Color(0xFF00838F),
        route: '/tasbeeh',
      ),
      _CategoryData(
        title: l10n.radioLive,
        icon: Icons.radio_rounded,
        color: const Color(0xFF2E7D32),
        route: '/radio',
      ),
      _CategoryData(
        title: l10n.liveTv,
        icon: Icons.live_tv_rounded,
        color: const Color(0xFFE65100),
        route: '/live-tv',
      ),
      _CategoryData(
        title: l10n.videoLibraryTitle,
        icon: Icons.video_library_rounded,
        color: const Color(0xFFBF360C),
        route: '/video',
      ),
      _CategoryData(
        title: l10n.booksLibraryTitle,
        icon: Icons.library_books_rounded,
        color: const Color(0xFF4E342E),
        route: '/books',
      ),
      _CategoryData(
        title: l10n.prayerTimes,
        icon: Icons.access_time_rounded,
        color: const Color(0xFF37474F),
        route: '/prayer-times',
      ),
      _CategoryData(
        title: l10n.downloads,
        icon: Icons.download_for_offline_rounded,
        color: const Color(0xFF00695C),
        route: '/downloads',
      ),
      _CategoryData(
        title: l10n.favorites,
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFFD84315),
        route: '/favorites',
      ),
      _CategoryData(
        title: l10n.settings,
        icon: Icons.settings_rounded,
        color: Colors.grey[700]!,
        route: '/settings',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.exploreSections,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
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
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryData category) {
    return InkWell(
      onTap: () => context.push(category.route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: category.color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 28),
            ),
            Text(
              category.title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _CategoryData({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
