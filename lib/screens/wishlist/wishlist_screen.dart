import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/book_card.dart';
import '../../widgets/reading_progress_bar.dart';
import '../details/book_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final wishlistBooks = library.wishlist;
    final goal = library.goal;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.canvasPaper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 20,
                20,
                isDesktop ? 32 : 20,
                isDesktop ? 40 : 80,
              ),
              children: [
                // Header
                Text(
                  'Wishlist & Goals',
                  style: AppTypography.displayMedium(color: AppColors.secondaryIndigo),
                ),
                Text(
                  'Curated queue and personal reading milestones',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Annual Reading Challenge Card
                Container(
                  padding: EdgeInsets.all(isDesktop ? 22 : 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondaryIndigo, Color(0xFF2E2A72)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryIndigo.withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                color: AppColors.primaryAmber,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '2026 Reading Challenge',
                                style: AppTypography.titleMedium(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.w700, fontSize: isDesktop ? 18 : 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'ON TRACK',
                              style: AppTypography.labelSmall(
                                color: AppColors.primaryLightAmber,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${goal.booksCompletedThisYear} of ${goal.yearlyBookTarget} books read this year',
                            style: AppTypography.bodySmall(color: Colors.white70),
                          ),
                          Text(
                            '${(goal.yearlyProgressPercentage * 100).toInt()}%',
                            style: AppTypography.labelMedium(
                              color: AppColors.primaryLightAmber,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ReadingProgressBar(
                        progress: goal.yearlyProgressPercentage,
                        height: 6,
                        activeColor: AppColors.primaryAmber,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Wishlist items header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved for Later (${wishlistBooks.length})',
                      style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Quick add recommendation
                        library.addBookToNest(
                          Book(
                            id: 'book-${DateTime.now().millisecondsSinceEpoch}',
                            title: 'The Psychology of Money',
                            author: 'Morgan Housel',
                            authorBio: 'Partner at Collaborative Fund and former columnist.',
                            coverUrl:
                                'https://images.unsplash.com/photo-1592496431122-2349e0fbc666?q=80&w=800&auto=format&fit=crop',
                            rating: 4.8,
                            reviewCount: 3900,
                            totalPages: 256,
                            genre: 'Finance',
                            tags: ['Wealth', 'Psychology', 'Decision Making'],
                            synopsis:
                                'Timeless lessons on wealth, greed, and happiness doing well with money isn’t necessarily about what you know. It’s about how you behave.',
                            publishedYear: '2020',
                            isbn: '978-0857197689',
                            shelfStatus: ShelfStatus.wishlist,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added new recommendation to Wishlist!')),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Book'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primaryAmber),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (wishlistBooks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 10),
                          Text(
                            'Your wishlist is currently empty',
                            style: AppTypography.titleMedium(color: AppColors.secondaryIndigo),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Save books while browsing to build your reading backlog',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isDesktop)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 124,
                    ),
                    itemCount: wishlistBooks.length,
                    itemBuilder: (context, index) {
                      final book = wishlistBooks[index];
                      return BookCard(
                        book: book,
                        displayMode: BookCardDisplayMode.list,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                      );
                    },
                  )
                else
                  ...wishlistBooks.map((book) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BookCard(
                        book: book,
                        displayMode: BookCardDisplayMode.list,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
