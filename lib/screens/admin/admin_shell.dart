import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_layout.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'books/admin_books_screen.dart';
import 'reviews/admin_reviews_screen.dart';
import 'users/admin_users_screen.dart';
import '../auth/login_screen.dart';
import '../main_shell.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _switchToSanctuary() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  void _signOut() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final screens = [
      AdminDashboardScreen(onNavigateTab: _onTabSelected),
      const AdminBooksScreen(),
      const AdminReviewsScreen(),
      const AdminUsersScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Admin Desktop Sidebar
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: AppColors.borderLight)),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryIndigo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 20,
                              color: AppColors.primaryLightAmber,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADMIN PORTAL',
                                style: AppTypography.labelMedium(
                                  color: AppColors.secondaryIndigo,
                                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.1),
                              ),
                              Text(
                                'Curatorial Suite',
                                style: AppTypography.labelSmall(
                                  color: AppColors.textMuted,
                                ).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 12),

                    // Navigation items
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _buildDesktopNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
                          _buildDesktopNavItem(1, Icons.library_books_rounded, Icons.library_books_outlined, 'Book Catalog'),
                          _buildDesktopNavItem(2, Icons.gavel_rounded, Icons.gavel_outlined, 'Moderation Queue'),
                          _buildDesktopNavItem(3, Icons.people_alt_rounded, Icons.people_alt_outlined, 'Reader Directory'),
                        ],
                      ),
                    ),

                    // Bottom Action
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: _switchToSanctuary,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.primaryAmber),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reader Sanctuary',
                                    style: AppTypography.labelSmall(color: AppColors.secondaryIndigo)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _signOut,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout_rounded, size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sign Out',
                                    style: AppTypography.labelSmall(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryIndigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.primaryLightAmber),
                  const SizedBox(width: 6),
                  Text(
                    'ADMIN PORTAL',
                    style: AppTypography.labelSmall(color: Colors.white)
                        .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Switch to Reader Sanctuary
          TextButton.icon(
            onPressed: _switchToSanctuary,
            icon: const Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.primaryAmber),
            label: Text(
              'Reader Sanctuary',
              style: AppTypography.labelSmall(color: AppColors.primaryAmber)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textMuted),
            tooltip: 'Sign Out to Login',
            onPressed: _signOut,
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryIndigo.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.library_books_rounded, Icons.library_books_outlined, 'Books'),
                _buildNavItem(2, Icons.gavel_rounded, Icons.gavel_outlined, 'Reviews'),
                _buildNavItem(3, Icons.people_alt_rounded, Icons.people_alt_outlined, 'Users'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentTabIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _onTabSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                size: 20,
                color: isSelected ? AppColors.primaryLightAmber : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: AppTypography.labelMedium(
                  color: isSelected ? Colors.white : AppColors.secondaryIndigo,
                ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentTabIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSmall(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
