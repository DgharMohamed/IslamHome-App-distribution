import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';

/// Represents a playback session that can be saved and restored
class PlaybackSession {
  final List<QuranVerse> playlist;
  final int currentIndex;
  final Duration currentPosition;
  final bool isPlaying;
  final AudioServiceRepeatMode repeatMode;
  final AudioServiceShuffleMode shuffleMode;

  const PlaybackSession({
    required this.playlist,
    required this.currentIndex,
    required this.currentPosition,
    required this.isPlaying,
    this.repeatMode = AudioServiceRepeatMode.none,
    this.shuffleMode = AudioServiceShuffleMode.none,
  });

  /// Converts to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'playlist': playlist
          .map(
            (v) => {
              'surahNumber': v.surahNumber,
              'surahName': v.surahName,
              'verseNumber': v.verseNumber,
              'arabicText': v.arabicText,
              'audioUrl': v.audioUrl,
              'duration': v.duration.inMilliseconds,
              'translation': v.translation,
            },
          )
          .toList(),
      'currentIndex': currentIndex,
      'currentPosition': currentPosition.inMilliseconds,
      'isPlaying': isPlaying,
      'repeatMode': repeatMode.index,
      'shuffleMode': shuffleMode.index,
    };
  }

  /// Creates from JSON for restoration
  static PlaybackSession fromJson(Map<String, dynamic> json) {
    final playlistJson = json['playlist'] as List<dynamic>;
    final playlist = playlistJson
        .map(
          (v) => QuranVerse(
            surahNumber: v['surahNumber'] as int,
            surahName: v['surahName'] as String,
            verseNumber: v['verseNumber'] as int,
            arabicText: v['arabicText'] as String,
            audioUrl: v['audioUrl'] as String,
            duration: Duration(milliseconds: v['duration'] as int),
            translation: v['translation'] as String?,
          ),
        )
        .toList();

    return PlaybackSession(
      playlist: playlist,
      currentIndex: json['currentIndex'] as int,
      currentPosition: Duration(milliseconds: json['currentPosition'] as int),
      isPlaying: json['isPlaying'] as bool,
      repeatMode: AudioServiceRepeatMode.values[json['repeatMode'] as int],
      shuffleMode: AudioServiceShuffleMode.values[json['shuffleMode'] as int],
    );
  }

  /// Creates a copy with updated values
  PlaybackSession copyWith({
    List<QuranVerse>? playlist,
    int? currentIndex,
    Duration? currentPosition,
    bool? isPlaying,
    AudioServiceRepeatMode? repeatMode,
    AudioServiceShuffleMode? shuffleMode,
  }) {
    return PlaybackSession(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPosition: currentPosition ?? this.currentPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
    );
  }
}
