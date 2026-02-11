import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

class FeatureGridWidget extends StatelessWidget {
  const FeatureGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final features = [
      _FeatureItem(
        title: 'القرآن الكريم',
        subtitle: 'تفسير، قراءة وترجمة',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFC2185B),
        route: '/quran-text',
      ),
      _FeatureItem(
        title: l10n.azkarDuas,
        icon: Icons.import_contacts_rounded,
        color: const Color(0xFF1565C0),
        route: '/azkar',
      ),
      _FeatureItem(
        title: l10n.propheticHadith,
        icon: Icons.history_edu_rounded,
        color: const Color(0xFF6A1B9A),
        route: '/hadith',
      ),
      _FeatureItem(
        title: l10n.radioLive,
        icon: Icons.radio_rounded,
        color: const Color(0xFF2E7D32),
        route: '/radio',
      ),
      _FeatureItem(
        title: l10n.liveTv,
        icon: Icons.live_tv_rounded,
        color: const Color(0xFFE65100),
        route: '/live-tv',
      ),
      _FeatureItem(
        title: l10n.videoLibraryTitle,
        icon: Icons.video_library_rounded,
        color: const Color(0xFFBF360C),
        route: '/video',
      ),
      _FeatureItem(
        title: l10n.booksLibraryTitle,
        icon: Icons.library_books_rounded,
        color: const Color(0xFF4E342E),
        route: '/books',
      ),
      _FeatureItem(
        title: l10n.prayerTimes,
        icon: Icons.access_time_filled_rounded,
        color: const Color(0xFFF57F17),
        route: '/prayer-times',
      ),
      _FeatureItem(
        title: l10n.qibla,
        icon: Icons.compass_calibration_rounded,
        color: const Color(0xFF00838F),
        route: '/qibla',
      ),
      _FeatureItem(
        title: l10n.tasbeeh,
        icon: Icons.touch_app_rounded,
        color: const Color(0xFF5D4037),
        route: '/tasbeeh',
      ),
      _FeatureItem(
        title: l10n.favorites,
        icon: Icons.favorite_rounded,
        color: const Color(0xFFD81B60),
        route: '/favorites',
      ),
      _FeatureItem(
        title: l10n.downloads,
        icon: Icons.download_for_offline_rounded,
        color: const Color(0xFF00695C),
        route: '/downloads',
      ),
      _FeatureItem(
        title: l10n.settings,
        icon: Icons.settings_rounded,
        color: const Color(0xFF455A64),
        route: '/settings',
      ),
    ];

    return SizedBox(
      height: 140, // Increased height for subtitles
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildFeatureCard(context, features[index]);
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem item) {
    return InkWell(
      onTap: item.route != null ? () => context.push(item.route!) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 130, // Wider for text and subtitle
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
            if (item.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                item.subtitle!,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.5),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? route;

  _FeatureItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.route,
  });
}
