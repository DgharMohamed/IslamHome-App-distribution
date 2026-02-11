import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة الإسلامية'**
  String get appTitle;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodAfternoon;

  /// No description provided for @goodNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلة سعيدة'**
  String get goodNight;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @dailyVerse.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get dailyVerse;

  /// No description provided for @khatmaProgress.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الختمة'**
  String get khatmaProgress;

  /// No description provided for @reachedSurah.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى سورة {surah}'**
  String reachedSurah(String surah);

  /// No description provided for @exploreSections.
  ///
  /// In ar, this message translates to:
  /// **'استكشف الأقسام'**
  String get exploreSections;

  /// No description provided for @quranMushaf.
  ///
  /// In ar, this message translates to:
  /// **'المصحف الشريف'**
  String get quranMushaf;

  /// No description provided for @propheticHadith.
  ///
  /// In ar, this message translates to:
  /// **'الأحاديث النبوية'**
  String get propheticHadith;

  /// No description provided for @hadithOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'حديث اليوم'**
  String get hadithOfTheDay;

  /// No description provided for @azkarDuas.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار والأدعية'**
  String get azkarDuas;

  /// No description provided for @adhkarOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسلم'**
  String get adhkarOfTheDay;

  /// No description provided for @radioLive.
  ///
  /// In ar, this message translates to:
  /// **'الإذاعات والمباشر'**
  String get radioLive;

  /// No description provided for @favoriteReciters.
  ///
  /// In ar, this message translates to:
  /// **'قراؤك المفضلون'**
  String get favoriteReciters;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @notificationsAthan.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والآذان'**
  String get notificationsAthan;

  /// No description provided for @athanNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الآذان'**
  String get athanNotifications;

  /// No description provided for @enabledForAll.
  ///
  /// In ar, this message translates to:
  /// **'مفعلة لكافة الصلوات'**
  String get enabledForAll;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطلة'**
  String get disabled;

  /// No description provided for @appearanceLanguage.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get appearanceLanguage;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'المظهر الداكن'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مفعل دائماً للراحة البصرية'**
  String get darkModeSubtitle;

  /// No description provided for @appLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get appLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'شارك التطبيق'**
  String get shareApp;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'قيم التطبيق'**
  String get rateApp;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @globalSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث شامل'**
  String get globalSearch;

  /// No description provided for @searchSurah.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن سورة...'**
  String get searchSurah;

  /// No description provided for @downloadAll.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الكل'**
  String get downloadAll;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @downloads.
  ///
  /// In ar, this message translates to:
  /// **'التنزيلات'**
  String get downloads;

  /// No description provided for @quranText.
  ///
  /// In ar, this message translates to:
  /// **'نص القرآن'**
  String get quranText;

  /// No description provided for @tasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'التسبيح'**
  String get tasbeeh;

  /// No description provided for @liveTv.
  ///
  /// In ar, this message translates to:
  /// **'البث المباشر'**
  String get liveTv;

  /// No description provided for @books.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة المقروءة'**
  String get books;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// No description provided for @currentLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الحالي'**
  String get currentLocation;

  /// No description provided for @qibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get qibla;

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get isha;

  /// No description provided for @noBookmarkSaved.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد علامة مرجعية محفوظة'**
  String get noBookmarkSaved;

  /// No description provided for @hadithBooks.
  ///
  /// In ar, this message translates to:
  /// **'كتب الحديث'**
  String get hadithBooks;

  /// No description provided for @nineBooksOfSunnah.
  ///
  /// In ar, this message translates to:
  /// **'تسع كتب من أصول السنة'**
  String get nineBooksOfSunnah;

  /// No description provided for @hadithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} حديث'**
  String hadithCount(int count);

  /// No description provided for @page.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {number}'**
  String page(int number);

  /// No description provided for @noHadithsAvailableOffline.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أحاديث متاحة أوفلاين لهذا الكتاب.\nيرجى الاتصال بالإنترنت للتحميل.'**
  String get noHadithsAvailableOffline;

  /// No description provided for @azkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get azkar;

  /// No description provided for @duas.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية'**
  String get duas;

  /// No description provided for @selectedDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية مختارة'**
  String get selectedDuas;

  /// No description provided for @dailyMuslimAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسلم اليومية'**
  String get dailyMuslimAzkar;

  /// No description provided for @morningAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get morningAzkar;

  /// No description provided for @eveningAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get eveningAzkar;

  /// No description provided for @sleepAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get sleepAzkar;

  /// No description provided for @wakeUpAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الاستيقاظ'**
  String get wakeUpAzkar;

  /// No description provided for @mosqueAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المسجد'**
  String get mosqueAzkar;

  /// No description provided for @adhanAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الآذان'**
  String get adhanAzkar;

  /// No description provided for @wuduAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الوضوء'**
  String get wuduAzkar;

  /// No description provided for @propheticDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية نبوية'**
  String get propheticDuas;

  /// No description provided for @quranDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية قرآنية'**
  String get quranDuas;

  /// No description provided for @prophetsDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية الأنبياء'**
  String get prophetsDuas;

  /// No description provided for @miscellaneousAzkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار متنوعة'**
  String get miscellaneousAzkar;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @startingDownloadAll.
  ///
  /// In ar, this message translates to:
  /// **'بدأ تحميل جميع السور...'**
  String get startingDownloadAll;

  /// No description provided for @downloadCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم اكتمال تحميل {count} سورة'**
  String downloadCompleted(int count);

  /// No description provided for @surahNumber.
  ///
  /// In ar, this message translates to:
  /// **'سورة رقم {number}'**
  String surahNumber(String number);

  /// No description provided for @recitationOf.
  ///
  /// In ar, this message translates to:
  /// **'تلاوة {name}'**
  String recitationOf(String name);

  /// No description provided for @downloadSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تم التحميل بنجاح'**
  String get downloadSuccessful;

  /// No description provided for @downloadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحميل: {error}'**
  String downloadFailed(String error);

  /// No description provided for @electronicTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'مسبحة إلكترونية'**
  String get electronicTasbeeh;

  /// No description provided for @totalTasbeehs.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التسبيحات'**
  String get totalTasbeehs;

  /// No description provided for @tapToCount.
  ///
  /// In ar, this message translates to:
  /// **'اضغط في أي مكان في الدائرة للتسبيح'**
  String get tapToCount;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get reset;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @mushaf.
  ///
  /// In ar, this message translates to:
  /// **'المصحف الشريف'**
  String get mushaf;

  /// No description provided for @pageSavedAsBookmark.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الصفحة {page} كعلامة مرجعية'**
  String pageSavedAsBookmark(int page);

  /// No description provided for @readingModeText.
  ///
  /// In ar, this message translates to:
  /// **'وضع القراءة النصي'**
  String get readingModeText;

  /// No description provided for @pageXOf604.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page} من 604'**
  String pageXOf604(int page);

  /// No description provided for @lastReadMushaf.
  ///
  /// In ar, this message translates to:
  /// **'آخر قرائة (صفحة {page})'**
  String lastReadMushaf(Object page);

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get previous;

  /// No description provided for @index.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس'**
  String get index;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالية'**
  String get next;

  /// No description provided for @errorLoadingPage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل الصفحة'**
  String get errorLoadingPage;

  /// No description provided for @surahIndex.
  ///
  /// In ar, this message translates to:
  /// **'فهرس السور'**
  String get surahIndex;

  /// No description provided for @errorLoadingSurahs.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل السور'**
  String get errorLoadingSurahs;

  /// No description provided for @meccan.
  ///
  /// In ar, this message translates to:
  /// **'مكية'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In ar, this message translates to:
  /// **'مدنية'**
  String get medinan;

  /// No description provided for @ayahsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} آية'**
  String ayahsCount(int count);

  /// No description provided for @pageN.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page}'**
  String pageN(int page);

  /// No description provided for @showMushaf.
  ///
  /// In ar, this message translates to:
  /// **'عرض المصحف'**
  String get showMushaf;

  /// No description provided for @selectTranslation.
  ///
  /// In ar, this message translates to:
  /// **'اختر الترجمة'**
  String get selectTranslation;

  /// No description provided for @selectTafsir.
  ///
  /// In ar, this message translates to:
  /// **'اختر التفسير'**
  String get selectTafsir;

  /// No description provided for @chooseTranslation.
  ///
  /// In ar, this message translates to:
  /// **'اختر الترجمة'**
  String get chooseTranslation;

  /// No description provided for @chooseTafsir.
  ///
  /// In ar, this message translates to:
  /// **'اختر التفسير'**
  String get chooseTafsir;

  /// No description provided for @chooseSurah.
  ///
  /// In ar, this message translates to:
  /// **'اختر السورة'**
  String get chooseSurah;

  /// No description provided for @verseN.
  ///
  /// In ar, this message translates to:
  /// **'الآية {number}'**
  String verseN(Object number);

  /// No description provided for @noTafsirAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تفسير متاح حالياً'**
  String get noTafsirAvailable;

  /// No description provided for @radio.
  ///
  /// In ar, this message translates to:
  /// **'الإذاعات'**
  String get radio;

  /// No description provided for @videos.
  ///
  /// In ar, this message translates to:
  /// **'السيرة النبوية'**
  String get videos;

  /// No description provided for @myAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccount;

  /// No description provided for @moodAnxious.
  ///
  /// In ar, this message translates to:
  /// **'قلق'**
  String get moodAnxious;

  /// No description provided for @moodSad.
  ///
  /// In ar, this message translates to:
  /// **'حزين'**
  String get moodSad;

  /// No description provided for @moodHappy.
  ///
  /// In ar, this message translates to:
  /// **'سعيد'**
  String get moodHappy;

  /// No description provided for @moodLost.
  ///
  /// In ar, this message translates to:
  /// **'تائه'**
  String get moodLost;

  /// No description provided for @moodTired.
  ///
  /// In ar, this message translates to:
  /// **'متعب'**
  String get moodTired;

  /// No description provided for @surahSharh.
  ///
  /// In ar, this message translates to:
  /// **'سورة الشرح'**
  String get surahSharh;

  /// No description provided for @descAnxious.
  ///
  /// In ar, this message translates to:
  /// **'تذكر دائماً أن مع العسر يسراً، هذه السورة تبعث الطمأنينة في القلوب القلقة.'**
  String get descAnxious;

  /// No description provided for @actionReadSurah.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ السورة'**
  String get actionReadSurah;

  /// No description provided for @surahYusuf.
  ///
  /// In ar, this message translates to:
  /// **'سورة يوسف'**
  String get surahYusuf;

  /// No description provided for @descSad.
  ///
  /// In ar, this message translates to:
  /// **'قصة الصبر والفرج بعد الضيق. إنها بلسم للقلوب الحزينة.'**
  String get descSad;

  /// No description provided for @surahRahman.
  ///
  /// In ar, this message translates to:
  /// **'سورة الرحمن'**
  String get surahRahman;

  /// No description provided for @descHappy.
  ///
  /// In ar, this message translates to:
  /// **'خير ما يشكر به الله على نعمه وفضله. فبأي آلاء ربكما تكذبان.'**
  String get descHappy;

  /// No description provided for @surahFatiha.
  ///
  /// In ar, this message translates to:
  /// **'سورة الفاتحة'**
  String get surahFatiha;

  /// No description provided for @descLost.
  ///
  /// In ar, this message translates to:
  /// **'أم الكتاب والدعاء بالهداية للصراط المستقيم في كل حين.'**
  String get descLost;

  /// No description provided for @descTired.
  ///
  /// In ar, this message translates to:
  /// **'لتستريح نفسك ويهدأ بالك بذكر الله قبل المنام.'**
  String get descTired;

  /// No description provided for @actionGoToAzkar.
  ///
  /// In ar, this message translates to:
  /// **'اذهب للأذكار'**
  String get actionGoToAzkar;

  /// No description provided for @becauseYouFeel.
  ///
  /// In ar, this message translates to:
  /// **'لأنك تشعر بـ {mood}'**
  String becauseYouFeel(String mood);

  /// No description provided for @howDoYouFeel.
  ///
  /// In ar, this message translates to:
  /// **'بماذا تشعر الآن؟'**
  String get howDoYouFeel;

  /// No description provided for @unknownName.
  ///
  /// In ar, this message translates to:
  /// **'اسم غير معروف'**
  String get unknownName;

  /// No description provided for @mushafCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مصحف'**
  String mushafCount(int count);

  /// No description provided for @nowPlaying.
  ///
  /// In ar, this message translates to:
  /// **'جاري التشغيل...'**
  String get nowPlaying;

  /// No description provided for @reciterLabel.
  ///
  /// In ar, this message translates to:
  /// **'القارئ'**
  String get reciterLabel;

  /// No description provided for @verseOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get verseOfTheDay;

  /// No description provided for @dailyVerseText.
  ///
  /// In ar, this message translates to:
  /// **'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا'**
  String get dailyVerseText;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimesTitle;

  /// No description provided for @noPrayerTimesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على مواقيت لهذه المدخلات'**
  String get noPrayerTimesFound;

  /// No description provided for @cityLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get cityLabel;

  /// No description provided for @countryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get countryLabel;

  /// No description provided for @updateTimesButton.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المواقيت'**
  String get updateTimesButton;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurred(String error);

  /// No description provided for @sunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get sunrise;

  /// No description provided for @nowListening.
  ///
  /// In ar, this message translates to:
  /// **'جاري الاستماع'**
  String get nowListening;

  /// No description provided for @sleepTimer.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت النوم'**
  String get sleepTimer;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تفعيل {feature} قريباً'**
  String comingSoon(Object feature);

  /// No description provided for @startingDownload.
  ///
  /// In ar, this message translates to:
  /// **'جاري بدء التحميل...'**
  String get startingDownload;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// No description provided for @playlist.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get playlist;

  /// No description provided for @currentPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التشغيل الحالية'**
  String get currentPlaylist;

  /// No description provided for @audioCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صوتيات'**
  String audioCount(Object count);

  /// No description provided for @nowPlayingLabel.
  ///
  /// In ar, this message translates to:
  /// **'يعمل الآن'**
  String get nowPlayingLabel;

  /// No description provided for @timeRemaining.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي: {time}'**
  String timeRemaining(Object time);

  /// No description provided for @stopTimer.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف المؤقت'**
  String get stopTimer;

  /// No description provided for @sleepTimerStopped.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف مؤقت النوم'**
  String get sleepTimerStopped;

  /// No description provided for @timerSetFor.
  ///
  /// In ar, this message translates to:
  /// **'تم ضبط المؤقت لـ {time}'**
  String timerSetFor(Object time);

  /// No description provided for @surahIdNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على معرف السورة'**
  String get surahIdNotFound;

  /// No description provided for @errorLoadingText.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل النص'**
  String get errorLoadingText;

  /// No description provided for @shareRecitationText.
  ///
  /// In ar, this message translates to:
  /// **'استمع إلى {title} بصوت القارئ {reciter} عبر تطبيق المكتبة الإسلامية.\n\n{link}'**
  String shareRecitationText(Object link, Object reciter, Object title);

  /// No description provided for @minutes.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String minutes(Object count);

  /// No description provided for @liveTvTitle.
  ///
  /// In ar, this message translates to:
  /// **'البث المباشر'**
  String get liveTvTitle;

  /// No description provided for @religiousChannelsDescription.
  ///
  /// In ar, this message translates to:
  /// **'قنوات دينية على مدار الساعة'**
  String get religiousChannelsDescription;

  /// No description provided for @videoPlayerError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تشغيل الفيديو'**
  String get videoPlayerError;

  /// No description provided for @checkInternetConnection.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى'**
  String get checkInternetConnection;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @islamicRadioTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإذاعات الإسلامية'**
  String get islamicRadioTitle;

  /// No description provided for @liveRadioDescription.
  ///
  /// In ar, this message translates to:
  /// **'بث مباشر على مدار الساعة'**
  String get liveRadioDescription;

  /// No description provided for @searchRadioHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن إذاعة...'**
  String get searchRadioHint;

  /// No description provided for @videoLibraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'السيرة النبوية'**
  String get videoLibraryTitle;

  /// No description provided for @searchVideoHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في السيرة النبوية...'**
  String get searchVideoHint;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @reciters.
  ///
  /// In ar, this message translates to:
  /// **'القراء'**
  String get reciters;

  /// No description provided for @surahs.
  ///
  /// In ar, this message translates to:
  /// **'السور'**
  String get surahs;

  /// No description provided for @noFavoriteReciters.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد قراء في المفضلة'**
  String get noFavoriteReciters;

  /// No description provided for @noFavoriteSurahs.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور في المفضلة'**
  String get noFavoriteSurahs;

  /// No description provided for @unknownReciter.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknownReciter;

  /// No description provided for @downloadingSurah.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل سورة {surah}...'**
  String downloadingSurah(String surah);

  /// No description provided for @downloaded.
  ///
  /// In ar, this message translates to:
  /// **'تم التحميل'**
  String get downloaded;

  /// No description provided for @downloadsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنزيلات'**
  String get downloadsTitle;

  /// No description provided for @downloadedSurahs.
  ///
  /// In ar, this message translates to:
  /// **'السور المحملة'**
  String get downloadedSurahs;

  /// No description provided for @downloadedLibraryDescription.
  ///
  /// In ar, this message translates to:
  /// **'مكتبتك الصوتية المحملة'**
  String get downloadedLibraryDescription;

  /// No description provided for @libraryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة فارغة'**
  String get libraryEmpty;

  /// No description provided for @downloadedFilesWillAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المحملة ستظهر هنا'**
  String get downloadedFilesWillAppearHere;

  /// No description provided for @downloadedSurahCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سورة محملة'**
  String downloadedSurahCount(Object count);

  /// No description provided for @audioFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف صوتي'**
  String get audioFile;

  /// No description provided for @deleteFileQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملف؟'**
  String get deleteFileQuestion;

  /// No description provided for @deleteFileConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الملف نهائياً؟'**
  String get deleteFileConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @booksLibraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الكتب'**
  String get booksLibraryTitle;

  /// No description provided for @articlesAndBooksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المقالات والكتب'**
  String get articlesAndBooksTitle;

  /// No description provided for @searchLibraryHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في المكتبة...'**
  String get searchLibraryHint;

  /// No description provided for @booksLabel.
  ///
  /// In ar, this message translates to:
  /// **'كتب'**
  String get booksLabel;

  /// No description provided for @articlesLabel.
  ///
  /// In ar, this message translates to:
  /// **'مقالات'**
  String get articlesLabel;

  /// No description provided for @audiosLabel.
  ///
  /// In ar, this message translates to:
  /// **'صوتيات'**
  String get audiosLabel;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج بحث'**
  String get noSearchResults;

  /// No description provided for @downloadButton.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get downloadButton;

  /// No description provided for @pageCount.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page}'**
  String pageCount(int page);

  /// No description provided for @allRecitersTitle.
  ///
  /// In ar, this message translates to:
  /// **'جميع القراء'**
  String get allRecitersTitle;

  /// No description provided for @mainMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة الرئيسية'**
  String get mainMenu;

  /// No description provided for @readingMedia.
  ///
  /// In ar, this message translates to:
  /// **'محتوى القراءة'**
  String get readingMedia;

  /// No description provided for @utilitiesTools.
  ///
  /// In ar, this message translates to:
  /// **'الأدوات المساعدة'**
  String get utilitiesTools;

  /// No description provided for @appNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'Islam Home'**
  String get appNameEnglish;

  /// No description provided for @appNameArabic.
  ///
  /// In ar, this message translates to:
  /// **'بيت الإسلام'**
  String get appNameArabic;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @hadith.
  ///
  /// In ar, this message translates to:
  /// **'الحديث'**
  String get hadith;

  /// No description provided for @surahName.
  ///
  /// In ar, this message translates to:
  /// **'{name}'**
  String surahName(String name);

  /// No description provided for @reciterName.
  ///
  /// In ar, this message translates to:
  /// **'{name}'**
  String reciterName(String name);

  /// No description provided for @useLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الموقع الحالي'**
  String get useLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الموقع معطلة.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الوصول للموقع.'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع بشكل دائم.'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @failedToGetLocation.
  ///
  /// In ar, this message translates to:
  /// **'فشل في الحصول على الموقع: {error}'**
  String failedToGetLocation(String error);

  /// No description provided for @updateLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع'**
  String get updateLocation;

  /// No description provided for @surahDuha.
  ///
  /// In ar, this message translates to:
  /// **'سورة الضحى'**
  String get surahDuha;

  /// No description provided for @descDuha.
  ///
  /// In ar, this message translates to:
  /// **'ما ودعك ربك وما قلى. رسالة ربانية لكل قلب يشعر بالضيق والحزن.'**
  String get descDuha;

  /// No description provided for @actionGoToDua.
  ///
  /// In ar, this message translates to:
  /// **'اذهب للأدعية'**
  String get actionGoToDua;

  /// No description provided for @startTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسبيح'**
  String get startTasbeeh;

  /// No description provided for @rememberAllah.
  ///
  /// In ar, this message translates to:
  /// **'ذكر الله'**
  String get rememberAllah;

  /// No description provided for @descHappyDhikr.
  ///
  /// In ar, this message translates to:
  /// **'الحمد لله تزيد النعمة وتبارك في الرزق وتديم السعادة.'**
  String get descHappyDhikr;

  /// No description provided for @allahIsNear.
  ///
  /// In ar, this message translates to:
  /// **'الله قريب منك'**
  String get allahIsNear;

  /// No description provided for @descLostDhikr.
  ///
  /// In ar, this message translates to:
  /// **'الله قريب منك دائماً، يوجهك ويسمع دعاءك إذا ضللت الطريق.'**
  String get descLostDhikr;

  /// No description provided for @rewardForTired.
  ///
  /// In ar, this message translates to:
  /// **'أجر التعب'**
  String get rewardForTired;

  /// No description provided for @descTiredDhikr.
  ///
  /// In ar, this message translates to:
  /// **'تذكر أن تعبك مأجور، وأن الله لا يحملك فوق طاقتك. استرح بذكر الله.'**
  String get descTiredDhikr;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في القرآن، الحديث، الأذكار...'**
  String get searchHint;

  /// No description provided for @searchQuranSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن: {surah} ({ayah})'**
  String searchQuranSubtitle(String surah, int ayah);

  /// No description provided for @searchHadithSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الحديث: {book} - {chapter}'**
  String searchHadithSubtitle(String book, String chapter);

  /// No description provided for @searchAdhkarSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار: {category}'**
  String searchAdhkarSubtitle(String category);

  /// No description provided for @exploreLibrary.
  ///
  /// In ar, this message translates to:
  /// **'استكشف المكتبة'**
  String get exploreLibrary;

  /// No description provided for @searchDescription.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الآيات والأحاديث والأدعية'**
  String get searchDescription;

  /// No description provided for @khatmaPlannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'مخطط الختمة الذكي'**
  String get khatmaPlannerTitle;

  /// No description provided for @khatmaPlannerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد المدة التي ترغب بختم القرآن فيها'**
  String get khatmaPlannerSubtitle;

  /// No description provided for @startKhatma.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الختمة'**
  String get startKhatma;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get days;

  /// No description provided for @pagesDaily.
  ///
  /// In ar, this message translates to:
  /// **'صفحات يومياً'**
  String get pagesDaily;

  /// No description provided for @pagesPerPrayer.
  ///
  /// In ar, this message translates to:
  /// **'صفحات لكل صلاة'**
  String get pagesPerPrayer;

  /// No description provided for @remainingToday.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي لك اليوم: {count} صفحات'**
  String remainingToday(int count);

  /// No description provided for @onTrack.
  ///
  /// In ar, this message translates to:
  /// **'أنت على الجدول'**
  String get onTrack;

  /// No description provided for @setupPlan.
  ///
  /// In ar, this message translates to:
  /// **'ضبط الخطة'**
  String get setupPlan;

  /// No description provided for @cancelPlan.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الخطة'**
  String get cancelPlan;

  /// No description provided for @manageNotificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إدارة إعدادات الإشعارات'**
  String get manageNotificationSettings;

  /// No description provided for @manageNotificationSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات النظام للإشعارات'**
  String get manageNotificationSettingsSubtitle;

  /// No description provided for @continueYourKhatma.
  ///
  /// In ar, this message translates to:
  /// **'واصل ختمـتك'**
  String get continueYourKhatma;

  /// No description provided for @juzAndSurah.
  ///
  /// In ar, this message translates to:
  /// **'الجزء {juz} - {surah}'**
  String juzAndSurah(Object juz, Object surah);

  /// No description provided for @smartSuggestionsForNewPlan.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات ذكية لنظامك الجديد:'**
  String get smartSuggestionsForNewPlan;

  /// No description provided for @khatmaInMonth.
  ///
  /// In ar, this message translates to:
  /// **'ختمة في شهر'**
  String get khatmaInMonth;

  /// No description provided for @oneJuzDaily.
  ///
  /// In ar, this message translates to:
  /// **'1 جزء يومياً'**
  String get oneJuzDaily;

  /// No description provided for @khatmaInTwoMonths.
  ///
  /// In ar, this message translates to:
  /// **'ختمة في شهرين'**
  String get khatmaInTwoMonths;

  /// No description provided for @fifteenPagesDaily.
  ///
  /// In ar, this message translates to:
  /// **'15 صفحة يومياً'**
  String get fifteenPagesDaily;

  /// No description provided for @pagesRemainingToday.
  ///
  /// In ar, this message translates to:
  /// **'بقي لك {count} صفحات لليوم'**
  String pagesRemainingToday(Object count);

  /// No description provided for @khatmaHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الختمات'**
  String get khatmaHistory;

  /// No description provided for @khatmaSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الختمة'**
  String get khatmaSettings;

  /// No description provided for @duaKhatm.
  ///
  /// In ar, this message translates to:
  /// **'دعاء ختم القرآن'**
  String get duaKhatm;

  /// No description provided for @continueReading.
  ///
  /// In ar, this message translates to:
  /// **'إكمال القراءة'**
  String get continueReading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
