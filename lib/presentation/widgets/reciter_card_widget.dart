import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/presentation/providers/favorites_provider.dart';

class ReciterCardWidget extends ConsumerWidget {
  final Reciter reciter;

  const ReciterCardWidget({super.key, required this.reciter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesProvider);
    final isFavorite = ref
        .read(favoritesProvider.notifier)
        .isFavoriteReciter(reciter.id?.toString() ?? '');

    return GestureDetector(
      onTap: () {
        debugPrint('🎵 ReciterCard: Tapping on ${reciter.name}');
        context.push('/reciter', extra: reciter);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.surfaceColor,
              AppTheme.darkBlue.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Border Pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: CustomPaint(
                  painter: _GeometricBorderPainter(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/reciters/${reciter.id}.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reciter Name
                        Text(
                          reciter.name ??
                              AppLocalizations.of(context)!.unknownName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Mushaf Count
                        Row(
                          children: [
                            Icon(
                              Icons.library_books_rounded,
                              size: 14,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${reciter.moshaf?.length ?? 0} ${AppLocalizations.of(context)!.mushafCount(1).split(' ').last}',
                              style: GoogleFonts.cairo(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Favorite Button
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavoriteReciter(reciter);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFavorite
                            ? Colors.red.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFavorite
                              ? Colors.red.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Geometric Border Pattern
class _GeometricBorderPainter extends CustomPainter {
  final Color color;

  _GeometricBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw corner ornaments (small diamonds)
    final cornerSize = 6.0;

    // Top-left
    _drawDiamond(canvas, paint, const Offset(12, 12), cornerSize);
    // Top-right
    _drawDiamond(canvas, paint, Offset(size.width - 12, 12), cornerSize);
    // Bottom-left
    _drawDiamond(canvas, paint, Offset(12, size.height - 12), cornerSize);
    // Bottom-right
    _drawDiamond(
      canvas,
      paint,
      Offset(size.width - 12, size.height - 12),
      cornerSize,
    );
  }

  void _drawDiamond(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
