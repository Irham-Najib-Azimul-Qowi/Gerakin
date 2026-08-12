import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Widget banner error yang reusable untuk halaman-halaman auth.
///
/// Menampilkan pesan error dari [AuthState.errorMessage] dengan tampilan
/// yang ramah dan informatif. Dipakai di [LoginPage], [RegisterPage],
/// dan [ForgotPasswordPage].
class AuthErrorBanner extends StatelessWidget {
  /// Pesan error yang akan ditampilkan. Jika `null`, widget tidak dirender.
  final String? message;

  /// Animasi fade-in opsional saat banner muncul (default: true).
  final bool animated;

  const AuthErrorBanner({
    super.key,
    required this.message,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();

    final banner = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (!animated) return banner;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: banner,
    );
  }
}
