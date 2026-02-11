import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/mood_provider.dart';

class SpiritualMoodsWidget extends ConsumerWidget {
  const SpiritualMoodsWidget({super.key});

  String _getLocalizedValue(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'surahSharh':
        return l10n.surahSharh;
      case 'descAnxious':
        return l10n.descAnxious;
      case 'actionReadSurah':
        return l10n.actionReadSurah;
      case 'allahIsNear':
        return l10n.allahIsNear;
      case 'actionGoToAzkar':
        return l10n.actionGoToAzkar;
      case 'surahYusuf':
        return l10n.surahYusuf;
      case 'descSad':
        return l10n.descSad;
      case 'surahDuha':
        return l10n.surahDuha;
      case 'descDuha':
        return l10n.descDuha;
      case 'surahRahman':
        return l10n.surahRahman;
      case 'descHappy':
        return l10n.descHappy;
      case 'startTasbeeh':
        return l10n.startTasbeeh;
      case 'rememberAllah':
        return l10n.rememberAllah;
      case 'descHappyDhikr':
        return l10n.descHappyDhikr;
      case 'surahFatiha':
        return l10n.surahFatiha;
      case 'descLost':
        return l10n.descLost;
      case 'actionGoToDua':
        return l10n.actionGoToDua;
      case 'descLostDhikr':
        return l10n.descLostDhikr;
      case 'sleepAzkar':
        return l10n.sleepAzkar;
      case 'descTired':
        return l10n.descTired;
      case 'rewardForTired':
        return l10n.rewardForTired;
      case 'descTiredDhikr':
        return l10n.descTiredDhikr;
      default:
        return key;
    }
  }

  void _showRecommendation(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> mood,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final rec = ref.read(moodRecommendationProvider(mood['id'] as String));
    final moodDisplay = mood['display'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              mood['icon'] as IconData,
              color: mood['color'] as Color,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.becauseYouFeel(moodDisplay),
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              _getLocalizedValue(context, rec.titleKey),
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getLocalizedValue(context, rec.descKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(rec.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _getLocalizedValue(context, rec.actionKey),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final moods = [
      {
        'id': 'anxious',
        'display': l10n.moodAnxious,
        'icon': Icons.sentiment_neutral_rounded,
        'color': Colors.orange,
      },
      {
        'id': 'sad',
        'display': l10n.moodSad,
        'icon': Icons.sentiment_dissatisfied_rounded,
        'color': Colors.blue,
      },
      {
        'id': 'happy',
        'display': l10n.moodHappy,
        'icon': Icons.sentiment_very_satisfied_rounded,
        'color': Colors.green,
      },
      {
        'id': 'lost',
        'display': l10n.moodLost,
        'icon': Icons.explore_rounded,
        'color': Colors.purple,
      },
      {
        'id': 'tired',
        'display': l10n.moodTired,
        'icon': Icons.battery_alert_rounded,
        'color': Colors.red,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.howDoYouFeel,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            padding: const EdgeInsets.only(bottom: 10),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return InkWell(
                onTap: () => _showRecommendation(context, ref, mood),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: (mood['color'] as Color).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (mood['color'] as Color).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mood['icon'] as IconData,
                        color: mood['color'] as Color,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood['display'] as String,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
