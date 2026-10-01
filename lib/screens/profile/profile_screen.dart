import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/reading_goal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/streak_badge.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingAvatar = false;

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploadingAvatar = true);
        final bytes = await image.readAsBytes();
        final success = await auth.updateAvatar(bytes);
        if (mounted) {
          setState(() => _isUploadingAvatar = false);
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Profile photo uploaded to Firebase Storage!'
                : 'Failed to upload photo. Please try again.'),
            backgroundColor: success ? AppColors.secondaryIndigo : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('Image selection error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditProfileModal(BuildContext context, LibraryProvider library, AuthProvider auth) {
    final nameCtrl = TextEditingController(
      text: auth.displayName.isNotEmpty ? auth.displayName : library.userName,
    );
    final titleCtrl = TextEditingController(
      text: auth.userTitle.isNotEmpty ? auth.userTitle : library.userTitle,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Edit Reader Identity',
                style: AppTypography.headlineMedium(
                  color: AppColors.secondaryIndigo,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Update your display name and reader description.',
                style: AppTypography.bodySmall(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Text(
                'READER NAME',
                style: AppTypography.labelSmall(
                  color: AppColors.secondaryIndigo,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryAmber,
                  ),
                  filled: true,
                  fillColor: AppColors.canvasPaper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'READER TITLE / INTENTION',
                style: AppTypography.labelSmall(
                  color: AppColors.secondaryIndigo,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Your reader title',
                  prefixIcon: const Icon(
                    Icons.bookmark_outline_rounded,
                    color: AppColors.primaryAmber,
                  ),
                  filled: true,
                  fillColor: AppColors.canvasPaper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    library.updateProfile(
                      name: nameCtrl.text.trim(),
                      title: titleCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reader profile updated successfully!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'SAVE CHANGES',
                    style: AppTypography.labelLarge(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();
    final goal = library.goal;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final displayName = auth.displayName.isNotEmpty ? auth.displayName : library.userName;
    final userTitle = auth.userTitle.isNotEmpty ? auth.userTitle : library.userTitle;
    final userInitial = displayName.trim().isNotEmpty ? displayName.trim()[0].toUpperCase() : 'R';
    final avatarUrl = auth.photoUrl;

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
                // Profile Header Card
                Container(
                  padding: EdgeInsets.all(isDesktop ? 24 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryIndigo.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar with Upload Overlay
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: isDesktop ? 42 : 36,
                            backgroundColor: AppColors.primaryLightAmber,
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Text(
                                    userInitial,
                                    style: AppTypography.displayMedium(
                                      color: AppColors.primaryDarkAmber,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isUploadingAvatar ? null : () => _pickAndUploadAvatar(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryIndigo,
                                  shape: BoxShape.circle,
                                ),
                                child: _isUploadingAvatar
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTypography.headlineLarge(
                                color: AppColors.secondaryIndigo,
                              ).copyWith(fontSize: isDesktop ? 26 : 22),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userTitle,
                              style: AppTypography.bodySmall(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (auth.email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cloud_done_rounded,
                                    size: 13,
                                    color: AppColors.primaryDarkAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    auth.email,
                                    style: AppTypography.labelSmall(
                                      color: AppColors.textMuted,
                                    ).copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            StreakBadge(
                              streakDays: goal.currentStreakDays,
                              isCompact: true,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.secondaryIndigo,
                        ),
                        tooltip: 'Edit Profile',
                        onPressed: () => _showEditProfileModal(context, library, auth),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Responsive 2-column on Desktop vs 1-column on Mobile
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Analytics & Achievements
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Reading Activity',
                              style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                            ),
                            const SizedBox(height: 12),
                            _buildWeeklyChartCard(goal),
                            const SizedBox(height: 24),
                            Text(
                              'Reader Achievements',
                              style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                            ),
                            const SizedBox(height: 12),
                            _buildAchievementsGrid(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column: Preferences & Settings
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preferences & Nest Settings',
                              style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingsList(context, library, auth),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Mobile Single Column View
                  Text(
                    'Weekly Reading Activity',
                    style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyChartCard(goal),
                  const SizedBox(height: 24),
                  Text(
                    'Reader Achievements',
                    style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementsGrid(),
                  const SizedBox(height: 28),
                  Text(
                    'Preferences & Nest Settings',
                    style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsList(context, library, auth),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChartCard(ReadingGoal goal) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryIndigo.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Minutes',
                style: AppTypography.labelLarge(color: AppColors.secondaryIndigo),
              ),
              Text(
                'Avg 43 mins/day',
                style: AppTypography.labelSmall(
                  color: AppColors.primaryAmber,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('Mon', goal.weeklyMinutesHistory[0], 60),
              _buildBar('Tue', goal.weeklyMinutesHistory[1], 60),
              _buildBar('Wed', goal.weeklyMinutesHistory[2], 60),
              _buildBar('Thu', goal.weeklyMinutesHistory[3], 60),
              _buildBar('Fri', goal.weeklyMinutesHistory[4], 60),
              _buildBar('Sat', goal.weeklyMinutesHistory[5], 60),
              _buildBar(
                'Sun',
                goal.weeklyMinutesHistory[6],
                60,
                isToday: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            '🔥 14-Day Streak',
            'Consistency Champion',
            AppColors.primaryLightAmber,
            AppColors.streakFlame,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBadgeCard(
            '📖 500+ Pages',
            'Deep Thinker',
            AppColors.secondaryContainer,
            AppColors.secondaryIndigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBadgeCard(
            '🏛️ Polymath',
            '4 Unique Genres',
            const Color(0xFFDCFCE7),
            AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context, LibraryProvider library, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.badge_outlined,
            title: 'Reader Profile & Identity',
            subtitle: '${auth.displayName.isNotEmpty ? auth.displayName : library.userName} • ${auth.userTitle.isNotEmpty ? auth.userTitle : library.userTitle}',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showEditProfileModal(context, library, auth),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          _buildSettingsTile(
            icon: Icons.cloud_sync_rounded,
            title: 'Firebase Cloud Storage',
            subtitle: 'Real-time synchronization active',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLightAmber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ONLINE',
                style: AppTypography.labelSmall(color: AppColors.primaryDarkAmber)
                    .copyWith(fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          _buildSettingsTile(
            icon: Icons.restart_alt_rounded,
            title: 'Restart Onboarding Tour',
            subtitle: 'Re-run first-time reader setup',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              library.resetOnboarding();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Daily Reading Reminders',
            subtitle: '8:00 PM every evening',
            trailing: Switch(
              value: false,
              activeThumbColor: AppColors.primaryAmber,
              onChanged: (val) {},
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out Account',
            subtitle: 'Sign out from Firebase and return to login',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () async {
              await auth.signOut();
              library.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    String day,
    int minutes,
    int maxMinutes, {
    bool isToday = false,
  }) {
    final heightRatio = (minutes / maxMinutes).clamp(0.1, 1.0);
    final barHeight = 80.0 * heightRatio;

    return Column(
      children: [
        Text(
          '${minutes}m',
          style: AppTypography.labelSmall(
            color: isToday ? AppColors.primaryAmber : AppColors.textMuted,
          ).copyWith(fontWeight: isToday ? FontWeight.w700 : FontWeight.w400),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: barHeight,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primaryAmber : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: AppTypography.labelSmall(
            color: isToday ? AppColors.secondaryIndigo : AppColors.textMuted,
          ).copyWith(fontWeight: isToday ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall(
              color: iconColor,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondaryIndigo),
      title: Text(
        title,
        style: AppTypography.labelLarge(color: AppColors.secondaryIndigo),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall(color: AppColors.textMuted),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
