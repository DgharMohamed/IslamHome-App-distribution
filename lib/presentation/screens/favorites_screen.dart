import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/favorites_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';

import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:islamic_library_flutter/presentation/screens/playlists_screen.dart';
import 'package:islamic_library_flutter/data/models/playlist_model.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  final String? importData;
  const FavoritesScreen({super.key, this.importData});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.importData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(favoritesProvider.notifier).importPlaylist(widget.importData!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استيراد قائمة التشغيل بنجاح')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoritesProvider);
    final favoriteReciters = favorites['reciters']!;
    final favoriteSurahs = favorites['surahs']!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Gradient Header
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: context.canPop()
                        ? IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => context.pop(),
                          )
                        : Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () =>
                                  GlobalScaffoldService.openDrawer(),
                            ),
                          ),
                  ),
                  Column(
                    children: [
                      Text(
                        l10n.favoritesTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: AppTheme.primaryColor,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        tabs: [
                          Tab(text: l10n.reciters),
                          Tab(text: l10n.surahs),
                          const Tab(text: 'قوائم التشغيل'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildRecitersList(context, favoriteReciters),
                  _buildSurahsList(context, favoriteSurahs),
                  const PlaylistsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecitersList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(
        l10n.noFavoriteReciters,
        Icons.person_outline_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final reciter = Reciter.fromJson(items[index]);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            onTap: () => context.push('/reciter', extra: reciter),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                reciter.name?[0] ?? '',
                style: GoogleFonts.cairo(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              reciter.name ?? '',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: AppTheme.primaryColor),
              onPressed: () => ref
                  .read(favoritesProvider.notifier)
                  .toggleFavoriteReciter(reciter),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahsList(BuildContext context, List<dynamic> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _buildEmptyState(l10n.noFavoriteSurahs, Icons.menu_book_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white10,
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              item['surah_name'] ?? '',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              item['reciter_name'] ?? '',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
            ),
            onTap: () async {
              final sources = items.map((s) {
                return AudioSource.uri(
                  Uri.parse(s['url']),
                  tag: MediaItem(
                    id: s['url'],
                    title: s['surah_name'] ?? l10n.surahName(''),
                    artist: s['reciter_name'] ?? l10n.reciterName(''),
                    artUri: Uri.parse(
                      'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
                    ),
                    extras: {'surahNumber': s['surah_number']},
                  ),
                );
              }).toList();

              try {
                final audioService = ref.read(audioPlayerServiceProvider);
                if (audioService == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'خدمة الصوت لم تكتمل بعد، يرجى المحاولة مرة أخرى',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  return;
                }
                await audioService.setPlaylist(
                  sources: sources,
                  initialIndex: index,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'خطأ في تشغيل القائمة: $e',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.playlist_add, color: Colors.white38),
                  onPressed: () => _showPlaylistSelector(context, item),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    final reciter = Reciter(
                      id: int.tryParse(item['reciter_id'].toString()),
                      name: item['reciter_name'],
                    );
                    final dummySurah = _DummySurah(
                      number: item['surah_number'] ?? 0,
                      name: item['surah_name'] ?? '',
                    );
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavoriteSurah(dummySurah, reciter);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaylistSelector(BuildContext context, dynamic item) {
    final favorites = ref.read(favoritesProvider);
    final playlists = (favorites['playlists'] as List)
        .map((p) => Playlist.fromJson(p))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'إضافة إلى قائمة تشغيل',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'لا توجد قوائم تشغيل. أنشئ واحدة من قسم المفضلات.',
                  style: GoogleFonts.cairo(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: Text(
                        playlist.icon ?? '⭐',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        playlist.name,
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                      onTap: () {
                        final reciter = Reciter(
                          id: int.tryParse(item['reciter_id'].toString()),
                          name: item['reciter_name'],
                        );
                        final surah = _DummySurah(
                          number: item['surah_number'] ?? 0,
                          name: item['surah_name'] ?? '',
                        );
                        ref
                            .read(favoritesProvider.notifier)
                            .addToPlaylist(
                              playlist.id,
                              surah,
                              reciter,
                              item['url'],
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تمت الإضافة إلى ${playlist.name}',
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.cairo(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DummySurah {
  final int number;
  final String name;
  _DummySurah({required this.number, required this.name});
}
