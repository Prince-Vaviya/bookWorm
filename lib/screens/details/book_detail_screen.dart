import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../widgets/rating_stars.dart';
import '../reader/reader_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isSynopsisExpanded = false;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final book = library.getBookById(widget.bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Book not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvasPaper,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.canvasPaper,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.secondaryIndigo),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  book.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: book.isFavorite ? Colors.redAccent : AppColors.secondaryIndigo,
                ),
                onPressed: () => library.toggleFavorite(book.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.secondaryIndigo),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing "${book.title}" link...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Hero 3D Book Cover & Key Metrics
                  Center(
                    child: Hero(
                      tag: 'book-cover-${book.id}',
                      child: Container(
                        width: 170,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryIndigo.withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(4, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceRecessed,
                              child: const Icon(Icons.book, size: 60, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title & Author
                  Center(
                    child: Text(
                      book.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.displayMedium(color: AppColors.secondaryIndigo),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      book.author,
                      textAlign: TextAlign.center,
                      style: AppTypography.titleMedium(color: AppColors.textSecondary)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata Badges (Rating, Pages, Time, Year)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricColumn('Rating', '${book.rating} ★', '${book.reviewCount} reviews'),
                        _buildDivider(),
                        _buildMetricColumn('Pages', '${book.totalPages}', 'Standard'),
                        _buildDivider(),
                        _buildMetricColumn('Time', '${book.estimatedRemainingMinutes}m', 'Est. read'),
                        _buildDivider(),
                        _buildMetricColumn('Year', book.publishedYear, 'First Ed.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Shelf Status Selector
                  _buildShelfSelector(context, book, library),
                  const SizedBox(height: 24),

                  // Key Quote Highlight
                  if (book.keyQuote != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF8),
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                          left: BorderSide(color: AppColors.primaryAmber, width: 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAmber.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIGHLIGHTED PASSAGE',
                            style: AppTypography.labelSmall(color: AppColors.primaryAmber)
                                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.keyQuote!,
                            style: AppTypography.quoteStyle(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Synopsis
                  Text(
                    'About This Book',
                    style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.synopsis,
                    maxLines: _isSynopsisExpanded ? null : 4,
                    overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSynopsisExpanded = !_isSynopsisExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        _isSynopsisExpanded ? 'Read less' : 'Read more...',
                        style: AppTypography.labelLarge(color: AppColors.primaryAmber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: book.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '# $tag',
                          style: AppTypography.labelSmall(color: AppColors.secondaryIndigo),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Author Spotlight
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryLightAmber,
                          child: Text(
                            book.author.isNotEmpty ? book.author[0] : 'A',
                            style: AppTypography.headlineSmall(color: AppColors.primaryDarkAmber),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.author,
                                style: AppTypography.titleMedium(color: AppColors.secondaryIndigo),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.authorBio,
                                style: AppTypography.bodySmall(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Reviews & Community
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reader Reviews',
                        style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _showWriteReviewDialog(context, book);
                        },
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text('Add Review'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryAmber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (book.reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          'No community reviews yet. Be the first to share your thoughts!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(),
                        ),
                      ),
                    )
                  else
                    ...book.reviews.map((rev) => _buildReviewCard(rev)),

                  const SizedBox(height: 100), // Space for sticky bottom bar
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),

      // Sticky Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryIndigo.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(book: book),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_stories_rounded, size: 20),
                  label: Text(
                    book.currentPage > 0 ? 'CONTINUE READING' : 'START READING',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShelfSelector(BuildContext context, Book book, LibraryProvider library) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_border_rounded, color: AppColors.secondaryIndigo, size: 20),
          const SizedBox(width: 10),
          Text(
            'Shelf:',
            style: AppTypography.labelMedium(color: AppColors.secondaryIndigo),
          ),
          const Spacer(),
          DropdownButton<ShelfStatus>(
            value: book.shelfStatus,
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryAmber),
            style: AppTypography.labelLarge(color: AppColors.primaryAmber),
            items: const [
              DropdownMenuItem(
                value: ShelfStatus.currentlyReading,
                child: Text('Currently Reading'),
              ),
              DropdownMenuItem(
                value: ShelfStatus.wantToRead,
                child: Text('Want to Read'),
              ),
              DropdownMenuItem(
                value: ShelfStatus.completed,
                child: Text('Completed'),
              ),
            ],
            onChanged: (newStatus) {
              if (newStatus != null) {
                library.updateShelfStatus(book.id, newStatus);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge(color: AppColors.secondaryIndigo)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.borderLight,
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.secondaryLightIndigo,
                child: Text(
                  review.reviewerName[0],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                review.reviewerName,
                style: AppTypography.labelLarge(color: AppColors.secondaryIndigo),
              ),
              const Spacer(),
              RatingStars(rating: review.rating, iconSize: 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: AppTypography.bodySmall(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                review.date,
                style: AppTypography.labelSmall(color: AppColors.textMuted),
              ),
              const Spacer(),
              const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${review.likesCount}',
                style: AppTypography.labelSmall(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(BuildContext context, Book book) {
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a Review for "${book.title}"',
                    style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rating: '),
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          icon: Icon(
                            i <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.ratingStar,
                          ),
                          onPressed: () {
                            setModalState(() {
                              selectedRating = i.toDouble();
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts, insights, or favorite takeaways...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          setState(() {
                            book.reviews.insert(
                              0,
                              Review(
                                id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
                                reviewerName: context.read<LibraryProvider>().userName,
                                rating: selectedRating,
                                date: 'Just now',
                                comment: commentController.text.trim(),
                                likesCount: 0,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review added successfully!')),
                          );
                        }
                      },
                      child: const Text('SUBMIT REVIEW'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
