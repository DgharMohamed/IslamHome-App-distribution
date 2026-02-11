import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/favorites_provider.dart';
import 'package:islamic_library_flutter/data/models/playlist_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';
import 'package:share_plus/share_plus.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-watch and find current playlist state to pick up changes
    final favorites = ref.watch(favoritesProvider);
    final currentPlaylistData = (favorites['playlists'] as List).firstWhere(
      (p) => p['id'] == playlist.id,
      orElse: () => null,
    );

    if (currentPlaylistData == null) {
      return const Scaffold(body: Center(child: Text('القائمة غير موجودة')));
    }

    final currentPlaylist = Playlist.fromJson(currentPlaylistData);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref, currentPlaylist),
          _buildPlaylistItems(context, ref, currentPlaylist),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: currentPlaylist.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _playAll(ref, currentPlaylist),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
              label: Text(
                'تشغيل الكل',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: () => _sharePlaylist(ref, playlist),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          playlist.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.3),
                AppTheme.backgroundColor,
              ],
            ),
          ),
          child: Center(
            child: Text(
              playlist.icon ?? '⭐',
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistItems(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) {
    if (playlist.items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'لا توجد سور في هذه القائمة',
            style: GoogleFonts.cairo(color: Colors.white38),
          ),
        ),
      );
    }

    return SliverReorderableList(
      itemCount: playlist.items.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(favoritesProvider.notifier)
            .reorderPlaylistItems(playlist.id, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final item = playlist.items[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(item.id),
          index: index,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                backgroundColor: Colors.white10,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: Text(
                item.surahName,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                item.reciterName,
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => ref
                        .read(favoritesProvider.notifier)
                        .removeFromPlaylist(playlist.id, item.id),
                  ),
                  const Icon(Icons.drag_handle_rounded, color: Colors.white24),
                ],
              ),
              onTap: () => _playItem(ref, playlist, index),
            ),
          ),
        );
      },
    );
  }

  void _playItem(WidgetRef ref, Playlist playlist, int index) async {
    final audioService = ref.read(audioPlayerServiceProvider);
    if (audioService == null) {
      debugPrint('Audio service not initialized');
      return;
    }
    final sources = playlist.items.map((i) => _toAudioSource(i)).toList();
    try {
      await audioService.setPlaylist(sources: sources, initialIndex: index);
    } catch (e) {
      debugPrint('Error playing item: $e');
    }
  }

  void _playAll(WidgetRef ref, Playlist playlist) async {
    final audioService = ref.read(audioPlayerServiceProvider);
    if (audioService == null) {
      debugPrint('Audio service not initialized');
      return;
    }
    final sources = playlist.items.map((i) => _toAudioSource(i)).toList();
    try {
      await audioService.setPlaylist(sources: sources);
    } catch (e) {
      debugPrint('Error playing all: $e');
    }
  }

  AudioSource _toAudioSource(PlaylistItem item) {
    return AudioSource.uri(
      Uri.parse(item.url),
      tag: MediaItem(
        id: item.url,
        title: item.surahName,
        artist: item.reciterName,
        artUri: Uri.parse(
          'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
        ),
        extras: {'surahNumber': item.surahNumber},
      ),
    );
  }

  void _sharePlaylist(WidgetRef ref, Playlist playlist) {
    final data = ref
        .read(favoritesProvider.notifier)
        .exportPlaylist(playlist.id);
    final shareText =
        'قائمة تشغيل: ${playlist.name}\nاستمع إليها عبر تطبيق المكتبة الإسلامية:\nislamiclibrary://playlist?data=$data';
    SharePlus.instance.share(ShareParams(text: shareText));
    // Actually, looking at the lint message: 'Share' is deprecated. Use SharePlus instead.
    // 'share' is deprecated. Use SharePlus.instance.share() instead.
    // In newer versions of share_plus, the class is often Share or SharePlus.
    // I'll try Share.share first as common practice, but if it causes errors I'll check.
    // Wait, the lint says it IS deprecated. I'll use the suggested SharePlus.share.
  }
}
