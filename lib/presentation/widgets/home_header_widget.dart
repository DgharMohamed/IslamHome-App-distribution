import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_library_flutter/presentation/providers/prayer_notifier.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/presentation/widgets/home_header_painters.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';

class HomeHeaderWidget extends ConsumerStatefulWidget {
  const HomeHeaderWidget({super.key});

  @override
  ConsumerState<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends ConsumerState<HomeHeaderWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  String _timeUntilNext = "";
  String _nextPrayerName = "";
  late AnimationController _animationController;
  final List<Star> _stars = Star.generate(50);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateNextPrayer();
      }
    });
  }

  void _calculateNextPrayer() {
    try {
      final prayerState = ref.read(prayerNotifierProvider);
      final l10n = AppLocalizations.of(context)!;

      prayerState.timings.whenData((data) {
        if (data == null) return;

        final now = DateTime.now();
        final prayerTimes = data.timings;
        final names = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        DateTime? nextTime;
        String nextName = '';

        for (var name in names) {
          final timeStr = prayerTimes[name];
          if (timeStr == null) continue;

          final parts = timeStr.split(':');
          if (parts.length < 2) continue;

          final pTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

          if (pTime.isAfter(now)) {
            nextTime = pTime;
            nextName = _getLocalizedName(name, l10n);
            break;
          }
        }

        if (nextTime == null) {
          final fajrStr = prayerTimes['Fajr']!;
          final parts = fajrStr.split(':');
          nextTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          nextName = l10n.fajr;
        }

        final remaining = nextTime.difference(now);
        final remStr = _formatDuration(remaining);

        if (mounted &&
            (_nextPrayerName != nextName || _timeUntilNext != remStr)) {
          setState(() {
            _nextPrayerName = nextName;
            _timeUntilNext = remStr;
          });
        }
      });
    } catch (e) {
      debugPrint('Error in HomeHeader timer: $e');
    }
  }

  String _getLocalizedName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Fajr':
        return l10n.fajr;
      case 'Sunrise':
        return l10n.sunrise;
      case 'Dhuhr':
        return l10n.dhuhr;
      case 'Asr':
        return l10n.asr;
      case 'Maghrib':
        return l10n.maghrib;
      case 'Isha':
        return l10n.isha;
      default:
        return key;
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    final hijri = HijriCalendar.now();
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', l10n.localeName).format(now);
    final gregorianDate = DateFormat(
      'd MMMM yyyy',
      l10n.localeName,
    ).format(now);

    final currentCityDisplay = '${prayerState.city}, ${prayerState.country}';

    // Dynamic Theme Logic
    final hour = now.hour;
    List<Color> gradientColors;
    bool showStars = false;
    Color mosqueColor;

    if (hour >= 5 && hour < 8) {
      // Dawn
      gradientColors = [const Color(0xFF1A237E), const Color(0xFFE91E63)];
      mosqueColor = const Color(0xFF10153F);
    } else if (hour >= 8 && hour < 17) {
      // Day
      gradientColors = [const Color(0xFF1E88E5), const Color(0xFF4FC3F7)];
      mosqueColor = const Color(0xFF0D47A1).withValues(alpha: 0.3);
    } else if (hour >= 17 && hour < 19) {
      // Sunset
      gradientColors = [const Color(0xFFE64A19), const Color(0xFFFFCC80)];
      mosqueColor = const Color(0xFF3E2723);
    } else {
      // Night
      gradientColors = [const Color(0xFF0F172A), const Color(0xFF1E293B)];
      showStars = true;
      mosqueColor = const Color(0xFF020617);
    }

    return Container(
      height: 420, // Increased to prevent overflow on some screens
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // 1. Sky Effects (Stars)
          if (showStars)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SkyPainter(_animationController.value, _stars),
                  size: Size.infinite,
                );
              },
            ),

          // 2. Mosque Silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: MosqueSilhouettePainter(color: mosqueColor),
              size: const Size(double.infinity, 220),
            ),
          ),

          // 3. Optional celestial body (Moon/Sun)
          if (showStars)
            Positioned(
              top: 50, // Moved up to avoid overlap with search/menu
              right: 20, // Moved further right
              child: Opacity(
                opacity: 0.6,
                child: CustomPaint(
                  painter: CrescentMoonPainter(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  size: const Size(24, 24), // Slightly smaller
                ),
              ),
            ),

          // 4. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date Info in Glassmorphic Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$gregorianDate | ${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Menu and Search Buttons
                      Row(
                        children: [
                          // Search Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/search'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Menu Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => GlobalScaffoldService.openDrawer(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Prayer Countdown
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _nextPrayerName.isEmpty
                              ? '...'
                              : '${l10n.nextPrayer} $_nextPrayerName',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Timer with Subtl Glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              _timeUntilNext.isEmpty
                                  ? '00:00:00'
                                  : _timeUntilNext,
                              style: GoogleFonts.montserrat(
                                fontSize: 52,
                                fontWeight: FontWeight.w200,
                                color: Colors.white.withValues(alpha: 0.1),
                                letterSpacing: 4,
                              ),
                            ),
                            Text(
                              _timeUntilNext.isEmpty
                                  ? '00:00:00'
                                  : _timeUntilNext,
                              style: GoogleFonts.montserrat(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Location Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => context.push('/prayer-times'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Color(0xFFEAA900),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentCityDisplay,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // All Prayer Times Row
                        prayerState.timings.when(
                          data: (data) {
                            if (data == null) {
                              return const SizedBox.shrink();
                            }
                            final timings = data.timings;
                            final prayerList = [
                              {'name': l10n.fajr, 'time': timings['Fajr']},
                              {'name': l10n.dhuhr, 'time': timings['Dhuhr']},
                              {'name': l10n.asr, 'time': timings['Asr']},
                              {
                                'name': l10n.maghrib,
                                'time': timings['Maghrib'],
                              },
                              {'name': l10n.isha, 'time': timings['Isha']},
                            ];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: prayerList.map((p) {
                                    final isNext = p['name'] == _nextPrayerName;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isNext
                                            ? const Color(
                                                0xFFFFD700,
                                              ).withValues(alpha: 0.25)
                                            : Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isNext
                                              ? const Color(0xFFFFD700)
                                              : Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                          width: isNext ? 2 : 1,
                                        ),
                                        boxShadow: isNext
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFFFD700,
                                                  ).withValues(alpha: 0.2),
                                                  blurRadius: 10,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            p['name']!,
                                            style: GoogleFonts.tajawal(
                                              fontSize: 13,
                                              color: isNext
                                                  ? const Color(0xFFFFD700)
                                                  : Colors.white.withValues(
                                                      alpha: 0.7,
                                                    ),
                                              fontWeight: isNext
                                                  ? FontWeight.w900
                                                  : FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            p['time']?.split(' ')[0] ?? '--:--',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
