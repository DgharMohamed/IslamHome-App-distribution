import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:islamic_library_flutter/presentation/screens/splash_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/home_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/all_reciters_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/reciter_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/quran_text_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/hadith_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/azkar_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/tasbeeh_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/radio_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/live_tv_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/video_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/search_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/prayer_times_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/qibla_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/books_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/downloads_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/favorites_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/player_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/settings_screen.dart';
import 'package:islamic_library_flutter/presentation/screens/all_sections_screen.dart';
import 'package:islamic_library_flutter/presentation/widgets/main_scaffold.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/presentation/providers/locale_provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:islamic_library_flutter/core/services/connectivity_service.dart';
import 'package:islamic_library_flutter/data/services/offline_cache_service.dart';
import 'package:islamic_library_flutter/data/services/quran_playback_service.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow runtime fetching for Google Fonts to avoid missing font errors
  GoogleFonts.config.allowRuntimeFetching = true;

  // 1. Core initialization - keep as minimal as possible
  try {
    await Hive.initFlutter();

    // Await ONLY the absolutely essential services needed for the app to function
    // We do them in parallel for speed.
    debugPrint('🎵 Main: Starting essential initialization...');
    await Future.wait([
      Hive.openBox('settings'),
      Hive.openBox('favorites'),
      Hive.openBox('prayer_times_cache'),
      OfflineCacheService().init(),
      ConnectivityService().init(),
    ]).timeout(const Duration(seconds: 15));

    debugPrint('🎵 Main: Essential services initialized');

    Timer.periodic(const Duration(seconds: 2), (t) {
      debugPrint('💓 Main Isolate Heartbeat: ${DateTime.now().second}s');
    });

    runApp(const ProviderScope(child: IslamicLibraryApp()));

    // 2. Initialize secondary services in background (non-blocking)
    // Move QuranPlaybackService to background initialization to avoid blocking UI
    QuranPlaybackService.initialize()
        .then((_) => debugPrint('🎵 Main: QuranPlaybackService ready'))
        .catchError((e) {
          debugPrint('🎵 Main: QuranPlaybackService error: $e');
        });

    // NotificationService().init().then(
    //   (_) => debugPrint('🔔 Main: Notifications ready'),
    // );
    // PlaybackSessionService.initialize().catchError(
    //   (e) => debugPrint('📦 PlaybackSession error: $e'),
    // );

    // 3. Debug: Check for Hadith assets (non-blocking)
    if (kDebugMode) {
      _debugCheckAssets();
    }
  } catch (e, stackTrace) {
    debugPrint('🔴 Main: Fatal initialization crash: $e');
    debugPrint('$stackTrace');

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper for non-blocking asset check in debug mode
void _debugCheckAssets() {
  rootBundle
      .loadString('AssetManifest.json')
      .then((manifestJson) {
        final manifest = json.decode(manifestJson) as Map<String, dynamic>;
        final hadithAssets = manifest.keys.where(
          (key) => key.contains('assets/data/hadith/'),
        );
        debugPrint('🎵 Main: Found ${hadithAssets.length} hadith assets');
      })
      .catchError((e) {
        debugPrint('🎵 Main: Failed to load AssetManifest: $e');
      });
}

class DebugNavObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      '🚀 NAV: Pushed ${route.settings.name} (${route.settings.arguments})',
    );
  }
}

final _router = GoRouter(
  observers: [DebugNavObserver()],
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/all-sections',
          builder: (context, state) => const AllSectionsScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/all-reciters',
          builder: (context, state) => const AllRecitersScreen(),
        ),
        GoRoute(
          path: '/reciter',
          builder: (context, state) {
            try {
              final reciter = state.extra as Reciter;
              return ReciterScreen(reciter: reciter);
            } catch (e) {
              debugPrint('Error casting reciter: $e');
              return const HomeScreen();
            }
          },
        ),
        GoRoute(
          path: '/quran-text',
          builder: (context, state) {
            final surahNumberStr = state.uri.queryParameters['surah'];
            final surahNumber = surahNumberStr != null
                ? int.tryParse(surahNumberStr)
                : null;
            return QuranTextScreen(initialSurahNumber: surahNumber);
          },
        ),
        GoRoute(
          path: '/hadith',
          builder: (context, state) => const HadithScreen(),
        ),
        GoRoute(
          path: '/azkar',
          builder: (context, state) => const AzkarScreen(),
        ),
        GoRoute(
          path: '/tasbeeh',
          builder: (context, state) => const TasbeehScreen(),
        ),
        GoRoute(
          path: '/radio',
          builder: (context, state) => const RadioScreen(),
        ),
        GoRoute(
          path: '/live-tv',
          builder: (context, state) => const LiveTVScreen(),
        ),
        GoRoute(
          path: '/video',
          builder: (context, state) => const VideoScreen(),
        ),
        GoRoute(
          path: '/prayer-times',
          builder: (context, state) => const PrayerTimesScreen(),
        ),
        GoRoute(
          path: '/qibla',
          builder: (context, state) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/books',
          builder: (context, state) => const BooksScreen(),
        ),
        GoRoute(
          path: '/downloads',
          builder: (context, state) => const DownloadsScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/playlist/import',
          builder: (context, state) {
            final data = state.uri.queryParameters['data'];
            return FavoritesScreen(importData: data);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
        );
      },
    ),
  ],
);

class IslamicLibraryApp extends ConsumerWidget {
  const IslamicLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Islam Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
    );
  }
}
