import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/book_card.dart';
import '../../widgets/streak_badge.dart';
import '../details/book_detail_screen.dart';
import '../reader/reader_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();
    final priorityBook = library.priorityBook;
    final goal = library.goal;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final greetingName = auth.displayName.isNotEmpty ? auth.displayName : library.userName;

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
                // Top Bar Greeting & Streak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, $greetingName 👋',
                          style: AppTypography.displayMedium(color: AppColors.secondaryIndigo)
                              .copyWith(fontSize: isDesktop ? 28 : 24),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your intellectual sanctuary is synced to cloud',
                          style: AppTypography.bodySmall(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    StreakBadge(streakDays: goal.currentStreakDays, isCompact: !isDesktop),
                  ],
                ),
                const SizedBox(height: 22),

                // Daily Reading Goal Progress Card
                Container(
                  padding: EdgeInsets.all(isDesktop ? 22 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryIndigo.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Circular Progress Indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 62,
                            height: 62,
                            child: CircularProgressIndicator(
                              value: goal.dailyProgressPercentage,
                              strokeWidth: 6.5,
                              backgroundColor: AppColors.surfaceContainerLow,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryAmber,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            '${(goal.dailyProgressPercentage * 100).toInt()}%',
                            style: AppTypography.labelSmall(color: AppColors.primaryAmber)
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today’s Reading Goal',
                              style: AppTypography.labelLarge(color: AppColors.secondaryIndigo)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${goal.minutesReadToday} of ${goal.dailyTargetMinutes} mins completed today',
                              style: AppTypography.bodySmall(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (priorityBook != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(book: priorityBook),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('START READING'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 20 : 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Continue Reading Priority Hero Card
                if (priorityBook != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Continue Reading',
                        style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(2), // Jump to Library tab
                        child: Text(
                          'View Shelf',
                          style: AppTypography.labelMedium(color: AppColors.primaryAmber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BookCard(
                    book: priorityBook,
                    displayMode: BookCardDisplayMode.hero,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(bookId: priorityBook.id),
                        ),
                      );
                    },
                    onResumeReading: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(book: priorityBook),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],

                // Curated Collections Carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Curated For You',
                      style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1), // Jump to Explore
                      child: Text(
                        'Explore All',
                        style: AppTypography.labelMedium(color: AppColors.primaryAmber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: library.allBooks.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final book = library.allBooks[index];
                      return BookCard(
                        book: book,
                        displayMode: BookCardDisplayMode.grid,
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
                  ),
                ),
                const SizedBox(height: 30),

                // Trending in Philosophy & Technology
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending in System Design & Wisdom',
                      style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: Text(
                        'Browse Topics',
                        style: AppTypography.labelMedium(color: AppColors.primaryAmber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Desktop Responsive Grid vs Mobile List for Trending
                if (isDesktop)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 124,
                    ),
                    itemCount: library.allBooks.take(4).length,
                    itemBuilder: (context, index) {
                      final book = library.allBooks[index];
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
                  ...library.allBooks.take(3).map((book) {
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
