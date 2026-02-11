import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/data/services/quran_playback_service.dart';

import 'package:islamic_library_flutter/data/models/video_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:async';

// Provider to hold the AudioHandler instance
// Returns null if not yet initialized to avoid blocking UI
final audioHandlerProvider = Provider<AudioHandler?>((ref) {
  if (!QuranPlaybackService.isInitialized) {
    return null;
  }
  return QuranPlaybackService.audioHandler;
});

// Provider to hold the underlying AudioPlayer for UI streams
// Returns null if handler not yet initialized
final playerProvider = Provider<AudioPlayer?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  if (handler == null) return null;
  // Both AudioPlayerHandler and QuranAudioHandler have a player property
  return (handler as dynamic).player;
});

class AudioPlayerService {
  final AudioHandler _handler;
  Timer? _sleepTimer;
  final _sleepTimerController = StreamController<Duration?>.broadcast();
  final _yt = YoutubeExplode();

  AudioPlayerService(this._handler);

  // Expose player and streams for widgets
  AudioPlayer get player => (_handler as dynamic).player;
  Stream<MediaItem?> get mediaItemStream => _handler.mediaItem;

  Future<void> playYoutubeAudio(
    String url, {
    String? title,
    String? artist,
    String? thumbUrl,
  }) async {
    try {
      debugPrint('🎵 Service: playYoutubeAudio called - url: $url');
      final videoId = VideoId.parseVideoId(url);
      if (videoId == null) {
        throw Exception('رابط غير صالح');
      }

      debugPrint('🎵 Service: Fetching YouTube manifest for $videoId');
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly;

      if (audioStreams.isEmpty) {
        throw Exception('لا توجد مسارات صوتية متاحة لهذا المقطع');
      }

      // Fallback Strategy:
      // 1. Try high-quality M4A
      // 2. Try any high-quality audio
      // 3. Try any audio (as last resort)
      final m4aStream = audioStreams
          .where((s) => s.container.name.toLowerCase() == 'm4a')
          .toList();

      final streamInfo = m4aStream.isNotEmpty
          ? m4aStream.withHighestBitrate()
          : audioStreams.withHighestBitrate();

      final streamUrl = streamInfo.url.toString();
      debugPrint(
        '🎵 Service: Resolved ${streamInfo.container.name} stream (${streamInfo.bitrate}): ${streamUrl.substring(0, 30)}...',
      );

      final source = AudioSource.uri(
        Uri.parse(streamUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Mobile Safari/537.36',
          'Referer': 'https://www.youtube.com/',
          'Origin': 'https://www.youtube.com/',
        },
        tag: MediaItem(
          id: url,
          album: 'السيرة النبوية',
          title: title ?? 'مقطع مرئي',
          artist: artist ?? 'الشيخ بدر المشاري',
          artUri: thumbUrl != null ? Uri.parse(thumbUrl) : null,
          displayTitle: title ?? 'مقطع مرئي',
          displaySubtitle: artist ?? 'الشيخ بدر المشاري',
        ),
      );

      debugPrint('🎵 Service: Setting audio source in handler');
      // Set a short timeout for source loading
      // Both AudioPlayerHandler and QuranAudioHandler have setAudioSource method
      await (_handler as dynamic)
          .setAudioSource(source)
          .timeout(const Duration(seconds: 15));

      debugPrint('🎵 Service: Starting playback');
      await _handler.play();
      debugPrint('🎵 Service: playYoutubeAudio completed successfully');
    } catch (e) {
      debugPrint('🎵 Service: Youtube Audio Error: $e');
      if (e is TimeoutException) {
        throw Exception('انتهت مهلة انتظار اتصال البث، يرجى المحاولة مرة أخرى');
      }
      rethrow;
    }
  }

  Future<void> playUrl(
    String url, {
    String? title,
    String? artist,
    String? album,
    String? thumbUrl,
  }) async {
    try {
      debugPrint('🎵 Service: playUrl called - title: $title');
      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          album: album ?? 'المكتبة الصوتية',
          title: title ?? 'تلاوة',
          artist: artist ?? 'شخصية إسلامية',
          artUri: Uri.parse(
            thumbUrl ??
                'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
          ),
          displayTitle: title ?? 'تلاوة',
          displaySubtitle: artist ?? 'شخصية إسلامية',
        ),
      );

      await (_handler as dynamic).setAudioSource(source);
      // Wait a brief moment for the player to be ready
      await Future.delayed(const Duration(milliseconds: 100));
      await _handler.play();
      // Wait after play to ensure notification is shown
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint(
        '🎵 Service: playUrl completed, notification should be visible',
      );
    } catch (e) {
      debugPrint('🎵 Service: Audio Error: $e');
    }
  }

  Future<void> setPlaylist({
    required List<AudioSource> sources,
    int initialIndex = 0,
  }) async {
    try {
      debugPrint(
        '🎵 Service: setPlaylist called with ${sources.length} sources, initialIndex=$initialIndex',
      );
      if (sources.isEmpty) {
        debugPrint('🎵 Service: Empty sources list');
        return;
      }

      final handler = _handler as dynamic;
      debugPrint('🎵 Service: Calling handler.setPlaylist...');
      await handler.setPlaylist(sources, initialIndex: initialIndex);
      debugPrint(
        '🎵 Service: handler.setPlaylist completed, waiting for player to be ready...',
      );

      // Wait longer for the player to be ready and for the notification to register
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint('🎵 Service: Now playing...');
      await _handler.play();

      // Wait after play to ensure notification is shown
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint(
        '🎵 Service: Play command sent, notification should now be visible',
      );
    } catch (e) {
      debugPrint('🎵 Service: Playlist Error: $e');
      debugPrintStack(stackTrace: StackTrace.current);
      rethrow;
    }
  }

  Future<void> playVideoPlaylist({
    required List<VideoModel> videos,
    int initialIndex = 0,
  }) async {
    try {
      debugPrint(
        '🎵 Service: playVideoPlaylist called with ${videos.length} videos, starting at $initialIndex',
      );

      final Map<String, String> reciterImages = {
        'بدر المشاري': 'https://i.ytimg.com/vi/qJwecTUy8PY/maxresdefault.jpg',
        'نواف السالم':
            'https://pbs.twimg.com/profile_images/1542862587086729216/zYQqXqZJ_400x400.jpg',
      };

      final sources = videos
          .where((v) => v.url != null) // Safety check
          .map((v) {
            final reciterImageUrl = reciterImages[v.reciter];

            return AudioSource.uri(
              Uri.parse(v.url!),
              tag: MediaItem(
                id: v.url!,
                album: v.reciter ?? 'السيرة النبوية',
                title: v.title ?? 'مقطع مرئي',
                artist: v.reciter ?? 'الشيخ بدر المشاري',
                artUri: Uri.parse(
                  reciterImageUrl ??
                      v.thumbUrl ??
                      'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
                ),
                displayTitle: v.title ?? 'مقطع مرئي',
                displaySubtitle: v.reciter ?? 'الشيخ بدر المشاري',
              ),
            );
          })
          .toList();

      await setPlaylist(sources: sources, initialIndex: initialIndex);
    } catch (e) {
      debugPrint('🎵 Service: playVideoPlaylist Error: $e');
    }
  }

  Future<void> skipForward() async {
    final current = player.position;
    final duration = player.duration ?? Duration.zero;
    final target = current + const Duration(seconds: 10);
    if (target < duration) {
      await player.seek(target);
    } else {
      await player.seek(duration);
    }
  }

  Future<void> skipBackward() async {
    final current = player.position;
    final target = current - const Duration(seconds: 10);
    if (target > Duration.zero) {
      await player.seek(target);
    } else {
      await player.seek(Duration.zero);
    }
  }

  Future<void> playFile(
    String filePath, {
    String? title,
    String? artist,
  }) async {
    try {
      final source = AudioSource.file(
        filePath,
        tag: MediaItem(
          id: filePath,
          album: 'التنزيلات',
          title: title ?? 'تنزيل',
          artist: artist ?? 'القارئ',
          artUri: Uri.parse(
            'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
          ),
        ),
      );
      (_handler as dynamic).mediaItem.add(source.tag as MediaItem);
      await (_handler as dynamic).setAudioSource(source);
      _handler.play();
    } catch (e) {
      debugPrint('Audio Error (File): $e');
    }
  }

  Future<void> pause() async => await _handler.pause();
  Future<void> resume() async => await _handler.play();
  Future<void> stop() async => await _handler.stop();
  Future<void> seek(Duration position) async => await _handler.seek(position);

  // Shuffle and Repeat
  Future<void> toggleShuffle() async {
    final enable = !(_handler as dynamic).player.shuffleModeEnabled;
    await (_handler as dynamic).player.setShuffleModeEnabled(enable);
  }

  Future<void> toggleRepeat() async {
    switch ((_handler as dynamic).player.loopMode) {
      case LoopMode.off:
        await (_handler as dynamic).player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await (_handler as dynamic).player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await (_handler as dynamic).player.setLoopMode(LoopMode.off);
        break;
    }
  }

  // Sleep Timer
  Stream<Duration?> get sleepTimerStream => _sleepTimerController.stream;

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    var remaining = duration;
    _sleepTimerController.add(remaining);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining -= const Duration(seconds: 1);
      if (remaining.inSeconds <= 0) {
        pause();
        _sleepTimer?.cancel();
        _sleepTimerController.add(null);
      } else {
        _sleepTimerController.add(remaining);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerController.add(null);
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  if (handler == null) return null;
  return AudioPlayerService(handler);
});
