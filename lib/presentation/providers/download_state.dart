import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/data/services/download_service.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';

// State for a single download item
class DownloadItemState {
  final String id;
  final String title;
  final String url;
  final double progress;
  final DownloadStatus status;

  DownloadItemState({
    required this.id,
    required this.title,
    required this.url,
    this.progress = 0.0,
    this.status = DownloadStatus.idle,
  });

  DownloadItemState copyWith({double? progress, DownloadStatus? status}) {
    return DownloadItemState(
      id: id,
      title: title,
      url: url,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}

// Map of ID -> DownloadItemState
class DownloadNotifier extends Notifier<Map<String, DownloadItemState>> {
  final DownloadService _downloadService = DownloadService();
  // We need to keep track of requests metadata for updates if not in state?
  // Actually, if we init state from active downloads in service, we might need to fetch them.
  // For now, assume state is transient or rebuilt from service.
  // Service doesn't expose active requests easily yet.
  // Let's stick to local state management for now.

  @override
  Map<String, DownloadItemState> build() {
    _init();
    return {};
  }

  void _init() {
    _downloadService.init();
    _downloadService.onProgress = (id, progress, status) {
      if (state.containsKey(id)) {
        _updateState(id, progress, status);
      }
    };
  }

  void _updateState(String id, double progress, DownloadStatus status) {
    if (!state.containsKey(id)) return;

    state = {
      ...state,
      id: state[id]!.copyWith(progress: progress, status: status),
    };
  }

  // Helper to add initially
  void _addState(String id, String title, String url) {
    state = {
      ...state,
      id: DownloadItemState(
        id: id,
        title: title,
        url: url,
        status: DownloadStatus.idle,
      ),
    };
  }

  String _generateId(String reciterId, String moshafType, int surahNumber) {
    return '${reciterId}_${moshafType}_$surahNumber';
  }

  Future<void> startDownload({
    required Reciter reciter,
    required Moshaf moshaf,
    required Surah surah,
  }) async {
    final id = _generateId(
      reciter.id.toString(),
      moshaf.moshafType.toString(),
      surah.number!,
    );

    String baseUrl = moshaf.server!;
    if (!baseUrl.endsWith('/')) baseUrl += '/';
    final paddedSurah = surah.number.toString().padLeft(3, '0');
    final url = '$baseUrl$paddedSurah.mp3';
    final title = 'سورة ${surah.name}';

    _downloadService.addToQueue(
      url: url,
      reciterId: reciter.id.toString(),
      moshafType: moshaf.moshafType.toString(),
      surahNumber: surah.number!,
      title: title,
      id: id,
    );

    _addState(id, title, url);
  }

  Future<void> downloadAll({
    required Reciter reciter,
    required Moshaf moshaf,
    required List<Surah> surahs,
  }) async {
    for (final surah in surahs) {
      final id = _generateId(
        reciter.id.toString(),
        moshaf.moshafType.toString(),
        surah.number!,
      );
      if (state.containsKey(id) &&
          state[id]!.status == DownloadStatus.downloading) {
        continue;
      }
      await startDownload(reciter: reciter, moshaf: moshaf, surah: surah);
    }
  }

  void cancelDownload(String id) {
    if (state.containsKey(id)) {
      _downloadService.cancelDownload(state[id]!.url);
    }
  }

  Future<bool> isDownloaded(Reciter reciter, Moshaf moshaf, Surah surah) async {
    return _downloadService.isFileDownloaded(
      reciter.id.toString(),
      moshaf.moshafType.toString(),
      surah.number!,
    );
  }

  Future<void> deleteFile(Reciter reciter, Moshaf moshaf, Surah surah) async {
    await _downloadService.deleteDownload(
      reciter.id.toString(),
      moshaf.moshafType.toString(),
      surah.number!,
    );
    final id = _generateId(
      reciter.id.toString(),
      moshaf.moshafType.toString(),
      surah.number!,
    );
    await _downloadService.removeFromHistory(id);

    if (state.containsKey(id)) {
      final newState = Map<String, DownloadItemState>.from(state);
      newState.remove(id);
      state = newState;
    }
  }

  Future<void> deleteFileById(String id) async {
    // Deletion by ID requires parsing ID or looking up history.
    // ID format: reciterId_moshafType_surahNumber
    final parts = id.split('_');
    if (parts.length == 3) {
      await _downloadService.deleteDownload(
        parts[0],
        parts[1],
        int.parse(parts[2]),
      );
      await _downloadService.removeFromHistory(id);

      if (state.containsKey(id)) {
        final newState = Map<String, DownloadItemState>.from(state);
        newState.remove(id);
        state = newState;
      }
    }
  }
}

final downloadProvider =
    NotifierProvider<DownloadNotifier, Map<String, DownloadItemState>>(
      DownloadNotifier.new,
    );

final downloadHistoryProvider = FutureProvider<List<DownloadRequest>>((
  ref,
) async {
  // Watch downloadProvider to refresh history when downloads change?
  // Or just refresh manually when entering screen.
  // For auto-refresh on completion:
  ref.watch(downloadProvider);
  // This might trigger too often (on every progress tick).
  // Better to just fetch once and have a refresh mechanism.
  return DownloadService().getDownloadedHistory();
});
