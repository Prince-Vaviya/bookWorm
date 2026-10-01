import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'reading_progress_bar.dart';
import 'rating_stars.dart';

enum BookCardDisplayMode { grid, list, compact, hero }

class BookCard extends StatelessWidget {
  final Book book;
  final BookCardDisplayMode displayMode;
  final VoidCallback onTap;
  final VoidCallback? onResumeReading;

  const BookCard({
    super.key,
    required this.book,
    this.displayMode = BookCardDisplayMode.grid,
    required this.onTap,
    this.onResumeReading,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case BookCardDisplayMode.hero:
        return _buildHeroCard(context);
      case BookCardDisplayMode.list:
        return _buildListCard(context);
      case BookCardDisplayMode.compact:
        return _buildCompactCard(context);
      case BookCardDisplayMode.grid:
        return _buildGridCard(context);
    }
  }

  Widget _buildHeroCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryIndigo,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryIndigo.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover with tactile 3D effect
                Hero(
                  tag: 'book-cover-${book.id}',
                  child: Container(
                    width: 90,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryLightAmber,
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primaryAmber,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'CURRENTLY READING',
                          style: AppTypography.labelSmall(
                            color: AppColors.primaryLightAmber,
                          ).copyWith(letterSpacing: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSmall(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.primaryLightAmber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${book.estimatedRemainingMinutes} mins left',
                            style: AppTypography.labelSmall(
                              color: AppColors.primaryLightAmber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chapter 1 • Page ${book.currentPage} of ${book.totalPages}',
                  style: AppTypography.labelSmall(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${(book.progressPercentage * 100).toInt()}%',
                  style: AppTypography.labelMedium(
                    color: AppColors.primaryLightAmber,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ReadingProgressBar(
              progress: book.progressPercentage,
              height: 6,
              activeColor: AppColors.primaryAmber,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResumeReading ?? onTap,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('RESUME READING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryIndigo.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 2 / 2.7,
                    child: Image.network(
                      book.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceRecessed,
                        child: const Icon(Icons.book, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                if (book.isFavorite)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge().copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(color: AppColors.textMuted)
                  .copyWith(fontSize: 11),
            ),
            const SizedBox(height: 4),
            if (book.shelfStatus == ShelfStatus.currentlyReading) ...[
              ReadingProgressBar(
                progress: book.progressPercentage,
                height: 4,
              ),
              const SizedBox(height: 3),
              Text(
                '${(book.progressPercentage * 100).toInt()}% read',
                style: AppTypography.labelSmall(color: AppColors.primaryAmber)
                    .copyWith(fontSize: 10),
              ),
            ] else ...[
              RatingStars(rating: book.rating, iconSize: 11),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryIndigo.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 86,
                child: Image.network(
                  book.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceRecessed,
                    child: const Icon(Icons.book, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.genre,
                          style: AppTypography.labelSmall(
                            color: AppColors.secondaryLightIndigo,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                      const Spacer(),
                      RatingStars(rating: book.rating, iconSize: 12),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium().copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(color: AppColors.textSecondary)
                        .copyWith(fontSize: 11.5),
                  ),
                  const SizedBox(height: 6),
                  if (book.shelfStatus == ShelfStatus.currentlyReading) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ReadingProgressBar(
                            progress: book.progressPercentage,
                            height: 4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(book.progressPercentage * 100).toInt()}%',
                          style: AppTypography.labelSmall(
                            color: AppColors.primaryAmber,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      '${book.totalPages} pages • ${book.publishedYear}',
                      style: AppTypography.labelSmall(color: AppColors.textMuted)
                          .copyWith(fontSize: 10.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 105,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  book.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceRecessed,
                    child: const Icon(Icons.book, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
