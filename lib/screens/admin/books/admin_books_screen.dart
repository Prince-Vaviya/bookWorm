import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin_metrics.dart';
import '../../../models/book.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/rating_stars.dart';
import 'add_edit_book_modal.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final admin = context.watch<AdminProvider>();

    final books = library.allBooks.where((book) {
      final status = admin.getBookPublicationStatus(book.id);
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Published' && status == PublicationStatus.published) ||
          (_filter == 'Draft' && status == PublicationStatus.draft) ||
          (_filter == 'Archived' && status == PublicationStatus.archived);

      final matchesQuery = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.isbn.contains(_searchQuery);

      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.canvasPaper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Books Catalog',
                              style: AppTypography.displayMedium(color: AppColors.secondaryIndigo)
                                  .copyWith(fontSize: 22),
                            ),
                            Text(
                              'Manage digital inventory (${library.allBooks.length} titles)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AddEditBookModal(),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search title, author, or ISBN...',
                        hintStyle: AppTypography.bodySmall(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAmber, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Published', 'Draft', 'Archived'].map((f) {
                        final isSelected = _filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _filter = f;
                                });
                              }
                            },
                            selectedColor: AppColors.secondaryIndigo,
                            backgroundColor: Colors.white,
                            labelStyle: AppTypography.labelSmall(
                              color: isSelected ? Colors.white : AppColors.secondaryIndigo,
                            ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                            side: BorderSide(
                              color: isSelected ? AppColors.secondaryIndigo : AppColors.borderLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Books List
            Expanded(
              child: books.isEmpty
                  ? Center(
                      child: Text(
                        'No books match the current filter',
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final status = admin.getBookPublicationStatus(book.id);

                        return _buildAdminBookCard(context, book, status, admin, library);
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildAdminBookCard(
    BuildContext context,
    Book book,
    PublicationStatus status,
    AdminProvider admin,
    LibraryProvider library,
  ) {
    Color statusBg;
    Color statusTextColor;
    String statusLabel;

    switch (status) {
      case PublicationStatus.draft:
        statusBg = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFF92400E);
        statusLabel = 'Draft';
        break;
      case PublicationStatus.archived:
        statusBg = const Color(0xFFF1F5F9);
        statusTextColor = const Color(0xFF475569);
        statusLabel = 'Archived';
        break;
      case PublicationStatus.published:
        statusBg = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF166534);
        statusLabel = 'Published';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryIndigo.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.coverUrl,
              width: 58,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 58,
                height: 84,
                color: AppColors.surfaceRecessed,
                child: const Icon(Icons.book, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book.genre,
                        style: AppTypography.labelSmall(color: AppColors.secondaryLightIndigo),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.labelSmall(color: statusTextColor)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    RatingStars(rating: book.rating, iconSize: 12),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium().copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  book.author,
                  style: AppTypography.bodySmall(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'ISBN: ${book.isbn}',
                      style: AppTypography.labelSmall(color: AppColors.textMuted).copyWith(fontSize: 10),
                    ),
                    const Spacer(),
                    // Status Toggle
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.secondaryIndigo),
                      onSelected: (val) {
                        if (val == 'edit') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddEditBookModal(bookToEdit: book),
                          );
                        } else if (val == 'publish') {
                          admin.setBookPublicationStatus(book.id, PublicationStatus.published);
                        } else if (val == 'draft') {
                          admin.setBookPublicationStatus(book.id, PublicationStatus.draft);
                        } else if (val == 'archive') {
                          admin.setBookPublicationStatus(book.id, PublicationStatus.archived);
                        } else if (val == 'delete') {
                          library.allBooks.removeWhere((b) => b.id == book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted "${book.title}" from catalog')),
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Edit Metadata'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'publish',
                          child: Row(
                            children: [
                              Icon(Icons.publish_rounded, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Set Published'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'draft',
                          child: Row(
                            children: [
                              Icon(Icons.edit_note_rounded, size: 16, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Set Draft'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Set Archived'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Book', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
