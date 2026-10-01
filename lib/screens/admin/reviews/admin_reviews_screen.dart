import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin_metrics.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/rating_stars.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  ModerationStatus _selectedTab = ModerationStatus.pending;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final library = context.watch<LibraryProvider>();

    final reviews = admin.moderationQueue
        .where((r) => r.status == _selectedTab)
        .toList();

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
                      Text(
                        'Review Moderation',
                        style: AppTypography.displayMedium(color: AppColors.secondaryIndigo),
                      ),
                      Text(
                        'Audit community contributions & maintain editorial standards',
                        style: AppTypography.bodySmall(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Segmented Status Filter
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildTabButton('Pending (${admin.pendingReviewsCount})', ModerationStatus.pending),
                            _buildTabButton('Flagged (${admin.flaggedReviewsCount})', ModerationStatus.flagged),
                            _buildTabButton('Approved', ModerationStatus.approved),
                            _buildTabButton('Rejected', ModerationStatus.rejected),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Review List
                Expanded(
                  child: reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 52, color: AppColors.successGreen),
                              const SizedBox(height: 12),
                              Text(
                                'Queue is Clear',
                                style: AppTypography.titleMedium(color: AppColors.secondaryIndigo),
                              ),
                              Text(
                                'No reviews in the ${_selectedTab.name} queue',
                                style: AppTypography.bodySmall(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final item = reviews[index];
                            return _buildModerationCard(context, item, admin, library);
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

  Widget _buildTabButton(String title, ModerationStatus status) {
    final isSelected = _selectedTab == status;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = status;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: AppTypography.labelSmall(
              color: isSelected ? Colors.white : AppColors.secondaryIndigo,
            ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildModerationCard(
    BuildContext context,
    ModerationReview item,
    AdminProvider admin,
    LibraryProvider library,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.status == ModerationStatus.flagged
              ? const Color(0xFFFCA5A5)
              : AppColors.borderLight,
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLightAmber,
                child: Text(
                  item.reviewerName[0],
                  style: AppTypography.labelMedium(color: AppColors.primaryDarkAmber),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.reviewerName,
                      style: AppTypography.labelLarge(color: AppColors.secondaryIndigo),
                    ),
                    Text(
                      'For "${item.bookTitle}" • ${item.submittedDate}',
                      style: AppTypography.bodySmall(color: AppColors.textMuted).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: item.rating, iconSize: 13),
            ],
          ),

          if (item.flagReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.flagReason!,
                      style: AppTypography.labelSmall(color: Colors.red).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            item.comment,
            style: AppTypography.bodyMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          if (item.status == ModerationStatus.pending || item.status == ModerationStatus.flagged)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      admin.rejectReview(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review rejected')),
                      );
                    },
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                    label: const Text('REJECT', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      admin.approveReview(item.id, library);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review approved and published!')),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('APPROVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
