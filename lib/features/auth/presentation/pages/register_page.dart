import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_error_banner.dart';

/// Halaman pendaftaran akun baru dengan nama, email, dan password.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).clearError();

    await ref.read(authControllerProvider.notifier).signUp(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text,
        );

    final authState = ref.read(authControllerProvider);
    if (!mounted) return;

    if (authState.isSuccess) {
      // Jika profil baru dibuat → arahkan ke Assessment Wizard untuk isi data fisik
      if (authState.requiresAssessment) {
        context.go('/assessment-wizard');
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.onSurface,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────
                Text(
                  'Buat Akun\nGerakIn ✨',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Daftar gratis dan mulai latihan adaptifmu hari ini.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Error Banner ──────────────────────────────────────
                AuthErrorBanner(message: authState.errorMessage),
                if (authState.errorMessage != null)
                  const SizedBox(height: AppSpacing.lg),

                // ── Nama Lengkap ──────────────────────────────────────
                _buildLabel('Nama Lengkap'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hint: 'Nama kamu',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (val.trim().length < 2) {
                      return 'Nama minimal 2 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Email ─────────────────────────────────────────────
                _buildLabel('Email'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  onChanged: (_) {
                    if (ref.read(authControllerProvider).errorMessage != null) {
                      ref.read(authControllerProvider.notifier).clearError();
                    }
                  },
                  decoration: _inputDecoration(
                    hint: 'nama@email.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Password ──────────────────────────────────────────
                _buildLabel('Password'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hint: 'Minimal 6 karakter',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.neutral500,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (val.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Konfirmasi Password ───────────────────────────────
                _buildLabel('Konfirmasi Password'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _inputDecoration(
                    hint: 'Ulangi password',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.neutral500,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (val != _passwordCtrl.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Tombol Daftar ─────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                      disabledBackgroundColor:
                          AppColors.secondary.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Daftar Sekarang',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.onSecondary,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Link ke Login ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          context.pushReplacementNamed(RouteNames.login),
                      child: Text(
                        'Masuk',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.secondary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurface),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral400),
      prefixIcon: Icon(prefixIcon, color: AppColors.neutral500, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
    );
  }
}
