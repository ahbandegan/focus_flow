import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/services/settings_preferences_service.dart';
import 'package:focus_flow/core/supabase/supabase_auth_repository.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:focus_flow/initialize_dependensies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opens the Profile Bottom Sheet Dialog
void showProfileBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return const ProfileBottomSheet();
    },
  );
}

class ProfileBottomSheet extends StatefulWidget {
  const ProfileBottomSheet({super.key});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapAuthError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid grant')) {
        return 'ایمیل یا رمز عبور اشتباه است.';
      } else if (msg.contains('user already registered') ||
          msg.contains('already exists')) {
        return 'کاربری با این مشخصات قبلاً ثبت‌نام شده است.';
      } else if (msg.contains('password should be at least')) {
        return 'رمز عبور باید حداقل ۶ کاراکتر باشد.';
      } else if (msg.contains('invalid email')) {
        return 'فرمت ایمیل وارد شده نامعتبر است.';
      }
      return error.message;
    }
    return 'خطایی در ارتباط با سرور رخ داد. لطفاً اتصال اینترنت خود را بررسی کنید.';
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final authRepo = di<SupabaseAuthRepository>();
      final AuthResponse response;

      if (_isSignUp) {
        response = await authRepo.signUp(
          email: email,
          password: password,
        );
      } else {
        response = await authRepo.signIn(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;

      final userId = response.user?.id;
      final userEmail = response.user?.email ?? email;

      await context.read<SettingsCubit>().updateLoginSession(
            email: userEmail,
            id: userId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSignUp
                  ? 'ثبت‌نام با موفقیت انجام شد و وارد شدید.'
                  : 'با موفقیت وارد حساب خود شدید.',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapAuthError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('خروج از حساب'),
        content: const Text('آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await di<SupabaseAuthRepository>().signOut();
    } catch (_) {
      // Even if remote sign out fails, clear local session
    }

    if (mounted) {
      await context.read<SettingsCubit>().logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('از حساب کاربری خارج شدید.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isLoggedIn = state.isLoggedIn;
        final userEmail = state.userEmail ??
            di<SettingsPreferencesService>().userEmail ??
            di<SupabaseAuthRepository>().currentUser?.email;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 8.0,
                  bottom: bottomInset + 20.0,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: isLoggedIn
                      ? _buildLoggedInView(
                          context,
                          userEmail: userEmail,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        )
                      : _buildAuthFormView(
                          context,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoggedInView(
    BuildContext context, {
    required String? userEmail,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final initial = (userEmail != null && userEmail.isNotEmpty)
        ? userEmail[0].toUpperCase()
        : 'U';
    final userId = di<SettingsPreferencesService>().userId ??
        di<SupabaseAuthRepository>().currentUser?.id;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'پروفایل کاربری',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'بستن',
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Avatar
        CircleAvatar(
          radius: 42,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            initial,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Email
        Text(
          userEmail ?? 'کاربر مهمان',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        // Active Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'حساب فعال و متصل',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Info Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.email_outlined, color: colorScheme.primary),
                  title: const Text('آدرس ایمیل'),
                  subtitle: Text(userEmail ?? 'تعریف نشده'),
                ),
                if (userId != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.fingerprint, color: colorScheme.primary),
                    title: const Text('شناسه کاربر'),
                    subtitle: Text(
                      userId,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.cloud_done_outlined, color: colorScheme.primary),
                  title: const Text('همگام‌سازی ابری'),
                  subtitle: const Text('پایگاه داده آنلاین فعال است'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text(
              'خروج از حساب کاربری',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAuthFormView(
    BuildContext context, {
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_circle_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isSignUp ? 'ثبت‌نام کاربر جدید' : 'ورود به حساب کاربری',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'بستن',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp
              ? 'برای ذخیره اطلاعات و همگام‌سازی فعالیت‌ها حساب جدید بسازید.'
              : 'برای دسترسی به سشن‌ها و تنظیمات شخصی وارد شوید.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 20),

        // Switch between Sign In and Sign Up
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              icon: Icon(Icons.login),
              label: Text('ورود'),
            ),
            ButtonSegment(
              value: true,
              icon: Icon(Icons.person_add_alt_1),
              label: Text('ثبت‌نام'),
            ),
          ],
          selected: {_isSignUp},
          onSelectionChanged: (val) {
            setState(() {
              _isSignUp = val.first;
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 20),

        // Error message banner
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Form fields
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'ایمیل (Email)',
                  hintText: 'example@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'لطفاً ایمیل خود را وارد کنید';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'لطفاً یک ایمیل معتبر وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitAuth(),
                decoration: InputDecoration(
                  labelText: 'رمز عبور (Password)',
                  hintText: 'حداقل ۶ کاراکتر',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'لطفاً رمز عبور را وارد کنید';
                  }
                  if (val.length < 6) {
                    return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : _submitAuth,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isSignUp ? 'ثبت‌نام و ورود' : 'ورود به حساب کاربری',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
