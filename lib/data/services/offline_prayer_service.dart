import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_library_flutter/data/models/prayer_times_model.dart';

class OfflinePrayerService {
  static final OfflinePrayerService _instance =
      OfflinePrayerService._internal();
  factory OfflinePrayerService() => _instance;
  OfflinePrayerService._internal();

  /// Calculates prayer times for a given location and date.
  /// Standard Morocco calculation is MWL (Muslim World League).
  PrayerTimesModel calculatePrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) {
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab
        .shafi; // Default for most, including Morocco (Maliki is similar in timings usually)

    final dateToCalculate = date ?? DateTime.now();
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    // Map adhan types to string format used in the existing model
    final DateFormat formatter = DateFormat('HH:mm');

    final Map<String, String> timings = {
      'Fajr': formatter.format(prayerTimes.fajr),
      'Sunrise': formatter.format(prayerTimes.sunrise),
      'Dhuhr': formatter.format(prayerTimes.dhuhr),
      'Asr': formatter.format(prayerTimes.asr),
      'Maghrib': formatter.format(prayerTimes.maghrib),
      'Isha': formatter.format(prayerTimes.isha),
    };

    // Calculate Hijri Date
    final hijriDate = HijriCalendar.fromDate(dateToCalculate);

    return PrayerTimesModel(
      timings: timings,
      date: DateInfo(
        gregorian: GregorianDate(
          date: DateFormat('dd-MM-yyyy').format(dateToCalculate),
          format: 'DD-MM-YYYY',
          day: DateFormat('EEEE').format(dateToCalculate),
        ),
        hijri: HijriDate(
          day: hijriDate.hDay.toString(),
          month: {
            'number': hijriDate.hMonth,
            'ar': _getArabicHijriMonthName(hijriDate.hMonth),
            'en': hijriDate.longMonthName,
          },
          year: hijriDate.hYear.toString(),
          date: hijriDate.toString(),
        ),
      ),
    );
  }

  String _getArabicHijriMonthName(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
