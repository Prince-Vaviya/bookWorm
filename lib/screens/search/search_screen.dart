import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/book_card.dart';
import '../details/book_detail_screen.dart';
import 'barcode_scanner_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  final List<String> _recentSearches = [
    'Marcus Aurelius',
    'Distributed Systems',
    'Habits',
    'Psychology'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final results = library.filteredBooks;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.canvasPaper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 20,
                      20,
                      isDesktop ? 32 : 20,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search & Discovery',
                          style: AppTypography.displayMedium(color: AppColors.secondaryIndigo),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore titles, authors, and topics across your digital collection',
                          style: AppTypography.bodySmall(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),

                        // Search Input & Scan Button
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderLight),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryIndigo.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    library.setSearchQuery(val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Title, author, or ISBN...',
                                    hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.primaryAmber,
                                    ),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 18),
                                            onPressed: () {
                                              _searchController.clear();
                                              library.setSearchQuery('');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Barcode scan trigger
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.secondaryIndigo,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                                tooltip: 'Scan ISBN Barcode',
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const BarcodeScannerModal(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Genre Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: library.availableGenres.map((genre) {
                              final isSelected = library.selectedGenreFilter == genre;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(genre),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      library.setGenreFilter(genre);
                                    }
                                  },
                                  selectedColor: AppColors.secondaryIndigo,
                                  backgroundColor: Colors.white,
                                  labelStyle: AppTypography.labelSmall(
                                    color: isSelected ? Colors.white : AppColors.secondaryIndigo,
                                  ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                                  shape: const StadiumBorder(),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.secondaryIndigo : AppColors.borderLight,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Recent search tags when query is empty
                        if (_searchController.text.isEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Recent Searches',
                                style: AppTypography.labelMedium(color: AppColors.textMuted),
                              ),
                              const Spacer(),
                              if (_recentSearches.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _recentSearches.clear();
                                    });
                                  },
                                  child: Text(
                                    'Clear',
                                    style: AppTypography.labelSmall(color: AppColors.primaryAmber),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _recentSearches.map((term) {
                              return ActionChip(
                                avatar: const Icon(Icons.history_rounded, size: 14, color: AppColors.textMuted),
                                label: Text(term),
                                backgroundColor: AppColors.surfaceRecessed,
                                labelStyle: AppTypography.labelSmall(color: AppColors.textPrimary),
                                side: const BorderSide(color: AppColors.borderSepia),
                                shape: const StadiumBorder(),
                                onPressed: () {
                                  _searchController.text = term;
                                  library.setSearchQuery(term);
                                },
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 16),
                        // Results count & Layout Switcher
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${results.length} ${results.length == 1 ? "Book" : "Books"} Found',
                              style: AppTypography.labelLarge(color: AppColors.secondaryIndigo)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.view_list_rounded,
                                    color: !_isGridView ? AppColors.primaryAmber : AppColors.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isGridView = false;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.grid_view_rounded,
                                    color: _isGridView ? AppColors.primaryAmber : AppColors.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isGridView = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Results List / Grid
                if (results.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No books found',
                            style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching by another title, author, or genre tag',
                            style: AppTypography.bodySmall(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_isGridView)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 4 : 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = results[index];
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
                        childCount: results.length,
                      ),
                    ),
                  )
                else if (isDesktop)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 124,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = results[index];
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
                        childCount: results.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = results[index];
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
                        },
                        childCount: results.length,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: SizedBox(height: isDesktop ? 40 : 80),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
