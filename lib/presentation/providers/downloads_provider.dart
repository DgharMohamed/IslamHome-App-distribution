import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsNotifier extends AsyncNotifier<List<FileSystemEntity>> {
  @override
  Future<List<FileSystemEntity>> build() async {
    return _loadDownloads();
  }

  Future<List<FileSystemEntity>> _loadDownloads() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${directory.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    final files = downloadsDir.listSync();
    return files;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDownloads());
  }

  Future<void> deleteFile(FileSystemEntity file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error (log it if needed)
    } finally {
      // Always refresh the list to ensure UI matches file system
      await refresh();
    }
  }

  Future<void> downloadFile(String url, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final savePath = '${downloadsDir.path}/$filename';
      final file = File(savePath);

      if (await file.exists()) {
        return; // Already downloaded
      }

      await Dio().download(url, savePath);
      await refresh();
    } catch (e) {
      throw Exception('Failed to download: $e');
    }
  }
}

final downloadsProvider =
    AsyncNotifierProvider<DownloadsNotifier, List<FileSystemEntity>>(() {
      return DownloadsNotifier();
    });
