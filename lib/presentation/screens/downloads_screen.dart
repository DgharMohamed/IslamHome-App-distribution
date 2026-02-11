import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/download_state.dart';
import 'package:islamic_library_flutter/data/services/download_service.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التنزيلات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'جاري التحميل'),
              Tab(text: 'المحملة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ActiveDownloadsTab(), _HistoryTab()],
        ),
      ),
    );
  }
}

class _ActiveDownloadsTab extends ConsumerWidget {
  const _ActiveDownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadProvider);
    final activeDownloads = downloads.entries
        .where(
          (e) =>
              e.value.status == DownloadStatus.downloading ||
              e.value.status == DownloadStatus.idle,
        )
        .toList();

    if (activeDownloads.isEmpty) {
      return const Center(child: Text('لا توجد تحميلات نشطة حالياً'));
    }

    return ListView.builder(
      itemCount: activeDownloads.length,
      itemBuilder: (context, index) {
        final item = activeDownloads[index].value;
        // We need title, but state only has ID/Progress.
        // Ideally state should have title too.
        // For now, ID contains some info Reciter_Moshaf_Number.
        // But we can't reconstruct title easily without passing it to state.
        // Let's rely on extracting from ID or just showing "Surah X".
        // Better: Update DownloadItemState to include title.
        // Since I can't easily update state without refactoring service->state flow again,
        // let's try to get info from ID or check if we can improve this later.
        // Wait, DownloadRequest has title.
        // I can perhaps fetch title from the active requests in service?
        // Or updated DownloadItemState.
        // For V1, I'll display ID or a placeholder if title is missing.
        // Actually, let's update DownloadItemState to include title to be specific.
        return ListTile(
          leading: const Icon(Icons.downloading),
          title: Text(item.title),
          subtitle: LinearProgressIndicator(
            value: item.progress > 0 ? item.progress : null,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              ref.read(downloadProvider.notifier).cancelDownload(item.id);
            },
          ),
        );
      },
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(downloadHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('سجل التحميلات فارغ'));
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return ListTile(
              leading: const Icon(Icons.audiotrack),
              title: Text(item.title),
              subtitle: Text('سورة ${item.surahNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await ref
                      .read(downloadProvider.notifier)
                      .deleteFileById(item.id);
                  ref.invalidate(downloadHistoryProvider);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
    );
  }
}
