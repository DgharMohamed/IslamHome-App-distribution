import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/prayer_notifier.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> _habousCities = [];
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String _nextPrayerName = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _startTimer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _calculateNextPrayer();
    });
  }

  void _calculateNextPrayer() {
    final state = ref.read(prayerNotifierProvider);
    state.timings.whenData((data) {
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
          nextName = name;
          break;
        }
      }

      // If no more prayers today, next is Fajr tomorrow
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
        nextName = 'Fajr';
      }

      if (mounted) {
        setState(() {
          _remaining = nextTime!.difference(now);
          _nextPrayerName = nextName;
        });
      }
    });
  }

  Future<void> _loadCities() async {
    final jsonStr = await rootBundle.loadString(
      'assets/json/habous_cities.json',
    );
    final data = json.decode(jsonStr);
    if (mounted) {
      setState(() {
        _habousCities = List<Map<String, String>>.from(
          data.map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.prayerTimesTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.backgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.top + 60),
            ),

            // Premium Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildHeader(state, l10n),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Timings List
            state.timings.when(
              data: (data) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (data != null) ...[
                      _buildPrayerItem(
                        l10n.fajr,
                        data.getFajr(),
                        Icons.wb_twilight,
                        'Fajr',
                      ),
                      _buildPrayerItem(
                        l10n.sunrise,
                        data.getSunrise(),
                        Icons.wb_sunny_outlined,
                        'Sunrise',
                      ),
                      _buildPrayerItem(
                        l10n.dhuhr,
                        data.getDhuhr(),
                        Icons.wb_sunny,
                        'Dhuhr',
                      ),
                      _buildPrayerItem(
                        l10n.asr,
                        data.getAsr(),
                        Icons.cloud_queue_rounded,
                        'Asr',
                      ),
                      _buildPrayerItem(
                        l10n.maghrib,
                        data.getMaghrib(),
                        Icons.nights_stay_outlined,
                        'Maghrib',
                      ),
                      _buildPrayerItem(
                        l10n.isha,
                        data.getIsha(),
                        Icons.nights_stay_rounded,
                        'Isha',
                      ),
                    ] else
                      Center(
                        child: Text(
                          l10n.noPrayerTimesFound,
                          style: GoogleFonts.cairo(color: Colors.white54),
                        ),
                      ),
                  ]),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    e.toString(),
                    style: GoogleFonts.cairo(color: Colors.redAccent),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // City Selection Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildLocationSettings(state, l10n),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PrayerState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                state.city,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getLocalizedPrayerName(_nextPrayerName, l10n),
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.05).animate(_pulseController),
            child: Text(
              _formatDuration(_remaining),
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'الوقت المتبقي للأذان',
            style: GoogleFonts.cairo(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(String name, String time, IconData icon, String key) {
    final isNext = _nextPrayerName == key;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNext
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: isNext
            ? Border.all(color: AppTheme.primaryColor, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isNext ? AppTheme.primaryColor : Colors.white54,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  color: isNext ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNext ? AppTheme.primaryColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSettings(PrayerState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildSettingRow(
                'الدولة',
                state.country,
                Icons.public_rounded,
                () => _showCountryPicker(),
              ),
              const Divider(color: Colors.white10, height: 32),
              _buildSettingRow(
                'المدينة',
                state.city,
                Icons.location_city_rounded,
                () => state.country == 'Morocco' || state.country == 'المغرب'
                    ? _showHabousCityPicker()
                    : _showManualCityInput(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.cairo(color: Colors.white70)),
            ],
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPickerOption('المغرب', 'Morocco', true),
            const SizedBox(height: 12),
            _buildPickerOption('دولة أخرى', 'Other', false),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(String label, String value, bool isMorocco) {
    return ListTile(
      title: Text(label, style: GoogleFonts.cairo(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (isMorocco) {
          ref
              .read(prayerNotifierProvider.notifier)
              .updateLocation(
                city: 'الرباط',
                country: 'Morocco',
                habousId: '1',
              );
        } else {
          _showManualCityInput();
        }
      },
    );
  }

  void _showHabousCityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _habousCities.length,
                itemBuilder: (context, index) {
                  final city = _habousCities[index];
                  return ListTile(
                    title: Text(
                      city['name'] ?? '',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    onTap: () {
                      ref
                          .read(prayerNotifierProvider.notifier)
                          .updateLocation(
                            city: city['name']!,
                            country: 'Morocco',
                            habousId: city['id'],
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualCityInput() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'إدخال يدوي',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(hintText: 'المدينة'),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(hintText: 'الدولة'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(prayerNotifierProvider.notifier)
                  .updateLocation(
                    city: cityController.text,
                    country: countryController.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  String _getLocalizedPrayerName(String key, AppLocalizations l10n) {
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
        return '...';
    }
  }
}
