import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/prayer_notifier.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islamic_library_flutter/data/services/notification_service.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

class PrayerTimesWidget extends ConsumerStatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  ConsumerState<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends ConsumerState<PrayerTimesWidget> {
  Timer? _timer;
  String _timeUntilNext = "";
  String _nextPrayerName = "";
  DateTime? _lastScheduledDate; // To avoid redundant scheduling

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Removed local location init methods

  @override
  void dispose() {
    _timer?.cancel();
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

        // Schedule enabled Athans (only once per day or on change)
        if (_lastScheduledDate == null ||
            _lastScheduledDate!.day != now.day ||
            _lastScheduledDate!.month != now.month) {
          final Map<String, DateTime> prayerDatetimes = {};
          for (var name in names) {
            final rawTime = prayerTimes[name];
            if (rawTime == null) continue;
            final parts = rawTime.split(':');
            if (parts.length < 2) continue;

            prayerDatetimes[name] = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          }

          final localizedNames = {
            'Fajr': l10n.fajr,
            'Dhuhr': l10n.dhuhr,
            'Asr': l10n.asr,
            'Maghrib': l10n.maghrib,
            'Isha': l10n.isha,
          };

          _scheduleAthans(prayerDatetimes, localizedNames);
          _lastScheduledDate = now;
        }
      });
    } catch (e) {
      debugPrint('Error calculating next prayer: $e');
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

    final currentCityDisplay = '${prayerState.city}, ${prayerState.country}';

    return prayerState.timings.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        return GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 16,
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.nextPrayer,
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nextPrayerName.isEmpty ? '...' : _nextPrayerName,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.hijriDate,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _timeUntilNext.isEmpty ? '00:00:00' : _timeUntilNext,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.explore_outlined,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentCityDisplay (${l10n.qibla}: 102°)',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPrayerTimeSmall('Fajr', l10n.fajr, data.getFajr()),
                  _buildPrayerTimeSmall('Dhuhr', l10n.dhuhr, data.getDhuhr()),
                  _buildPrayerTimeSmall('Asr', l10n.asr, data.getAsr()),
                  _buildPrayerTimeSmall(
                    'Maghrib',
                    l10n.maghrib,
                    data.getMaghrib(),
                  ),
                  _buildPrayerTimeSmall('Isha', l10n.isha, data.getIsha()),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildPrayerTimeSmall(String id, String name, String time) {
    // Basic time cleanup (remove trailing zone info)
    final cleanTime = time.split(' ')[0];
    final box = Hive.box('settings');
    final bool isAthanEnabled = box.get('athan_$id', defaultValue: false);

    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          cleanTime,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        IconButton(
          icon: Icon(
            isAthanEnabled
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            size: 16,
            color: isAthanEnabled ? AppTheme.primaryColor : Colors.white24,
          ),
          onPressed: () {
            box.put('athan_$id', !isAthanEnabled);
            _lastScheduledDate = null; // Force re-schedule
            setState(() {});
            // Re-schedule logic will trigger on next tick or manually
            _calculateNextPrayer();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _scheduleAthans(
    Map<String, DateTime> prayerTimes,
    Map<String, String> localizedNames,
  ) {
    final box = Hive.box('settings');
    final notificationService = NotificationService();

    final bool globalEnabled = box.get(
      'notifications_enabled',
      defaultValue: true,
    );
    if (!globalEnabled) return;

    prayerTimes.forEach((name, time) {
      final bool isEnabled = box.get('athan_$name', defaultValue: false);
      if (isEnabled) {
        notificationService.scheduleAthan(
          id: name.hashCode,
          title:
              '${AppLocalizations.of(context)!.nextPrayer} ${localizedNames[name]}',
          body: 'Allah Akbar...', // Could also be localized
          scheduledDate: time,
        );
      } else {
        notificationService.cancelNotification(name.hashCode);
      }
    });
  }
}
