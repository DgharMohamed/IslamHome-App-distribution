// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المكتبة الإسلامية';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodNight => 'ليلة سعيدة';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get dailyVerse => 'آية اليوم';

  @override
  String get khatmaProgress => 'متابعة الختمة';

  @override
  String reachedSurah(String surah) {
    return 'وصلت إلى سورة $surah';
  }

  @override
  String get exploreSections => 'استكشف الأقسام';

  @override
  String get quranMushaf => 'المصحف الشريف';

  @override
  String get propheticHadith => 'الأحاديث النبوية';

  @override
  String get hadithOfTheDay => 'حديث اليوم';

  @override
  String get azkarDuas => 'الأذكار والأدعية';

  @override
  String get adhkarOfTheDay => 'أذكار المسلم';

  @override
  String get radioLive => 'الإذاعات والمباشر';

  @override
  String get favoriteReciters => 'قراؤك المفضلون';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notificationsAthan => 'التنبيهات والآذان';

  @override
  String get athanNotifications => 'تنبيهات الآذان';

  @override
  String get enabledForAll => 'مفعلة لكافة الصلوات';

  @override
  String get disabled => 'معطلة';

  @override
  String get appearanceLanguage => 'المظهر واللغة';

  @override
  String get darkMode => 'المظهر الداكن';

  @override
  String get darkModeSubtitle => 'مفعل دائماً للراحة البصرية';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get shareApp => 'شارك التطبيق';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get globalSearch => 'بحث شامل';

  @override
  String get searchSurah => 'بحث عن سورة...';

  @override
  String get downloadAll => 'تحميل الكل';

  @override
  String get favorites => 'المفضلة';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get quranText => 'نص القرآن';

  @override
  String get tasbeeh => 'التسبيح';

  @override
  String get liveTv => 'البث المباشر';

  @override
  String get books => 'المكتبة المقروءة';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get qibla => 'القبلة';

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get noBookmarkSaved => 'لا توجد علامة مرجعية محفوظة';

  @override
  String get hadithBooks => 'كتب الحديث';

  @override
  String get nineBooksOfSunnah => 'تسع كتب من أصول السنة';

  @override
  String hadithCount(int count) {
    return '$count حديث';
  }

  @override
  String page(int number) {
    return 'صفحة $number';
  }

  @override
  String get noHadithsAvailableOffline =>
      'لا توجد أحاديث متاحة أوفلاين لهذا الكتاب.\nيرجى الاتصال بالإنترنت للتحميل.';

  @override
  String get azkar => 'الأذكار';

  @override
  String get duas => 'الأدعية';

  @override
  String get selectedDuas => 'أدعية مختارة';

  @override
  String get dailyMuslimAzkar => 'أذكار المسلم اليومية';

  @override
  String get morningAzkar => 'أذكار الصباح';

  @override
  String get eveningAzkar => 'أذكار المساء';

  @override
  String get sleepAzkar => 'أذكار النوم';

  @override
  String get wakeUpAzkar => 'أذكار الاستيقاظ';

  @override
  String get mosqueAzkar => 'أذكار المسجد';

  @override
  String get adhanAzkar => 'أذكار الآذان';

  @override
  String get wuduAzkar => 'أذكار الوضوء';

  @override
  String get propheticDuas => 'أدعية نبوية';

  @override
  String get quranDuas => 'أدعية قرآنية';

  @override
  String get prophetsDuas => 'أدعية الأنبياء';

  @override
  String get miscellaneousAzkar => 'أذكار متنوعة';

  @override
  String get done => 'تم';

  @override
  String get startingDownloadAll => 'بدأ تحميل جميع السور...';

  @override
  String downloadCompleted(int count) {
    return 'تم اكتمال تحميل $count سورة';
  }

  @override
  String surahNumber(String number) {
    return 'سورة رقم $number';
  }

  @override
  String recitationOf(String name) {
    return 'تلاوة $name';
  }

  @override
  String get downloadSuccessful => 'تم التحميل بنجاح';

  @override
  String downloadFailed(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get electronicTasbeeh => 'مسبحة إلكترونية';

  @override
  String get totalTasbeehs => 'إجمالي التسبيحات';

  @override
  String get tapToCount => 'اضغط في أي مكان في الدائرة للتسبيح';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get history => 'السجل';

  @override
  String get mushaf => 'المصحف الشريف';

  @override
  String pageSavedAsBookmark(int page) {
    return 'تم حفظ الصفحة $page كعلامة مرجعية';
  }

  @override
  String get readingModeText => 'وضع القراءة النصي';

  @override
  String pageXOf604(int page) {
    return 'صفحة $page من 604';
  }

  @override
  String lastReadMushaf(Object page) {
    return 'آخر قرائة (صفحة $page)';
  }

  @override
  String get previous => 'السابقة';

  @override
  String get index => 'الفهرس';

  @override
  String get next => 'التالية';

  @override
  String get errorLoadingPage => 'حدث خطأ في تحميل الصفحة';

  @override
  String get surahIndex => 'فهرس السور';

  @override
  String get errorLoadingSurahs => 'حدث خطأ في تحميل السور';

  @override
  String get meccan => 'مكية';

  @override
  String get medinan => 'مدنية';

  @override
  String ayahsCount(int count) {
    return '$count آية';
  }

  @override
  String pageN(int page) {
    return 'صفحة $page';
  }

  @override
  String get showMushaf => 'عرض المصحف';

  @override
  String get selectTranslation => 'اختر الترجمة';

  @override
  String get selectTafsir => 'اختر التفسير';

  @override
  String get chooseTranslation => 'اختر الترجمة';

  @override
  String get chooseTafsir => 'اختر التفسير';

  @override
  String get chooseSurah => 'اختر السورة';

  @override
  String verseN(Object number) {
    return 'الآية $number';
  }

  @override
  String get noTafsirAvailable => 'لا يوجد تفسير متاح حالياً';

  @override
  String get radio => 'الإذاعات';

  @override
  String get videos => 'السيرة النبوية';

  @override
  String get myAccount => 'حسابي';

  @override
  String get moodAnxious => 'قلق';

  @override
  String get moodSad => 'حزين';

  @override
  String get moodHappy => 'سعيد';

  @override
  String get moodLost => 'تائه';

  @override
  String get moodTired => 'متعب';

  @override
  String get surahSharh => 'سورة الشرح';

  @override
  String get descAnxious =>
      'تذكر دائماً أن مع العسر يسراً، هذه السورة تبعث الطمأنينة في القلوب القلقة.';

  @override
  String get actionReadSurah => 'اقرأ السورة';

  @override
  String get surahYusuf => 'سورة يوسف';

  @override
  String get descSad => 'قصة الصبر والفرج بعد الضيق. إنها بلسم للقلوب الحزينة.';

  @override
  String get surahRahman => 'سورة الرحمن';

  @override
  String get descHappy =>
      'خير ما يشكر به الله على نعمه وفضله. فبأي آلاء ربكما تكذبان.';

  @override
  String get surahFatiha => 'سورة الفاتحة';

  @override
  String get descLost =>
      'أم الكتاب والدعاء بالهداية للصراط المستقيم في كل حين.';

  @override
  String get descTired => 'لتستريح نفسك ويهدأ بالك بذكر الله قبل المنام.';

  @override
  String get actionGoToAzkar => 'اذهب للأذكار';

  @override
  String becauseYouFeel(String mood) {
    return 'لأنك تشعر بـ $mood';
  }

  @override
  String get howDoYouFeel => 'بماذا تشعر الآن؟';

  @override
  String get unknownName => 'اسم غير معروف';

  @override
  String mushafCount(int count) {
    return '$count مصحف';
  }

  @override
  String get nowPlaying => 'جاري التشغيل...';

  @override
  String get reciterLabel => 'القارئ';

  @override
  String get verseOfTheDay => 'آية اليوم';

  @override
  String get dailyVerseText =>
      'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا';

  @override
  String get prayerTimesTitle => 'مواقيت الصلاة';

  @override
  String get noPrayerTimesFound => 'لم يتم العثور على مواقيت لهذه المدخلات';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get updateTimesButton => 'تحديث المواقيت';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get sunrise => 'الشروق';

  @override
  String get nowListening => 'جاري الاستماع';

  @override
  String get sleepTimer => 'مؤقت النوم';

  @override
  String get share => 'مشاركة';

  @override
  String comingSoon(Object feature) {
    return 'سيتم تفعيل $feature قريباً';
  }

  @override
  String get startingDownload => 'جاري بدء التحميل...';

  @override
  String get download => 'تحميل';

  @override
  String get playlist => 'القائمة';

  @override
  String get currentPlaylist => 'قائمة التشغيل الحالية';

  @override
  String audioCount(Object count) {
    return '$count صوتيات';
  }

  @override
  String get nowPlayingLabel => 'يعمل الآن';

  @override
  String timeRemaining(Object time) {
    return 'الوقت المتبقي: $time';
  }

  @override
  String get stopTimer => 'إيقاف المؤقت';

  @override
  String get sleepTimerStopped => 'تم إيقاف مؤقت النوم';

  @override
  String timerSetFor(Object time) {
    return 'تم ضبط المؤقت لـ $time';
  }

  @override
  String get surahIdNotFound => 'لم يتم العثور على معرف السورة';

  @override
  String get errorLoadingText => 'خطأ في تحميل النص';

  @override
  String shareRecitationText(Object link, Object reciter, Object title) {
    return 'استمع إلى $title بصوت القارئ $reciter عبر تطبيق المكتبة الإسلامية.\n\n$link';
  }

  @override
  String minutes(Object count) {
    return '$count دقيقة';
  }

  @override
  String get liveTvTitle => 'البث المباشر';

  @override
  String get religiousChannelsDescription => 'قنوات دينية على مدار الساعة';

  @override
  String get videoPlayerError => 'تعذر تشغيل الفيديو';

  @override
  String get checkInternetConnection =>
      'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get islamicRadioTitle => 'الإذاعات الإسلامية';

  @override
  String get liveRadioDescription => 'بث مباشر على مدار الساعة';

  @override
  String get searchRadioHint => 'ابحث عن إذاعة...';

  @override
  String get videoLibraryTitle => 'السيرة النبوية';

  @override
  String get searchVideoHint => 'ابحث في السيرة النبوية...';

  @override
  String get all => 'الكل';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get reciters => 'القراء';

  @override
  String get surahs => 'السور';

  @override
  String get noFavoriteReciters => 'لا يوجد قراء في المفضلة';

  @override
  String get noFavoriteSurahs => 'لا توجد سور في المفضلة';

  @override
  String get unknownReciter => 'غير معروف';

  @override
  String downloadingSurah(String surah) {
    return 'جاري تحميل سورة $surah...';
  }

  @override
  String get downloaded => 'تم التحميل';

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get downloadedSurahs => 'السور المحملة';

  @override
  String get downloadedLibraryDescription => 'مكتبتك الصوتية المحملة';

  @override
  String get libraryEmpty => 'المكتبة فارغة';

  @override
  String get downloadedFilesWillAppearHere => 'الملفات المحملة ستظهر هنا';

  @override
  String downloadedSurahCount(Object count) {
    return '$count سورة محملة';
  }

  @override
  String get audioFile => 'ملف صوتي';

  @override
  String get deleteFileQuestion => 'حذف الملف؟';

  @override
  String get deleteFileConfirmation => 'هل أنت متأكد من حذف هذا الملف نهائياً؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get booksLibraryTitle => 'مكتبة الكتب';

  @override
  String get articlesAndBooksTitle => 'المقالات والكتب';

  @override
  String get searchLibraryHint => 'ابحث في المكتبة...';

  @override
  String get booksLabel => 'كتب';

  @override
  String get articlesLabel => 'مقالات';

  @override
  String get audiosLabel => 'صوتيات';

  @override
  String get noSearchResults => 'لا توجد نتائج بحث';

  @override
  String get downloadButton => 'تحميل';

  @override
  String pageCount(int page) {
    return 'صفحة $page';
  }

  @override
  String get allRecitersTitle => 'جميع القراء';

  @override
  String get mainMenu => 'القائمة الرئيسية';

  @override
  String get readingMedia => 'محتوى القراءة';

  @override
  String get utilitiesTools => 'الأدوات المساعدة';

  @override
  String get appNameEnglish => 'Islam Home';

  @override
  String get appNameArabic => 'بيت الإسلام';

  @override
  String get home => 'الرئيسية';

  @override
  String get hadith => 'الحديث';

  @override
  String surahName(String name) {
    return '$name';
  }

  @override
  String reciterName(String name) {
    return '$name';
  }

  @override
  String get useLocation => 'استخدام الموقع الحالي';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة.';

  @override
  String get locationPermissionsDenied => 'تم رفض إذن الوصول للموقع.';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'تم رفض إذن الموقع بشكل دائم.';

  @override
  String failedToGetLocation(String error) {
    return 'فشل في الحصول على الموقع: $error';
  }

  @override
  String get updateLocation => 'تحديث الموقع';

  @override
  String get surahDuha => 'سورة الضحى';

  @override
  String get descDuha =>
      'ما ودعك ربك وما قلى. رسالة ربانية لكل قلب يشعر بالضيق والحزن.';

  @override
  String get actionGoToDua => 'اذهب للأدعية';

  @override
  String get startTasbeeh => 'ابدأ التسبيح';

  @override
  String get rememberAllah => 'ذكر الله';

  @override
  String get descHappyDhikr =>
      'الحمد لله تزيد النعمة وتبارك في الرزق وتديم السعادة.';

  @override
  String get allahIsNear => 'الله قريب منك';

  @override
  String get descLostDhikr =>
      'الله قريب منك دائماً، يوجهك ويسمع دعاءك إذا ضللت الطريق.';

  @override
  String get rewardForTired => 'أجر التعب';

  @override
  String get descTiredDhikr =>
      'تذكر أن تعبك مأجور، وأن الله لا يحملك فوق طاقتك. استرح بذكر الله.';

  @override
  String get searchHint => 'ابحث في القرآن، الحديث، الأذكار...';

  @override
  String searchQuranSubtitle(String surah, int ayah) {
    return 'القرآن: $surah ($ayah)';
  }

  @override
  String searchHadithSubtitle(String book, String chapter) {
    return 'الحديث: $book - $chapter';
  }

  @override
  String searchAdhkarSubtitle(String category) {
    return 'الأذكار: $category';
  }

  @override
  String get exploreLibrary => 'استكشف المكتبة';

  @override
  String get searchDescription => 'ابحث عن الآيات والأحاديث والأدعية';

  @override
  String get khatmaPlannerTitle => 'مخطط الختمة الذكي';

  @override
  String get khatmaPlannerSubtitle => 'حدد المدة التي ترغب بختم القرآن فيها';

  @override
  String get startKhatma => 'ابدأ الختمة';

  @override
  String get days => 'يوم';

  @override
  String get pagesDaily => 'صفحات يومياً';

  @override
  String get pagesPerPrayer => 'صفحات لكل صلاة';

  @override
  String remainingToday(int count) {
    return 'المتبقي لك اليوم: $count صفحات';
  }

  @override
  String get onTrack => 'أنت على الجدول';

  @override
  String get setupPlan => 'ضبط الخطة';

  @override
  String get cancelPlan => 'إلغاء الخطة';

  @override
  String get manageNotificationSettings => 'إدارة إعدادات الإشعارات';

  @override
  String get manageNotificationSettingsSubtitle =>
      'فتح إعدادات النظام للإشعارات';

  @override
  String get continueYourKhatma => 'واصل ختمـتك';

  @override
  String juzAndSurah(Object juz, Object surah) {
    return 'الجزء $juz - $surah';
  }

  @override
  String get smartSuggestionsForNewPlan => 'اقتراحات ذكية لنظامك الجديد:';

  @override
  String get khatmaInMonth => 'ختمة في شهر';

  @override
  String get oneJuzDaily => '1 جزء يومياً';

  @override
  String get khatmaInTwoMonths => 'ختمة في شهرين';

  @override
  String get fifteenPagesDaily => '15 صفحة يومياً';

  @override
  String pagesRemainingToday(Object count) {
    return 'بقي لك $count صفحات لليوم';
  }

  @override
  String get khatmaHistory => 'سجل الختمات';

  @override
  String get khatmaSettings => 'إعدادات الختمة';

  @override
  String get duaKhatm => 'دعاء ختم القرآن';

  @override
  String get continueReading => 'إكمال القراءة';
}
