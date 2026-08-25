import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_error_banner.dart';

/// Halaman lupa password (Sesuai DESIGN.md).
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).clearError();
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSuccess = authState.isSuccess && !authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          child: isSuccess
              ? _buildSuccessState(context)
              : _buildFormState(context, authState),
        ),
      ),
    );
  }

  // ── State Sukses ────────────────────────────────────────────────────────

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.massive),

        // Ilustrasi sukses
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.successContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 48,
            color: AppColors.success,
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        Text(
          'Email Terkirim! 📬',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          'Link untuk mereset password telah dikirim ke:\n${_emailCtrl.text}',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Periksa folder Spam atau Promosi jika tidak menemukan emailnya.',
          style: AppTextStyles.captionSmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.giant),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(
              'Kembali ke Halaman Masuk',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusXxl,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── State Form ──────────────────────────────────────────────────────────

  Widget _buildFormState(BuildContext context, AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Text(
            'Lupa Password? 🔑',
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Masukkan email yang terdaftar dan kami akan mengirimkan link untuk mereset passwordmu.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // ── Error Banner ─────────────────────────────────────────
          AuthErrorBanner(message: authState.errorMessage),
          if (authState.errorMessage != null)
            const SizedBox(height: AppSpacing.lg),

          // ── Email Field ──────────────────────────────────────────
          Text(
            'Email',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            onFieldSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (ref.read(authControllerProvider).errorMessage != null) {
                ref.read(authControllerProvider.notifier).clearError();
              }
            },
            decoration: InputDecoration(
              hintText: 'nama@email.com',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral400,
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusXxl,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusXxl,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusXxl,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusXxl,
                borderSide: const BorderSide(color: AppColors.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusXxl,
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
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

          const SizedBox(height: AppSpacing.xxxl),

          // ── Tombol Kirim ─────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusXxl,
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
                      'Kirim Link Reset',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
