import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Premium Branding Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.appTitle,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Spiritual Journey & Library',
                  style: GoogleFonts.tajawal(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader(l10n.mainMenu),
                _buildDrawerItem(Icons.home_filled, l10n.home, '/', context),
                _buildDrawerItem(
                  Icons.search_rounded,
                  l10n.globalSearch,
                  '/search',
                  context,
                ),
                _buildDrawerItem(
                  Icons.people_alt_rounded,
                  l10n.reciters,
                  '/all-reciters',
                  context,
                ),

                const SizedBox(height: 20),
                _buildSectionHeader(l10n.readingMedia),
                _buildDrawerItem(
                  Icons.auto_stories_rounded,
                  l10n.mushaf,
                  '/mushaf',
                  context,
                ),
                _buildDrawerItem(
                  Icons.history_edu_rounded,
                  l10n.hadith,
                  '/hadith',
                  context,
                ),
                _buildDrawerItem(
                  Icons.import_contacts_rounded,
                  l10n.azkarDuas,
                  '/azkar',
                  context,
                ),
                _buildDrawerItem(
                  Icons.radio_rounded,
                  l10n.radio,
                  '/radio',
                  context,
                ),
                _buildDrawerItem(
                  Icons.live_tv_rounded,
                  l10n.liveTv,
                  '/live-tv',
                  context,
                ),
                _buildDrawerItem(
                  Icons.video_collection_rounded,
                  l10n.videos,
                  '/video',
                  context,
                ),
                _buildDrawerItem(
                  Icons.library_books_rounded,
                  l10n.books,
                  '/books',
                  context,
                ),

                const SizedBox(height: 20),
                _buildSectionHeader(l10n.utilitiesTools),
                _buildDrawerItem(
                  Icons.access_time_filled_rounded,
                  l10n.prayerTimes,
                  '/prayer-times',
                  context,
                ),
                _buildDrawerItem(
                  Icons.touch_app_rounded,
                  l10n.tasbeeh,
                  '/tasbeeh',
                  context,
                ),
                _buildDrawerItem(
                  Icons.download_for_offline_rounded,
                  l10n.downloads,
                  '/downloads',
                  context,
                ),
                _buildDrawerItem(
                  Icons.favorite_rounded,
                  l10n.favorites,
                  '/favorites',
                  context,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10),
                ),

                _buildDrawerItem(
                  Icons.bookmark_rounded,
                  l10n.lastReadMushaf(
                    Hive.box(
                      'settings',
                    ).get('last_mushaf_page', defaultValue: 1),
                  ),
                  'bookmark',
                  context,
                ),
                _buildDrawerItem(
                  Icons.settings_outlined,
                  l10n.settings,
                  '/settings',
                  context,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cairo(
          color: Colors.white24,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    String route,
    BuildContext context,
  ) {
    final bool isSelected = GoRouterState.of(context).uri.toString() == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2))
            : null,
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.white54,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        onTap: () {
          context.pop(); // Close drawer
          if (route == 'bookmark') {
            final box = Hive.box('settings');
            final lastPage = box.get('last_mushaf_page');
            if (lastPage != null) {
              context.push('/mushaf?page=$lastPage');
            } else {
              context.push('/mushaf');
            }
          } else {
            context.push(route);
          }
        },
      ),
    );
  }
}
