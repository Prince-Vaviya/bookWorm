import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../admin/admin_shell.dart';
import '../main_shell.dart';
import '../onboarding/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(
    text: 'reader@test.app',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'sanctuary2026',
  );
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  int _selectedRoleIndex = 0; // 0: Reader, 1: Administrator

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final libraryProvider = context.read<LibraryProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final role = _selectedRoleIndex == 1 ? 'admin' : 'reader';

    bool success = false;
    if (_isSignUpMode) {
      final name = _nameController.text.trim();
      success = await authProvider.signUp(
        email: email,
        password: password,
        name: name.isNotEmpty
            ? name
            : (_selectedRoleIndex == 1 ? 'Administrator' : 'Reader'),
        role: role,
      );
    } else {
      success = await authProvider.signIn(email: email, password: password);
    }

    if (!mounted) return;

    if (success) {
      final user = authProvider.user;
      final userName =
          user?.displayName ??
          (_isSignUpMode
              ? _nameController.text.trim()
              : email.split('@').first);

      if (role == 'admin' || authProvider.isAdmin) {
        libraryProvider.loginAsAdmin();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AdminShell(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        libraryProvider.loginAsReader(
          name: userName.isNotEmpty ? userName : 'Reader',
          isFirstTimeSignUp: _isSignUpMode,
        );

        // Only show the onboarding screen if and only if they created an account.
        // Existing readers signing in are directed straight to their sanctuary.
        final destination = _isSignUpMode
            ? const OnboardingScreen()
            : const MainShell();

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                destination,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      // Show error snackbar
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    _forgotEmailController.text = _emailController.text.trim();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.primaryAmber),
            const SizedBox(width: 10),
            Text(
              'Reset Password',
              style: AppTypography.headlineSmall(
                color: AppColors.secondaryIndigo,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered email address. We will send you a secure Firebase password reset link.',
              style: AppTypography.bodySmall(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _forgotEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'reader@test.app',
                prefixIcon: const Icon(
                  Icons.email_outlined,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _forgotEmailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(dialogCtx);
                final auth = context.read<AuthProvider>();
                final ok = await auth.resetPassword(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Password reset email sent to $email'
                            : (auth.errorMessage ??
                                  'Failed to send reset email'),
                      ),
                      backgroundColor: ok
                          ? AppColors.secondaryIndigo
                          : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('SEND RESET LINK'),
          ),
        ],
      ),
    );
  }

  void _fillDemoReader() {
    setState(() {
      _selectedRoleIndex = 0;
      _nameController.text = 'eagle';
      _emailController.text = 'reader@test.app';
      _passwordController.text = 'sanctuary2026';
      _confirmPasswordController.text = 'sanctuary2026';
    });
  }

  void _fillDemoAdmin() {
    setState(() {
      _selectedRoleIndex = 1;
      _nameController.text = 'Chief Curator';
      _emailController.text = 'admin@test.app';
      _passwordController.text = 'archival2026';
      _confirmPasswordController.text = 'archival2026';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.canvasPaper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo & Header
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryIndigo,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryIndigo.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Book',
                          style: AppTypography.displayLarge(
                            color: AppColors.secondaryIndigo,
                          ).copyWith(fontSize: 28),
                        ),
                        Text(
                          'Worm',
                          style: AppTypography.displayLarge(
                            color: AppColors.primaryAmber,
                          ).copyWith(fontSize: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isSignUpMode
                          ? 'Create your personalized cloud sanctuary'
                          : 'Sign in to your intellectual sanctuary',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Auth Mode Switcher (Sign In vs Create Account)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isSignUpMode = false;
                                  authProvider.clearError();
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !_isSignUpMode
                                      ? AppColors.secondaryIndigo
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: AppTypography.labelMedium(
                                    color: !_isSignUpMode
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isSignUpMode = true;
                                  authProvider.clearError();
                                  if (_confirmPasswordController.text.isEmpty) {
                                    _confirmPasswordController.text =
                                        _passwordController.text;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isSignUpMode
                                      ? AppColors.secondaryIndigo
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Create Account',
                                  style: AppTypography.labelMedium(
                                    color: _isSignUpMode
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Role Selector Segment (Reader vs Administrator)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedRoleIndex = 0),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedRoleIndex == 0
                                      ? AppColors.surfaceContainerLow
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: _selectedRoleIndex == 0
                                      ? Border.all(
                                          color: AppColors.primaryAmber,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      size: 16,
                                      color: _selectedRoleIndex == 0
                                          ? AppColors.primaryAmber
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Reader',
                                      style: AppTypography.labelSmall(
                                        color: _selectedRoleIndex == 0
                                            ? AppColors.secondaryIndigo
                                            : AppColors.textSecondary,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedRoleIndex = 1),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedRoleIndex == 1
                                      ? AppColors.surfaceContainerLow
                                      : Colors.transparent,
                                  border: _selectedRoleIndex == 1
                                      ? Border.all(
                                          color: AppColors.primaryAmber,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings_rounded,
                                      size: 16,
                                      color: _selectedRoleIndex == 1
                                          ? AppColors.primaryAmber
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Admin',
                                      style: AppTypography.labelSmall(
                                        color: _selectedRoleIndex == 1
                                            ? AppColors.secondaryIndigo
                                            : AppColors.textSecondary,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Main Auth Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryIndigo.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sign Up: Name Field
                          if (_isSignUpMode) ...[
                            Text(
                              'FULL NAME',
                              style:
                                  AppTypography.labelSmall(
                                    color: AppColors.secondaryIndigo,
                                  ).copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              validator: (val) {
                                if (_isSignUpMode &&
                                    (val == null || val.trim().isEmpty)) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g. Elena Rostova',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.primaryAmber,
                                ),
                                filled: true,
                                fillColor: AppColors.canvasPaper,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Email Field
                          Text(
                            'EMAIL ADDRESS',
                            style:
                                AppTypography.labelSmall(
                                  color: AppColors.secondaryIndigo,
                                ).copyWith(
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'reader@test.app',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryAmber,
                              ),
                              filled: true,
                              fillColor: AppColors.canvasPaper,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Password Field
                          Text(
                            'PASSWORD',
                            style:
                                AppTypography.labelSmall(
                                  color: AppColors.secondaryIndigo,
                                ).copyWith(
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primaryAmber,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.canvasPaper,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                            ),
                          ),

                          // Sign Up: Confirm Password Field
                          if (_isSignUpMode) ...[
                            const SizedBox(height: 14),
                            Text(
                              'CONFIRM PASSWORD',
                              style:
                                  AppTypography.labelSmall(
                                    color: AppColors.secondaryIndigo,
                                  ).copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: (val) {
                                if (_isSignUpMode &&
                                    val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: AppColors.primaryAmber,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.canvasPaper,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // Options (Remember me & Forgot password)
                          if (!_isSignUpMode)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: AppColors.primaryAmber,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) => setState(
                                          () => _rememberMe = val ?? true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: AppTypography.bodySmall(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: _showForgotPasswordDialog,
                                  child: Text(
                                    'Forgot password?',
                                    style: AppTypography.bodySmall(
                                      color: AppColors.primaryAmber,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 18),

                          // Submit Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleAuthSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRoleIndex == 1
                                    ? AppColors.secondaryIndigo
                                    : AppColors.primaryAmber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isSignUpMode
                                          ? (_selectedRoleIndex == 1
                                                ? 'CREATE ADMIN ACCOUNT'
                                                : 'CREATE READER ACCOUNT')
                                          : (_selectedRoleIndex == 1
                                                ? 'SIGN IN AS ADMINISTRATOR'
                                                : 'SIGN IN AS READER'),
                                      style:
                                          AppTypography.labelLarge(
                                            color: Colors.white,
                                          ).copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Demo Test Credentials Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                size: 16,
                                color: AppColors.primaryAmber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'QUICK DEV / DEMO CREDENTIALS',
                                style:
                                    AppTypography.labelSmall(
                                      color: AppColors.secondaryIndigo,
                                    ).copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _fillDemoReader,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Fill Reader',
                                    style: AppTypography.labelSmall(
                                      color: AppColors.secondaryIndigo,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _fillDemoAdmin,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Fill Admin',
                                    style: AppTypography.labelSmall(
                                      color: AppColors.primaryAmber,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cloud Firebase status badge
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_done_rounded,
                            size: 14,
                            color: AppColors.primaryDarkAmber,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Firebase Auth & Cloud Storage Connected',
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
