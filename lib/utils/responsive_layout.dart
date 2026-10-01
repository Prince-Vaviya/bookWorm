import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

class ResponsiveLayout {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int getGridColumnCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

/// A container that centers its child and clamps it to a maximum width
/// on wide desktop screens to prevent awkward edge-to-edge stretching.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: isDesktop ? padding : EdgeInsets.zero,
          child: child,
        ),
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    return content;
  }
}

/// Sleek Desktop Sidebar Navigation used on desktop/web screen widths
class DesktopSidebarNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback? onSignOut;
  final String userName;
  final String? userAvatarUrl;
  final int streakDays;

  const DesktopSidebarNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onSignOut,
    required this.userName,
    this.userAvatarUrl,
    this.streakDays = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          right: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryIndigo.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryIndigo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryIndigo.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Text(
                        'Book',
                        style: AppTypography.displayLarge(
                          color: AppColors.secondaryIndigo,
                        ).copyWith(fontSize: 22),
                      ),
                      Text(
                        'Worm',
                        style: AppTypography.displayLarge(
                          color: AppColors.primaryAmber,
                        ).copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User Info Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.secondaryLightIndigo.withValues(alpha: 0.2),
                      backgroundImage: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                          ? NetworkImage(userAvatarUrl!)
                          : null,
                      child: userAvatarUrl == null || userAvatarUrl!.isEmpty
                          ? Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'R',
                              style: AppTypography.labelMedium(
                                color: AppColors.secondaryIndigo,
                              ).copyWith(fontWeight: FontWeight.w800),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelMedium(
                              color: AppColors.secondaryIndigo,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: AppColors.primaryDarkAmber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$streakDays Day Streak',
                                style: AppTypography.labelSmall(
                                  color: AppColors.primaryDarkAmber,
                                ).copyWith(fontSize: 10.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home Sanctuary'),
                  _buildNavItem(1, Icons.search_rounded, Icons.search_outlined, 'Search & Explore'),
                  _buildNavItem(2, Icons.local_library_rounded, Icons.local_library_outlined, 'My Library'),
                  _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profile & Goals'),
                ],
              ),
            ),

            // Bottom Actions (Sign Out)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (onSignOut != null)
                    InkWell(
                      onTap: onSignOut,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
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
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
                color: isSelected ? AppColors.primaryAmber : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: AppTypography.labelMedium(
                  color: isSelected ? Colors.white : AppColors.secondaryIndigo,
                ).copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
