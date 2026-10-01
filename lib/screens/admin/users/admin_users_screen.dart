import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin_metrics.dart';
import '../../../providers/admin_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedRoleFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    final users = admin.usersDirectory.where((user) {
      final matchesRole = _selectedRoleFilter == 'All' ||
          (_selectedRoleFilter == 'Admin' && user.role == UserRole.admin) ||
          (_selectedRoleFilter == 'Curator' && user.role == UserRole.curator) ||
          (_selectedRoleFilter == 'Reader' && user.role == UserRole.reader);

      final matchesQuery = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesRole && matchesQuery;
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
                  Text(
                    'Users Directory',
                    style: AppTypography.displayMedium(color: AppColors.secondaryIndigo),
                  ),
                  Text(
                    'Manage reader accounts, curatorial privileges & system roles',
                    style: AppTypography.bodySmall(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search user by name or email...',
                        hintStyle: AppTypography.bodySmall(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAmber, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Admin', 'Curator', 'Reader'].map((role) {
                        final isSelected = _selectedRoleFilter == role;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(role),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedRoleFilter = role);
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

            // Users List
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        'No users found',
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserCard(context, user, admin);
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

  Widget _buildUserCard(BuildContext context, AdminUserRecord user, AdminProvider admin) {
    Color roleBadgeBg;
    Color roleBadgeText;

    switch (user.role) {
      case UserRole.admin:
        roleBadgeBg = const Color(0xFFFEF3C7);
        roleBadgeText = const Color(0xFF92400E);
        break;
      case UserRole.curator:
        roleBadgeBg = const Color(0xFFEDE9FE);
        roleBadgeText = const Color(0xFF5B21B6);
        break;
      case UserRole.reader:
        roleBadgeBg = AppColors.surfaceContainerLow;
        roleBadgeText = AppColors.secondaryLightIndigo;
        break;
    }

    final isSuspended = user.status == UserAccountStatus.suspended;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuspended ? const Color(0xFFFCA5A5) : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryIndigo.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user.avatarUrl),
            onBackgroundImageError: (context, error) {},
            child: Text(user.name[0]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.labelLarge(color: AppColors.secondaryIndigo),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role.name.toUpperCase(),
                        style: AppTypography.labelSmall(color: roleBadgeText)
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTypography.bodySmall(color: AppColors.textMuted).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${user.booksRead} books read • ${user.reviewsCount} reviews • Joined ${user.joinedDate}',
                  style: AppTypography.labelSmall(color: AppColors.textSecondary).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.secondaryIndigo),
            onSelected: (val) {
              if (val == 'make_admin') {
                admin.updateUserRole(user.id, UserRole.admin);
              } else if (val == 'make_curator') {
                admin.updateUserRole(user.id, UserRole.curator);
              } else if (val == 'make_reader') {
                admin.updateUserRole(user.id, UserRole.reader);
              } else if (val == 'toggle_status') {
                admin.toggleUserStatus(user.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSuspended
                          ? 'Account for ${user.name} reactivated'
                          : 'Account for ${user.name} suspended',
                    ),
                  ),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'make_curator',
                child: Text('Assign Curator Role'),
              ),
              const PopupMenuItem(
                value: 'make_admin',
                child: Text('Assign Admin Role'),
              ),
              const PopupMenuItem(
                value: 'make_reader',
                child: Text('Set as Standard Reader'),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: Text(
                  isSuspended ? 'Reactivate Account' : 'Suspend Account',
                  style: TextStyle(color: isSuspended ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
