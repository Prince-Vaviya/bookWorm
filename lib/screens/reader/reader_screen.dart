import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../models/reader_settings.dart';
import '../../providers/library_provider.dart';
import '../../providers/reader_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../widgets/reading_progress_bar.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showControls = true;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll > 0) {
      setState(() {
        _scrollProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Color _getBackgroundColor(ReaderThemeMode mode) {
    switch (mode) {
      case ReaderThemeMode.warmSepia:
        return AppColors.readerSepiaBg;
      case ReaderThemeMode.nightIndigo:
        return AppColors.readerDarkBg;
      case ReaderThemeMode.darkAmoled:
        return AppColors.readerAmoledBg;
      case ReaderThemeMode.creamPaper:
        return AppColors.readerCreamBg;
    }
  }

  Color _getTextColor(ReaderThemeMode mode) {
    switch (mode) {
      case ReaderThemeMode.warmSepia:
        return AppColors.readerSepiaText;
      case ReaderThemeMode.nightIndigo:
        return AppColors.readerDarkText;
      case ReaderThemeMode.darkAmoled:
        return AppColors.readerAmoledText;
      case ReaderThemeMode.creamPaper:
        return AppColors.readerCreamText;
    }
  }

  TextStyle _getReaderTextStyle(ReaderSettings settings, Color textColor) {
    switch (settings.fontFamily) {
      case ReaderFontFamily.bricolage:
        return GoogleFonts.bricolageGrotesque(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          color: textColor,
          letterSpacing: 0.1,
        );
      case ReaderFontFamily.sansSerif:
        return TextStyle(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          color: textColor,
          fontFamily: 'Roboto',
        );
      case ReaderFontFamily.literata:
        return GoogleFonts.literata(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          color: textColor,
          letterSpacing: 0.1,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final library = context.watch<LibraryProvider>();
    final settings = reader.settings;

    final bgColor = _getBackgroundColor(settings.themeMode);
    final textColor = _getTextColor(settings.themeMode);
    final isDark = settings.themeMode == ReaderThemeMode.nightIndigo ||
        settings.themeMode == ReaderThemeMode.darkAmoled;

    final chapters = widget.book.chapters;
    final currentChapter = chapters.isNotEmpty
        ? chapters[reader.currentChapterIndex.clamp(0, chapters.length - 1)]
        : Chapter(
            number: 1,
            title: widget.book.title,
            estimatedMinutes: widget.book.estimatedRemainingMinutes,
            content: widget.book.synopsis,
          );

    final isBookmarked =
        widget.book.bookmarkedChapters.contains(currentChapter.number);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Reading Surface
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: settings.horizontalMargin,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Room for top bar
                    // Book & Chapter Header
                    Text(
                      'CHAPTER ${currentChapter.number}',
                      style: AppTypography.labelMedium(
                        color: isDark
                            ? AppColors.primaryLightAmber
                            : AppColors.primaryAmber,
                      ).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentChapter.title,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: settings.fontSize * 1.5,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.borderSepia,
                    ),
                    const SizedBox(height: 24),

                    // Chapter Longform Body
                    SelectableText(
                      currentChapter.content,
                      style: _getReaderTextStyle(settings, textColor),
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: 60),

                    // End of chapter footer
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 24,
                            color: isDark ? Colors.white38 : AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'End of Chapter ${currentChapter.number}',
                            style: AppTypography.labelSmall(
                              color: isDark ? Colors.white38 : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (reader.currentChapterIndex < chapters.length - 1)
                            ElevatedButton.icon(
                              onPressed: () {
                                reader.setChapterIndex(reader.currentChapterIndex + 1);
                                library.updateReadingProgress(
                                  widget.book.id,
                                  ((reader.currentChapterIndex + 1) /
                                          chapters.length *
                                          widget.book.totalPages)
                                      .toInt(),
                                );
                                _scrollController.jumpTo(0);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text('NEXT CHAPTER'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAmber,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Top Header Overlay (animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.borderLight,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : AppColors.secondaryIndigo,
                      ),
                      onPressed: () {
                        // Persist reading time and progress before exiting
                        library.addMinutesReadToday(5);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelLarge(
                              color: isDark ? Colors.white : AppColors.secondaryIndigo,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Chapter ${currentChapter.number} of ${chapters.isNotEmpty ? chapters.length : 1}',
                            style: AppTypography.labelSmall(
                              color: isDark ? Colors.white70 : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppColors.primaryAmber : (isDark ? Colors.white : AppColors.secondaryIndigo),
                      ),
                      onPressed: () {
                        reader.toggleChapterBookmark(widget.book, currentChapter.number);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked ? 'Bookmark removed' : 'Chapter bookmarked',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.text_format_rounded,
                        color: isDark ? Colors.white : AppColors.secondaryIndigo,
                      ),
                      onPressed: () {
                        _showTypographySettingsModal(context, reader, isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Progress & Chapter Drawer Overlay (animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -120,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.borderLight,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reading Progress Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(_scrollProgress * 100).toInt()}% completed',
                          style: AppTypography.labelSmall(
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${currentChapter.estimatedMinutes} mins remaining',
                          style: AppTypography.labelSmall(
                            color: isDark
                                ? AppColors.primaryLightAmber
                                : AppColors.primaryAmber,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ReadingProgressBar(
                      progress: _scrollProgress,
                      height: 4,
                      activeColor: AppColors.primaryAmber,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.surfaceContainerLow,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          onPressed: reader.currentChapterIndex > 0
                              ? () {
                                  reader.setChapterIndex(reader.currentChapterIndex - 1);
                                  _scrollController.jumpTo(0);
                                }
                              : null,
                          icon: const Icon(Icons.skip_previous_rounded, size: 20),
                          label: const Text('Prev'),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : AppColors.secondaryIndigo,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.format_list_bulleted_rounded,
                            color: isDark ? Colors.white : AppColors.secondaryIndigo,
                          ),
                          onPressed: () {
                            _showChaptersListModal(context, widget.book, reader, isDark);
                          },
                        ),
                        TextButton.icon(
                          onPressed: reader.currentChapterIndex < chapters.length - 1
                              ? () {
                                  reader.setChapterIndex(reader.currentChapterIndex + 1);
                                  _scrollController.jumpTo(0);
                                }
                              : null,
                          icon: const Icon(Icons.skip_next_rounded, size: 20),
                          label: const Text('Next'),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : AppColors.secondaryIndigo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTypographySettingsModal(BuildContext context, ReaderProvider reader, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.secondaryIndigo : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final settings = reader.settings;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Reading Experience',
                      style: AppTypography.headlineSmall(
                        color: isDark ? Colors.white : AppColors.secondaryIndigo,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Themes row
                    Text(
                      'PAPER THEME',
                      style: AppTypography.labelSmall(
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ).copyWith(letterSpacing: 1),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildThemeCircle(
                          'Cream',
                          AppColors.readerCreamBg,
                          settings.themeMode == ReaderThemeMode.creamPaper,
                          () => reader.setThemeMode(ReaderThemeMode.creamPaper),
                        ),
                        _buildThemeCircle(
                          'Sepia',
                          AppColors.readerSepiaBg,
                          settings.themeMode == ReaderThemeMode.warmSepia,
                          () => reader.setThemeMode(ReaderThemeMode.warmSepia),
                        ),
                        _buildThemeCircle(
                          'Indigo',
                          AppColors.readerDarkBg,
                          settings.themeMode == ReaderThemeMode.nightIndigo,
                          () => reader.setThemeMode(ReaderThemeMode.nightIndigo),
                        ),
                        _buildThemeCircle(
                          'AMOLED',
                          AppColors.readerAmoledBg,
                          settings.themeMode == ReaderThemeMode.darkAmoled,
                          () => reader.setThemeMode(ReaderThemeMode.darkAmoled),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Font Size Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FONT SIZE (${settings.fontSize.toInt()}pt)',
                          style: AppTypography.labelSmall(
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                          ).copyWith(letterSpacing: 1),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('A', style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                        Expanded(
                          child: Slider(
                            value: settings.fontSize,
                            min: 13.0,
                            max: 26.0,
                            divisions: 13,
                            activeColor: AppColors.primaryAmber,
                            onChanged: (val) {
                              reader.setFontSize(val);
                              setModalState(() {});
                            },
                          ),
                        ),
                        Text('A', style: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Font Family Selector
                    Text(
                      'TYPEFACE',
                      style: AppTypography.labelSmall(
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ).copyWith(letterSpacing: 1),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFontOption(
                            'Literata',
                            settings.fontFamily == ReaderFontFamily.literata,
                            () => reader.setFontFamily(ReaderFontFamily.literata),
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFontOption(
                            'Bricolage',
                            settings.fontFamily == ReaderFontFamily.bricolage,
                            () => reader.setFontFamily(ReaderFontFamily.bricolage),
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFontOption(
                            'Sans Serif',
                            settings.fontFamily == ReaderFontFamily.sansSerif,
                            () => reader.setFontFamily(ReaderFontFamily.sansSerif),
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeCircle(String label, Color color, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryAmber : Colors.grey.withValues(alpha: 0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 20, color: AppColors.primaryAmber)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFontOption(String name, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAmber
              : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.surfaceContainerLow),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          name,
          style: AppTypography.labelSmall(
            color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.secondaryIndigo),
          ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }

  void _showChaptersListModal(
      BuildContext context, Book book, ReaderProvider reader, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.secondaryIndigo : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Table of Contents',
                style: AppTypography.headlineSmall(
                  color: isDark ? Colors.white : AppColors.secondaryIndigo,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: book.chapters.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? Colors.white12 : AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final ch = book.chapters[index];
                    final isCurrent = index == reader.currentChapterIndex;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isCurrent
                            ? AppColors.primaryAmber
                            : (isDark ? Colors.white10 : AppColors.surfaceContainerLow),
                        child: Text(
                          '${ch.number}',
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.secondaryIndigo),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        ch.title,
                        style: AppTypography.labelLarge(
                          color: isDark ? Colors.white : AppColors.secondaryIndigo,
                        ).copyWith(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        '${ch.estimatedMinutes}m',
                        style: AppTypography.labelSmall(
                          color: isDark ? Colors.white60 : AppColors.textMuted,
                        ),
                      ),
                      onTap: () {
                        reader.setChapterIndex(index);
                        Navigator.pop(ctx);
                        _scrollController.jumpTo(0);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
