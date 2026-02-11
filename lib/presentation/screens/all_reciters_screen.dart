import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/presentation/widgets/reciter_card_widget.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';

class AllRecitersScreen extends ConsumerStatefulWidget {
  const AllRecitersScreen({super.key});

  @override
  ConsumerState<AllRecitersScreen> createState() => _AllRecitersScreenState();
}

class _AllRecitersScreenState extends ConsumerState<AllRecitersScreen> {
  int? selectedRewayah;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recitersAsync = ref.watch(recitersProvider);
    final rewayatAsync = ref.watch(rewayatProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(context, l10n),

            // Search Bar
            _buildSearchBar(l10n),

            // Rewayat Filter
            rewayatAsync.when(
              data: (rewayat) => _buildRewayatFilter(rewayat),
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Reciters Grid
            Expanded(
              child: recitersAsync.when(
                data: (reciters) => _buildRecitersGrid(reciters, l10n),
                loading: () => _buildLoadingState(),
                error: (err, _) => _buildErrorState(err, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back/Menu Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: IconButton(
              icon: Icon(
                context.canPop() ? Icons.arrow_back : Icons.menu_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  GlobalScaffoldService.openDrawer();
                }
              },
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.allRecitersTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر القارئ المفضل لديك',
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        borderRadius: 16,
        opacity: 0.05,
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'ابحث عن قارئ...',
            hintStyle: GoogleFonts.cairo(color: Colors.white38),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildRewayatFilter(List<dynamic> rewayat) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rewayat.length,
        itemBuilder: (context, index) {
          final riwaya = rewayat[index];
          final isActive = selectedRewayah == riwaya.id;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedRewayah = isActive ? null : riwaya.id;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primaryColor.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    riwaya.name ?? '',
                    style: GoogleFonts.cairo(
                      color: isActive ? AppTheme.primaryColor : Colors.white70,
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecitersGrid(List<dynamic> reciters, AppLocalizations l10n) {
    final filtered = reciters.where((r) {
      final matchRewayah =
          selectedRewayah == null ||
          (r.moshaf?.any(
                (m) =>
                    m.moshafType == selectedRewayah ||
                    (m.moshafType != null &&
                        (m.moshafType! ~/ 10) == selectedRewayah),
              ) ??
              false);

      final matchSearch =
          searchQuery.isEmpty ||
          (r.name?.toLowerCase().contains(searchQuery) ?? false);

      return matchRewayah && matchSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات أخرى',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    // تحسين التخطيط للشاشات المختلفة
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد عدد الأعمدة بناءً على عرض الشاشة
        int crossAxisCount = 1; // Single column for horizontal cards
        double childAspectRatio = 3.5; // Wide horizontal cards

        if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 3.2;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return ReciterCardWidget(reciter: filtered[index]);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object err, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}
