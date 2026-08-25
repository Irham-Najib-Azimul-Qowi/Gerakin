import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../user/data/repositories/user_repository_impl.dart';
import '../../../user/services/guest_session_manager.dart';

/// Halaman gateway autentikasi — pintu masuk ke Login, Register, atau mode Tamu (Sesuai DESIGN.md).
///
/// Personality: Bright, Friendly, Inclusive, Cheerful, Modern, Premium.
class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.huge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.massive),

                // ── Logo & Branding ─────────────────────────────────
                _buildBranding(context),

                const SizedBox(height: AppSpacing.giant),

                // ── Tagline ─────────────────────────────────────────
                _buildTagline(context),

                const SizedBox(height: AppSpacing.giant),

                // ── Tombol Utama ─────────────────────────────────────
                _buildPrimaryButton(
                  context,
                  label: 'Masuk',
                  icon: Icons.login_rounded,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  onPressed: () => context.pushNamed(RouteNames.login),
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildSecondaryButton(
                  context,
                  label: 'Daftar Akun Baru',
                  icon: Icons.person_add_rounded,
                  onPressed: () => context.pushNamed(RouteNames.register),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Divider ─────────────────────────────────────────
                _buildDivider(context),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Tombol Guest ────────────────────────────────────
                _buildGuestButton(context, ref),

                const SizedBox(height: AppSpacing.xxl),

                // ── Catatan privasi kecil ────────────────────────────
                Text(
                  'Dengan mendaftar, kamu menyetujui\nKebijakan Privasi & Syarat Penggunaan GerakIn.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildBranding(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderRadiusXxl,
            boxShadow: AppShadows.softCard,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Image.asset(
            'assets/images/logo-gerakin.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'GerakIn',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline(BuildContext context) {
    return Column(
      children: [
        Text(
          'Mulai Perjalanan\nKesehatanmu',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Fitnes adaptif & rehabilitasi untuk pengguna kursi roda.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXxl, // 24px
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: AppColors.onSecondaryContainer),
        label: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSecondaryContainer,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXxl, // 24px
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'atau',
            style: AppTextStyles.captionSmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildGuestButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        final userRepo = ref.read(userRepositoryProvider);
        final guestManager = GuestSessionManager(userRepo);
        await guestManager.startGuestSession();
        if (context.mounted) {
          context.go('/');
        }
      },
      icon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textPrimary),
      label: Text(
        'Lanjutkan sebagai Tamu',
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXxl, // 24px
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
