import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/presentation/widgets/aurora_background.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  String selectedType = 'books';
  String searchQuery = '';
  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final booksAsync = ref.watch(
      booksProvider({'type': selectedType, 'page': currentPage}),
    );

    return Scaffold(
      body: AuroraBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              leading: context.canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 28),
                        onPressed: () => GlobalScaffoldService.openDrawer(),
                      ),
                    ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  selectedType == 'books'
                      ? l10n.booksLibraryTitle
                      : l10n.articlesAndBooksTitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search
                    GlassContainer(
                      borderRadius: 15,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n.searchLibraryHint,
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Switcher
                    Row(
                      children: [
                        _buildTypeChip(l10n.booksLabel, 'books'),
                        const SizedBox(width: 10),
                        _buildTypeChip(l10n.articlesLabel, 'articles'),
                        const SizedBox(width: 10),
                        _buildTypeChip(l10n.audiosLabel, 'audios'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            booksAsync.when(
              data: (books) {
                final filteredBooks = books
                    .where(
                      (b) =>
                          b.title?.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ) ??
                          true,
                    )
                    .toList();

                if (filteredBooks.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(l10n.noSearchResults)),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final book = filteredBooks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassContainer(
                          borderRadius: 15,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (book.attachments != null &&
                                  book.attachments!.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  children: book.attachments!.map((att) {
                                    return ActionChip(
                                      label: Text(
                                        att.size ?? l10n.downloadButton,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      avatar: const Icon(
                                        Icons.download,
                                        size: 14,
                                      ),
                                      backgroundColor: AppTheme.primaryColor
                                          .withValues(alpha: 0.1),
                                      labelStyle: const TextStyle(
                                        color: AppTheme.primaryColor,
                                      ),
                                      onPressed: () async {
                                        if (att.url != null) {
                                          final url = Uri.parse(att.url!);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          }
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: filteredBooks.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text(l10n.errorOccurred(err.toString()))),
              ),
            ),

            // Pagination
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: currentPage > 1
                          ? () => setState(() => currentPage--)
                          : null,
                    ),
                    Text(
                      l10n.pageCount(currentPage),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => currentPage++),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String type) {
    final isActive = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() {
        selectedType = type;
        currentPage = 1;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Cairo',
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
