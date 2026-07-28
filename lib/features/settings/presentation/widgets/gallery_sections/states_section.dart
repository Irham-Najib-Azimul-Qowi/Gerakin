import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/states/empty_state.dart';
import '../../../../../shared/widgets/states/error_state.dart';

/// Section states di Component Gallery.
class StatesSection extends StatelessWidget {
  const StatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('States', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),

        Text('Empty State', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        const SizedBox(
          height: 260,
          child: EmptyState(
            title: 'Belum Ada Workout',
            subtitle: 'Mulai workout pertamamu sekarang!',
            icon: Icons.fitness_center_rounded,
            actionLabel: 'Mulai Workout',
          ),
        ),
        Gap(AppSpacing.xxl),

        Text('Error State', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        const SizedBox(
          height: 280,
          child: ErrorState(
            title: 'Gagal Memuat Data',
            message: 'Periksa koneksi internet kamu dan coba lagi.',
          ),
        ),
      ],
    );
  }
}
