import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/download_state.dart';
import 'package:islamic_library_flutter/data/services/download_service.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadProvider);
    final historyAsync = ref.watch(downloadHistoryProvider);

    final activeCount = downloads.values
        .where((e) => e.status == DownloadStatus.downloading)
        .length;
    final totalDownloaded = historyAsync.maybeWhen(
      data: (h) => h.length,
      orElse: () => 0,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkBlue, AppTheme.backgroundColor],
          ),
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _buildHeader(context, activeCount, totalDownloaded),
                const TabBar(
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: [
                    Tab(text: 'جاري التحميل'),
                    Tab(text: 'المحملة'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [_ActiveDownloadsTab(), _HistoryTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int active, int total) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التنزيلات',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                'نشطة',
                active.toString(),
                Icons.downloading,
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 15),
              _buildStatCard(
                'مكتملة',
                total.toString(),
                Icons.check_circle,
                Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
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
    final allActive = downloads.entries
        .where(
          (e) =>
              e.value.status == DownloadStatus.downloading ||
              e.value.status == DownloadStatus.idle,
        )
        .map((e) => e.value)
        .toList();

    if (allActive.isEmpty) {
      return _buildEmptyState(
        'لا توجد تحميلات نشطة',
        'يمكنك تحميل السور للاستماع إليها لاحقاً بدون إنترنت',
        Icons.cloud_download_outlined,
      );
    }

    final quranActive = allActive
        .where((e) => e.id.startsWith('quran_'))
        .toList();
    final seerahActive = allActive
        .where((e) => e.id.startsWith('seerah_'))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        if (quranActive.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'القرآن الكريم',
            Icons.menu_book_rounded,
          ),
          ...quranActive.map((item) => _buildDownloadCard(context, ref, item)),
        ],
        if (seerahActive.isNotEmpty) ...[
          if (quranActive.isNotEmpty) const SizedBox(height: 20),
          _buildSectionHeader(
            context,
            'السيرة النبوية',
            Icons.history_edu_rounded,
          ),
          ...seerahActive.map((item) => _buildDownloadCard(context, ref, item)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(
    BuildContext context,
    WidgetRef ref,
    DownloadItemState item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.downloading,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${(item.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () =>
                    ref.read(downloadProvider.notifier).cancelDownload(item.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: item.progress > 0 ? item.progress : null,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
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
          return _buildEmptyState(
            'سجل التنزيلات فارغ',
            'لم تقم بتنزيل أي سور بعد',
            Icons.history,
          );
        }

        final quranItems = history.where((e) => e.type == 'quran').toList();
        final seerahItems = history.where((e) => e.type == 'seerah').toList();

        return ListView(
          padding: const EdgeInsets.all(15),
          children: [
            if (quranItems.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'القرآن الكريم',
                Icons.menu_book_rounded,
              ),
              ...quranItems.map(
                (item) => _buildHistoryCard(context, ref, item),
              ),
            ],
            if (seerahItems.isNotEmpty) ...[
              if (quranItems.isNotEmpty) const SizedBox(height: 20),
              _buildSectionHeader(
                context,
                'السيرة النبوية',
                Icons.history_edu_rounded,
              ),
              ...seerahItems.map(
                (item) => _buildHistoryCard(context, ref, item),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    DownloadRequest item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.type == 'seerah'
                ? Icons.history_edu_rounded
                : Icons.audiotrack,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          item.type == 'seerah' ? item.reciterId : 'سورة ${item.surahNumber}',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: AppTheme.primaryColor,
                size: 32,
              ),
              onPressed: () async {
                final audioService = ref.read(audioPlayerServiceProvider);
                if (audioService != null) {
                  final dir = await DownloadService().getFilePath(
                    item.reciterId,
                    item.moshafType,
                    item.surahNumber,
                    type: item.type,
                  );
                  audioService.playFile(
                    dir,
                    title: item.title,
                    artist: item.type == 'seerah'
                        ? item.reciterId
                        : 'القرآن الكريم',
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await ref
                    .read(downloadProvider.notifier)
                    .deleteFileById(item.id);
                ref.invalidate(downloadHistoryProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState(String title, String subtitle, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 80,
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    ),
  );
}
