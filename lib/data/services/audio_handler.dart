import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Robust AudioHandler for music-player-like behavior and reliable notifications
class AudioPlayerHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final _player = AudioPlayer();
  late StreamSubscription<PlaybackEvent> _playbackEventSubscription;
  late StreamSubscription<SequenceState?> _sequenceStateSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;

  // Ensure initialization is complete before allowing playback
  late final Future<void> _initComplete;

  AudioPlayerHandler() {
    debugPrint('🎵 AudioHandler: Initializing...');
    _initComplete = _init();
  }

  AudioPlayer get player => _player;

  Future<void> _init() async {
    // Set initial playback state - THIS IS CRITICAL for notifications to work
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.playPause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    // Configure audio session for music playback
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Handle audio interruptions (e.g., phone calls)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // Handle becoming noisy (e.g., headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        pause();
      });
    } catch (e) {
      debugPrint('🎵 AudioHandler: Audio session config error: $e');
    }

    // Pass all playback events from just_audio through to audio_service
    _playbackEventSubscription = _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace st) {
        debugPrint('🎵 AudioHandler: Playback error: $e');
      },
    );

    // Listen to changes in the current media item
    _sequenceStateSubscription = _player.sequenceStateStream.listen((state) {
      final sequence = state?.sequence ?? [];
      final index = state?.currentIndex;
      if (sequence.isEmpty || index == null || index >= sequence.length) return;

      final source = sequence[index];
      final tag = source.tag;
      if (tag is MediaItem) {
        final item = tag.copyWith(duration: _player.duration);
        mediaItem.add(item);
        debugPrint(
          '🎵 AudioHandler: Now playing: ${item.title} by ${item.artist}',
        );
      }
    });

    // Listen for index changes to update the queue index
    _currentIndexSubscription = _player.currentIndexStream.listen((index) {
      if (index != null) {
        _broadcastState(_player.playbackEvent);
      }
    });

    // Handle duration changes specifically to update mediaItem
    _durationSubscription = _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item != null && duration != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    });

    debugPrint('🎵 AudioHandler: Initialization complete');
  }

  /// Broadcasts the current player state to the system notification
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = _player.currentIndex ?? 0;

    debugPrint(
      '🎵 AudioHandler._broadcastState: playing=$playing, queueIndex=$queueIndex, mediaItem=${mediaItem.value?.title}',
    );

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.playPause,
          MediaAction.stop,
          MediaAction.play,
          MediaAction.pause,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: queueIndex,
      ),
    );
  }

  @override
  Future<void> play() async {
    debugPrint(
      '🎵 AudioHandler: play() called, waiting for init to complete...',
    );
    await _initComplete;
    debugPrint('🎵 AudioHandler: Init complete, now playing');
    await _player.play();
  }

  @override
  Future<void> pause() async {
    debugPrint('🎵 AudioHandler: pause() called');
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint('🎵 AudioHandler: seek() to $position');
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    debugPrint('🎵 AudioHandler: stop() called');
    await _player.stop();
    // Reset position
    await _player.seek(Duration.zero);
    // Broadcast stopped state
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    debugPrint('🎵 AudioHandler: skipToNext() called');
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    debugPrint('🎵 AudioHandler: skipToPrevious() called');
    await _player.seekToPrevious();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    debugPrint('🎵 AudioHandler: skipToQueueItem($index)');
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _player.setShuffleModeEnabled(
      shuffleMode == AudioServiceShuffleMode.all,
    );
  }

  // Custom methods for setting sources while ensuring mediaItem is updated
  Future<void> setAudioSource(AudioSource source) async {
    debugPrint('🎵 AudioHandler: setAudioSource() - waiting for init...');
    await _initComplete;
    debugPrint('🎵 AudioHandler: setAudioSource()');
    if (source is UriAudioSource) {
      final item = source.tag as MediaItem?;
      if (item != null) {
        debugPrint(
          '🎵 AudioHandler: Setting mediaItem: ${item.title} by ${item.artist}',
        );
        mediaItem.add(item);
        queue.add([item]);
      } else {
        debugPrint(
          '🎵 AudioHandler: WARNING - No mediaItem tag found in source',
        );
      }
    }
    await _player.setAudioSource(source);
  }

  Future<void> setPlaylist(
    List<AudioSource> sources, {
    int initialIndex = 0,
  }) async {
    debugPrint('🎵 AudioHandler: setPlaylist() - waiting for init...');
    await _initComplete;
    debugPrint(
      '🎵 AudioHandler: setPlaylist() with ${sources.length} items, starting at $initialIndex',
    );

    // Build queue from sources
    final mediaItems = sources
        .map((s) => s is UriAudioSource ? s.tag as MediaItem? : null)
        .whereType<MediaItem>()
        .toList();

    // Update queue
    queue.add(mediaItems);

    // Update current media item
    if (initialIndex < mediaItems.length) {
      final item = mediaItems[initialIndex];
      debugPrint(
        '🎵 AudioHandler: Setting initial mediaItem: ${item.title} by ${item.artist}',
      );
      mediaItem.add(item);
    }

    // Create concatenating audio source
    final playlist = ConcatenatingAudioSource(
      children: sources,
      useLazyPreparation: true,
    );

    await _player.setAudioSource(playlist, initialIndex: initialIndex);
    debugPrint('🎵 AudioHandler: Playlist set successfully');
  }

  @override
  Future<void> onTaskRemoved() async {
    debugPrint('🎵 AudioHandler: onTaskRemoved()');
    // Only stop if not playing to allow background playback
    if (!_player.playing) {
      await stop();
    }
  }

  Future<void> dispose() async {
    debugPrint('🎵 AudioHandler: dispose()');
    await _playbackEventSubscription.cancel();
    await _sequenceStateSubscription.cancel();
    await _durationSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _player.dispose();
  }
}
