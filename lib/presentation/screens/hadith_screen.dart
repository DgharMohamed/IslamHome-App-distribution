import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  String? selectedBookKey;
  String? selectedBookName;
  int currentPage = 1;
  static const int perPage = 20;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(hadithBooksProvider);
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180.0,
          pinned: true,
          backgroundColor: AppTheme.backgroundColor,
          leading: selectedBookKey != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    selectedBookKey = null;
                    selectedBookName = null;
                    currentPage = 1;
                  }),
                )
              : (context.canPop()
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      )
                    : Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu_rounded, size: 28),
                          onPressed: () => GlobalScaffoldService.openDrawer(),
                        ),
                      )),
          flexibleSpace: FlexibleSpaceBar(
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
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          selectedBookName ?? l10n.hadithBooks,
                          style: GoogleFonts.cairo(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (selectedBookKey != null)
                    Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() {
                          selectedBookKey = null;
                          selectedBookName = null;
                          currentPage = 1;
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (selectedBookKey == null)
          booksAsync.when(
            data: (books) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 2
                      : 1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: MediaQuery.of(context).size.width > 600
                      ? 3.2
                      : 3.5,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = books[index];
                  final isAvailable = (book.available ?? 0) > 0;

                  return GestureDetector(
                    onTap: isAvailable
                        ? () => setState(() {
                            selectedBookKey = book.id;
                            selectedBookName = book.nameAr ?? book.name;
                          })
                        : null,
                    child: Opacity(
                      opacity: isAvailable ? 1.0 : 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isAvailable
                                ? [
                                    AppTheme.surfaceColor,
                                    AppTheme.surfaceColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ]
                                : [
                                    AppTheme.surfaceColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    AppTheme.surfaceColor.withValues(
                                      alpha: 0.2,
                                    ),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomPaint(
                          painter: _GeometricBorderPainter(
                            color: isAvailable
                                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isAvailable
                                          ? [
                                              AppTheme.primaryColor.withValues(
                                                alpha: 0.2,
                                              ),
                                              AppTheme.primaryColor.withValues(
                                                alpha: 0.1,
                                              ),
                                            ]
                                          : [
                                              Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                              Colors.white.withValues(
                                                alpha: 0.02,
                                              ),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getBookIcon(book.id ?? ''),
                                    color: isAvailable
                                        ? AppTheme.primaryColor
                                        : Colors.white38,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        book.nameAr ?? book.name ?? '',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: isAvailable
                                              ? Colors.white
                                              : Colors.white60,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (isAvailable)
                                        Row(
                                          children: [
                                            Text(
                                              l10n.hadithCount(
                                                book.available ?? 0,
                                              ),
                                              style: GoogleFonts.cairo(
                                                fontSize: 13,
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (_isLocalBook(
                                              book.id ?? '',
                                            )) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: AppTheme.primaryColor
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .offline_pin_outlined,
                                                      size: 10,
                                                      color:
                                                          AppTheme.primaryColor,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'متاح محلياً',
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 9,
                                                        color: AppTheme
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                      else
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.lock_outline,
                                              size: 14,
                                              color: Colors.white38,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'قريبًا',
                                              style: GoogleFonts.cairo(
                                                fontSize: 13,
                                                color: Colors.white54,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                if (isAvailable)
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: books.length),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
            error: (err, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          )
        else
          ref
              .watch(hadithsProvider(selectedBookKey!))
              .when(
                data: (hadiths) {
                  if (hadiths.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          l10n.noHadithsAvailableOffline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ),
                    );
                  }

                  final start = (currentPage - 1) * perPage;
                  final end = start + perPage;
                  final pagedHadiths = hadiths.sublist(
                    start,
                    end > hadiths.length ? hadiths.length : end,
                  );

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final hadith = pagedHadiths[index];
                            return _buildHadithCard(hadith, start + index + 1);
                          }, childCount: pagedHadiths.length),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildPagination(hadiths.length),
                      ),
                    ],
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
      ],
    );
  }

  Widget _buildHadithCard(HadithModel hadith, int actualNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceColor,
            AppTheme.surfaceColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_quote,
                        size: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${hadith.number ?? actualNumber}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    size: 22,
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              hadith.arab ?? '',
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 22,
                height: 2.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hadith.english != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hadith.english!,
                style: GoogleFonts.tajawal(fontSize: 15, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildGradeBadge(hadith.grade),
          if (hadith.narrator != null ||
              hadith.book != null ||
              hadith.chapter != null)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hadith.narrator != null)
                    _buildMetadataRow(
                      Icons.person_outline,
                      'الراوي',
                      hadith.narrator!,
                    ),
                  if (hadith.book != null)
                    _buildMetadataRow(
                      Icons.menu_book_outlined,
                      'الكتاب',
                      hadith.book!,
                    ),
                  if (hadith.chapter != null)
                    _buildMetadataRow(
                      Icons.bookmark_outline,
                      'الباب',
                      hadith.chapter!,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradeBadge(String? grade) {
    if (grade == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getGradeColor(grade).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getGradeColor(grade).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              grade,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: _getGradeColor(grade),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    final g = grade.toLowerCase();
    if (g.contains('sahih')) return Colors.green;
    if (g.contains('hasan')) return Colors.teal;
    if (g.contains('daif')) return Colors.orange;
    return AppTheme.primaryColor;
  }

  Widget _buildPagination(int totalCount) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage > 1
                ? () => setState(() => currentPage--)
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            l10n.page(currentPage),
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentPage * perPage) < totalCount
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  bool _isLocalBook(String id) {
    const localBooks = [
      'bukhari',
      'muslim',
      'abudawud',
      'tirmidhi',
      'nasai',
      'ibnmajah',
      'malik',
      'nawawi',
      'ara-bukhari',
      'ara-muslim',
      'ara-abudawud',
      'ara-tirmidhi',
      'ara-nasai',
      'ara-ibnmajah',
      'ara-malik',
    ];
    return localBooks.contains(id);
  }

  IconData _getBookIcon(String bookId) {
    switch (bookId) {
      case 'bukhari':
        return Icons.menu_book_rounded;
      case 'muslim':
        return Icons.auto_stories_rounded;
      case 'abudawud':
        return Icons.import_contacts_rounded;
      case 'tirmidhi':
        return Icons.book_rounded;
      case 'nasai':
        return Icons.library_books_rounded;
      case 'ibnmajah':
        return Icons.chrome_reader_mode_rounded;
      case 'malik':
        return Icons.menu_book_outlined;
      case 'nawawi':
        return Icons.star_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.white60,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Geometric Border Painter for Islamic pattern
class _GeometricBorderPainter extends CustomPainter {
  final Color color;

  _GeometricBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const cornerSize = 20.0;

    // Top-left corner
    canvas.drawLine(const Offset(0, cornerSize), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(cornerSize, 0), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerSize, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height - cornerSize),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerSize, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - cornerSize, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerSize),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
