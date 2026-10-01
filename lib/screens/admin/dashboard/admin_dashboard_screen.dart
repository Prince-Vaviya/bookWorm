import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/responsive_layout.dart';
import '../books/add_edit_book_modal.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const AdminDashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final admin = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Operations & Cloud Metrics',
                            style: AppTypography.displayMedium(color: AppColors.secondaryIndigo)
                                .copyWith(fontSize: isDesktop ? 26 : 22),
                          ),
                          Text(
                            'Platform health, Firebase synchronization, and live activity pulse',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FIREBASE LIVE',
                            style: AppTypography.labelSmall(color: AppColors.successGreen)
                                .copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // High-Impact KPI Metric Grid (Responsive 4-column on desktop vs 2-column on mobile)
                if (isDesktop)
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Active Readers',
                          '12,480',
                          '+14.2% this mo',
                          Icons.people_alt_rounded,
                          AppColors.secondaryIndigo,
                          AppColors.surfaceContainerLow,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildKpiCard(
                          'Catalog Titles',
                          '${library.allBooks.length}',
                          'Synced to Cloud',
                          Icons.menu_book_rounded,
                          AppColors.primaryAmber,
                          const Color(0xFFFFF7ED),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildKpiCard(
                          'Pending Reviews',
                          '${admin.pendingReviewsCount}',
                          '${admin.flaggedReviewsCount} flagged',
                          Icons.rate_review_rounded,
                          AppColors.secondaryLightIndigo,
                          AppColors.surfaceContainerLow,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildKpiCard(
                          'Storage Buckets',
                          '4.8 GB',
                          'Covers & Avatars',
                          Icons.cloud_done_rounded,
                          AppColors.successGreen,
                          const Color(0xFFECFDF5),
                        ),
                      ),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Active Readers',
                          '12,480',
                          '+14.2% this mo',
                          Icons.people_alt_rounded,
                          AppColors.secondaryIndigo,
                          AppColors.surfaceContainerLow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          'Catalog Titles',
                          '${library.allBooks.length}',
                          'Synced to Cloud',
                          Icons.menu_book_rounded,
                          AppColors.primaryAmber,
                          const Color(0xFFFFF7ED),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Pending Reviews',
                          '${admin.pendingReviewsCount}',
                          '${admin.flaggedReviewsCount} flagged',
                          Icons.rate_review_rounded,
                          AppColors.secondaryLightIndigo,
                          AppColors.surfaceContainerLow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          'Storage Buckets',
                          '4.8 GB',
                          'Covers & Avatars',
                          Icons.cloud_done_rounded,
                          AppColors.successGreen,
                          const Color(0xFFECFDF5),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Quick Admin Actions
                Text(
                  'Quick Management Actions',
                  style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AddEditBookModal(),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Book to Catalog'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onNavigateTab(2), // Jump to Moderation
                        icon: const Icon(Icons.gavel_rounded, size: 18, color: AppColors.secondaryIndigo),
                        label: const Text('Moderate Reviews'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondaryIndigo,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent Platform Audit Logs
                Text(
                  'Recent Activity Audit Stream',
                  style: AppTypography.headlineSmall(color: AppColors.secondaryIndigo),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: admin.activityLogs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final log = admin.activityLogs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceContainerLow,
                          child: Icon(
                            _getLogIcon(log.iconType),
                            color: AppColors.secondaryIndigo,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          log.title,
                          style: AppTypography.labelMedium(color: AppColors.secondaryIndigo)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          log.description,
                          style: AppTypography.bodySmall(color: AppColors.textMuted),
                        ),
                        trailing: Text(
                          log.timestamp,
                          style: AppTypography.labelSmall(color: AppColors.textMuted),
                        ),
                      );
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

  Widget _buildKpiCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headlineLarge(color: AppColors.secondaryIndigo)
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.labelMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.labelSmall(color: AppColors.primaryAmber)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  IconData _getLogIcon(String iconType) {
    if (iconType == 'approved' || iconType == 'check') return Icons.check_circle_outline_rounded;
    if (iconType == 'flag' || iconType == 'flagged') return Icons.flag_outlined;
    if (iconType == 'add' || iconType == 'book') return Icons.add_circle_outline_rounded;
    return Icons.info_outline_rounded;
  }
}
