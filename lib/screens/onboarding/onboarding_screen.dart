import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final TextEditingController _nameController;
  final TextEditingController _titleController = TextEditingController(
    text: 'Curator & Software Architect',
  );

  int _selectedDailyMinutes = 45;
  final List<String> _selectedGenres = ['Technology', 'Philosophy'];

  final List<String> _availableGenres = [
    'Technology',
    'Philosophy',
    'Fiction',
    'History',
    'Psychology',
    'Self Development',
    'Science',
    'Art & Design',
    'Economics',
  ];

  @override
  void initState() {
    super.initState();
    final existingName = context.read<LibraryProvider>().userName;
    _nameController = TextEditingController(
      text: (existingName.isNotEmpty && existingName != 'Reader')
          ? existingName
          : '',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    final library = context.read<LibraryProvider>();
    library.completeOnboarding(
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      dailyTargetMinutes: _selectedDailyMinutes,
      genres: _selectedGenres,
    );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasPaper,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.secondaryIndigo,
                        size: 20,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 40),
                  Row(
                    children: List.generate(3, (index) {
                      final isCurrent = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isCurrent ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primaryAmber
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTypography.labelMedium(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Onboarding Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildIdentityPage(),
                  _buildPreferencesPage(),
                ],
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == 2 ? 'ENTER YOUR SANCTUARY' : 'CONTINUE',
                    style: AppTypography.labelLarge(
                      color: Colors.white,
                    ).copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Animated Logo Box
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.secondaryIndigo,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryIndigo.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Book',
                style: AppTypography.displayLarge(
                  color: AppColors.secondaryIndigo,
                ).copyWith(fontSize: 34),
              ),
              Text(
                'Worm',
                style: AppTypography.displayLarge(
                  color: AppColors.primaryAmber,
                ).copyWith(fontSize: 34),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your Intellectual Sanctuary',
            style: AppTypography.titleMedium(
              color: AppColors.secondaryLightIndigo,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'A unified, distraction-free reading sanctuary. Track your personal library, cultivate daily habits, and read with archival typography.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          // Value Props
          _buildValueProp(
            Icons.auto_stories_rounded,
            'Distraction-Free E-Reader & Themes',
          ),
          const SizedBox(height: 12),
          _buildValueProp(
            Icons.local_fire_department_rounded,
            'Streak Tracking & Reading Goals',
          ),
          const SizedBox(height: 12),
          _buildValueProp(
            Icons.collections_bookmark_rounded,
            'Personal Shelves & Curated Catalog',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildIdentityPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Reader Identity',
              style: AppTypography.displayMedium(
                color: AppColors.secondaryIndigo,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tell us what we should call you in your sanctuary.',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            // Avatar Placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLightAmber,
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : 'R',
                      style: AppTypography.displayMedium(
                        color: AppColors.primaryDarkAmber,
                      ).copyWith(fontSize: 36),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryAmber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Name Field
            Text(
              'YOUR NAME',
              style: AppTypography.labelSmall(
                color: AppColors.secondaryIndigo,
              ).copyWith(letterSpacing: 1, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'e.g. Elena, Alex, Marcus',
                hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primaryAmber,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryAmber,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Reader Title Field
            Text(
              'YOUR READER TITLE / INTENTION',
              style: AppTypography.labelSmall(
                color: AppColors.secondaryIndigo,
              ).copyWith(letterSpacing: 1, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Lifelong Learner, Software Architect',
                hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: AppColors.primaryAmber,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryAmber,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Reading Intentions',
              style: AppTypography.displayMedium(
                color: AppColors.secondaryIndigo,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Set your daily reading goal and preferred topics.',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            // Daily Target Minutes
            Text(
              'DAILY READING TARGET',
              style: AppTypography.labelSmall(
                color: AppColors.secondaryIndigo,
              ).copyWith(letterSpacing: 1, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [15, 30, 45, 60].map((mins) {
                final isSelected = _selectedDailyMinutes == mins;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDailyMinutes = mins;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondaryIndigo
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondaryIndigo
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$mins',
                              style: AppTypography.titleMedium(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.secondaryIndigo,
                              ).copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'mins',
                              style: AppTypography.labelSmall(
                                color: isSelected
                                    ? AppColors.primaryLightAmber
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            // Favorite Genres
            Text(
              'FAVORITE TOPICS & GENRES',
              style: AppTypography.labelSmall(
                color: AppColors.secondaryIndigo,
              ).copyWith(letterSpacing: 1, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableGenres.map((genre) {
                final isSelected = _selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                  selectedColor: AppColors.secondaryIndigo,
                  backgroundColor: Colors.white,
                  labelStyle:
                      AppTypography.labelSmall(
                        color: isSelected
                            ? Colors.white
                            : AppColors.secondaryIndigo,
                      ).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.secondaryIndigo
                        : AppColors.borderLight,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueProp(IconData icon, String text) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryLightAmber,
          child: Icon(icon, size: 16, color: AppColors.primaryDarkAmber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall(
              color: AppColors.secondaryIndigo,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
