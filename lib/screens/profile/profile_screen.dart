import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/streak_badge.dart';
import '../auth/login_screen.dart';

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
                    onPressed: () async {
                      final newName = nameCtrl.text.trim();
                      final newTitle = titleCtrl.text.trim();
                      await auth.updateProfile(
                        name: newName,
                        title: newTitle,
                      );
                      library.updateProfile(
                        name: newName,
                        title: newTitle,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reader profile updated successfully!'),
                            backgroundColor: AppColors.secondaryIndigo,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 20,
                24,
                isDesktop ? 32 : 20,
                isDesktop ? 40 : 80,
              ),
              children: [
                // Page Header
                Text(
                  'Reader Profile',
                  style: AppTypography.displayMedium(color: AppColors.secondaryIndigo)
                      .copyWith(fontSize: isDesktop ? 28 : 24),
                ),
                Text(
                  'Manage your sanctuary account and personal identity',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Profile Identity Hero Card
                Container(
                  padding: EdgeInsets.all(isDesktop ? 26 : 20),
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar with Upload Overlay
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: isDesktop ? 44 : 36,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: 16),

                      // Action Buttons (Edit Profile & Sign Out)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showEditProfileModal(context, library, auth),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Identity'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondaryIndigo,
                                side: const BorderSide(color: AppColors.borderLight),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
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
                              icon: const Icon(Icons.logout_rounded, size: 16),
                              label: const Text('Sign Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEE2E2),
                                foregroundColor: const Color(0xFFDC2626),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
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
      ),
    );
  }
}
