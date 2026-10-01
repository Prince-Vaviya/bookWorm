import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/book.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../services/firebase_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';

class AddEditBookModal extends StatefulWidget {
  final Book? bookToEdit;

  const AddEditBookModal({super.key, this.bookToEdit});

  @override
  State<AddEditBookModal> createState() => _AddEditBookModalState();
}

class _AddEditBookModalState extends State<AddEditBookModal> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingCover = false;

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _genreController;
  late TextEditingController _isbnController;
  late TextEditingController _pagesController;
  late TextEditingController _yearController;
  late TextEditingController _coverUrlController;
  late TextEditingController _synopsisController;
  late TextEditingController _quoteController;

  @override
  void initState() {
    super.initState();
    final b = widget.bookToEdit;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _genreController = TextEditingController(text: b?.genre ?? 'Technology');
    _isbnController = TextEditingController(text: b?.isbn ?? '978-0123456789');
    _pagesController = TextEditingController(text: b != null ? '${b.totalPages}' : '350');
    _yearController = TextEditingController(text: b?.publishedYear ?? '2024');
    _coverUrlController = TextEditingController(
      text: b?.coverUrl ??
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=800&auto=format&fit=crop',
    );
    _synopsisController = TextEditingController(text: b?.synopsis ?? '');
    _quoteController = TextEditingController(text: b?.keyQuote ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _isbnController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    _coverUrlController.dispose();
    _synopsisController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCover() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1400,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploadingCover = true);
        final bytes = await image.readAsBytes();
        final title = _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'book_${DateTime.now().millisecondsSinceEpoch}';

        final downloadUrl = await FirebaseService.uploadBookCover(
          bytes: bytes,
          fileName: '$title.jpg',
        );

        setState(() {
          _coverUrlController.text = downloadUrl;
          _isUploadingCover = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book cover uploaded to Firebase Storage!'),
              backgroundColor: AppColors.secondaryIndigo,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploadingCover = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cover upload error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _saveBook() {
    if (_formKey.currentState?.validate() ?? false) {
      final library = context.read<LibraryProvider>();
      final admin = context.read<AdminProvider>();

      if (widget.bookToEdit != null) {
        // Edit existing book
        final book = widget.bookToEdit!;
        final updatedBook = Book(
          id: book.id,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          authorBio: book.authorBio,
          coverUrl: _coverUrlController.text.trim(),
          rating: book.rating,
          reviewCount: book.reviewCount,
          totalPages: int.tryParse(_pagesController.text.trim()) ?? 300,
          currentPage: book.currentPage,
          genre: _genreController.text.trim(),
          tags: book.tags,
          synopsis: _synopsisController.text.trim(),
          keyQuote: _quoteController.text.trim().isNotEmpty
              ? _quoteController.text.trim()
              : null,
          publishedYear: _yearController.text.trim(),
          isbn: _isbnController.text.trim(),
          shelfStatus: book.shelfStatus,
          isFavorite: book.isFavorite,
          chapters: book.chapters,
          reviews: book.reviews,
        );

        final index = library.allBooks.indexWhere((b) => b.id == book.id);
        if (index != -1) {
          library.allBooks[index] = updatedBook;
        }
      } else {
        // Add new book
        final newBook = Book(
          id: 'book-${DateTime.now().millisecondsSinceEpoch}',
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          authorBio: 'Distinguished author and thought leader.',
          coverUrl: _coverUrlController.text.trim(),
          rating: 4.8,
          reviewCount: 1,
          totalPages: int.tryParse(_pagesController.text.trim()) ?? 300,
          genre: _genreController.text.trim(),
          tags: [_genreController.text.trim(), 'Recommended'],
          synopsis: _synopsisController.text.trim().isNotEmpty
              ? _synopsisController.text.trim()
              : 'A curated masterwork exploring ideas, systems, and craft.',
          keyQuote: _quoteController.text.trim().isNotEmpty
              ? _quoteController.text.trim()
              : null,
          publishedYear: _yearController.text.trim(),
          isbn: _isbnController.text.trim(),
          shelfStatus: ShelfStatus.wantToRead,
          chapters: [
            Chapter(
              number: 1,
              title: 'Foundational Principles',
              estimatedMinutes: 15,
              content: _synopsisController.text.trim().isNotEmpty
                  ? _synopsisController.text.trim()
                  : 'Welcome to this comprehensive volume.',
            ),
          ],
        );

        library.addBookToNest(newBook);
        admin.recordNewBookAdded(newBook.title);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.bookToEdit != null
                ? 'Book details updated successfully!'
                : 'New book published to catalog!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.bookToEdit != null ? 'Edit Book Record' : 'Add New Book to Sanctuary',
                      style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Book Title',
                        hint: 'e.g., Designing Data-Intensive Applications',
                        validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _authorController,
                        label: 'Author Name',
                        hint: 'e.g., Martin Kleppmann',
                        validator: (v) => v == null || v.isEmpty ? 'Author is required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _genreController,
                              label: 'Genre',
                              hint: 'Technology',
                              validator: (v) => v == null || v.isEmpty ? 'Genre required' : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTextField(
                              controller: _pagesController,
                              label: 'Total Pages',
                              hint: '350',
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'Pages required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _isbnController,
                              label: 'ISBN-13',
                              hint: '978-0132350884',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTextField(
                              controller: _yearController,
                              label: 'Year Published',
                              hint: '2024',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Cover URL + Firebase Storage Upload Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _coverUrlController,
                              label: 'Cover Image URL',
                              hint: 'https://images.unsplash.com/...',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: ElevatedButton.icon(
                              onPressed: _isUploadingCover ? null : _pickAndUploadCover,
                              icon: _isUploadingCover
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload_rounded, size: 18),
                              label: const Text('UPLOAD'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryIndigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _quoteController,
                        label: 'Key Passage / Quote (Optional)',
                        hint: 'A memorable insight from this book...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _synopsisController,
                        label: 'Full Synopsis',
                        hint: 'Provide an overview of the volume...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.bookToEdit != null ? 'SAVE CHANGES' : 'PUBLISH TO CATALOG',
                          style: AppTypography.labelLarge(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall(color: AppColors.secondaryIndigo)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.canvasPaper,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }
}
