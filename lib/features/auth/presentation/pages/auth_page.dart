import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../user/data/repositories/user_repository_impl.dart';
import '../../../user/services/guest_session_manager.dart';

/// Halaman gateway autentikasi — pintu masuk ke Login, Register, atau mode Tamu.
///
/// Menggantikan placeholder lama dan menjadi hub navigasi untuk semua alur auth.
class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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

                _buildPrimaryButton(
                  context,
                  label: 'Daftar Akun Baru',
                  icon: Icons.person_add_rounded,
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral500,
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.accessibility_new_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'GerakIn',
          style: AppTextStyles.headlineMedium.copyWith(
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
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Latihan adaptif untuk pengguna kursi roda,\ntersedia online maupun offline.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.neutral600,
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
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: AppTextStyles.labelLarge),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'atau',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1)),
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
      icon: const Icon(Icons.person_outline_rounded, size: 20),
      label: Text(
        'Lanjutkan sebagai Tamu',
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neutral700,
        side: BorderSide(color: AppColors.outlineVariant, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
