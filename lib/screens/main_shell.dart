import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'admin/admin_shell.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'library/library_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _switchToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminShell()),
    );
  }

  void _signOut() async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final library = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const SearchScreen(),
      const LibraryScreen(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            DesktopSidebarNav(
              currentIndex: _currentTabIndex,
              onTabSelected: _onTabSelected,
              onSwitchToAdmin: _switchToAdmin,
              onSignOut: _signOut,
              userName: auth.displayName.isNotEmpty ? auth.displayName : library.userName,
              userAvatarUrl: auth.photoUrl,
              streakDays: library.goal.currentStreakDays,
            ),
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
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
