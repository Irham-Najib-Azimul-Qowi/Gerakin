import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';

/// Section input di Component Gallery.
class InputsSection extends StatelessWidget {
  const InputsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inputs', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),
        AppTextField(
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
          prefixIcon: Icons.person_outline_rounded,
          helperText: 'Nama akan ditampilkan di profil',
        ),
        Gap(AppSpacing.lg),
        AppTextField(
          label: 'Email',
          hint: 'contoh@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        Gap(AppSpacing.lg),
        AppTextField(
          label: 'Password',
          hint: 'Minimal 8 karakter',
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: Icons.visibility_off_outlined,
          obscureText: true,
        ),
        Gap(AppSpacing.lg),
        AppTextField(
          label: 'Cari Workout',
          hint: 'Ketik untuk mencari...',
          prefixIcon: Icons.search_rounded,
          suffixIcon: Icons.tune_rounded,
        ),
        Gap(AppSpacing.lg),
        AppTextField(
          label: 'Input Error',
          hint: 'Contoh input error',
          errorText: 'Field ini wajib diisi',
          prefixIcon: Icons.warning_amber_rounded,
        ),
        Gap(AppSpacing.lg),
        AppTextField(
          label: 'Disabled',
          hint: 'Input tidak aktif',
          enabled: false,
        ),
      ],
    );
  }
}
