import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';
import 'package:islamic_library_flutter/data/services/download_service.dart';
import 'package:islamic_library_flutter/presentation/providers/download_state.dart';

class DownloadButton extends ConsumerStatefulWidget {
  final Reciter reciter;
  final Moshaf moshaf;
  final Surah surah;
  final Color? color;

  const DownloadButton({
    super.key,
    required this.reciter,
    required this.moshaf,
    required this.surah,
    this.color,
  });

  @override
  ConsumerState<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<DownloadButton> {
  bool _isDownloaded = false;
  bool _isLoadingCheck = true;
  String get _id =>
      'quran_${widget.reciter.id}_${widget.moshaf.moshafType}_${widget.surah.number}';

  @override
  void initState() {
    super.initState();
    _checkFileStatus();
  }

  Future<void> _checkFileStatus() async {
    final notifier = ref.read(downloadProvider.notifier);
    final exists = await notifier.isDownloaded(
      widget.reciter,
      widget.moshaf,
      widget.surah,
    );
    if (mounted) {
      setState(() {
        _isDownloaded = exists;
        _isLoadingCheck = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProvider);
    final itemState = downloadState[_id];

    // 1. If actively downloading/queued/failed in this session
    if (itemState != null) {
      switch (itemState.status) {
        case DownloadStatus.idle: // Queued?
        case DownloadStatus.downloading:
          return SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: itemState.progress > 0 ? itemState.progress : null,
                  strokeWidth: 2,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
                Icon(
                  Icons.close,
                  size: 14,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
              ],
            ),
          );
        case DownloadStatus.completed:
          // Update local state so if provider gets cleared (e.g. app restart) we still know
          // Actually, if completed, we just show checked.
          return Icon(
            Icons.check_circle,
            color: widget.color ?? Theme.of(context).primaryColor,
          );
        case DownloadStatus.failed:
          return IconButton(
            icon: Icon(Icons.error_outline, color: Colors.red),
            onPressed: () => _startDownload(),
          );
        case DownloadStatus.canceled:
          // Fall back to idle check
          break;
      }
    }

    // 2. Initial Loading Check
    if (_isLoadingCheck) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // 3. Checked File Status
    if (_isDownloaded) {
      return Icon(
        Icons.check_circle_outline,
        color: widget.color ?? Theme.of(context).primaryColor,
      );
    }

    // 4. Idle / Not Downloaded
    return IconButton(
      icon: Icon(
        Icons.download_rounded,
        color: widget.color ?? Theme.of(context).primaryColor,
      ),
      onPressed: _startDownload,
    );
  }

  void _startDownload() {
    ref
        .read(downloadProvider.notifier)
        .startDownload(
          reciter: widget.reciter,
          moshaf: widget.moshaf,
          surah: widget.surah,
        );
  }
}
