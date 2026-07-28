import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../../shared/widgets/feedback/app_snackbar.dart';

/// Section feedback di Component Gallery.
class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feedback', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),

        // Dialogs
        Text('Dialogs', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: 'Success',
              size: AppButtonSize.small,
              onPressed: () => AppDialog.success(
                context,
                title: 'Berhasil!',
                message: 'Workout berhasil disimpan.',
              ),
            ),
            AppButton(
              label: 'Error',
              size: AppButtonSize.small,
              variant: AppButtonVariant.outlined,
              onPressed: () => AppDialog.error(
                context,
                title: 'Gagal',
                message: 'Terjadi kesalahan saat menyimpan data.',
              ),
            ),
            AppButton(
              label: 'Confirm',
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              onPressed: () => AppDialog.confirmation(
                context,
                title: 'Hapus Workout?',
                message: 'Workout ini akan dihapus secara permanen.',
              ),
            ),
          ],
        ),
        Gap(AppSpacing.xxl),

        // Snackbars
        Text('Snackbars', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: 'Success',
              size: AppButtonSize.small,
              onPressed: () =>
                  AppSnackbar.success(context, 'Data berhasil disimpan!'),
            ),
            AppButton(
              label: 'Error',
              size: AppButtonSize.small,
              variant: AppButtonVariant.outlined,
              onPressed: () =>
                  AppSnackbar.error(context, 'Terjadi kesalahan!'),
            ),
            AppButton(
              label: 'Info',
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              onPressed: () =>
                  AppSnackbar.info(context, 'Update tersedia.'),
            ),
            AppButton(
              label: 'Warning',
              size: AppButtonSize.small,
              variant: AppButtonVariant.text,
              onPressed: () =>
                  AppSnackbar.warning(context, 'Koneksi tidak stabil.'),
            ),
          ],
        ),
        Gap(AppSpacing.xxl),

        // Bottom Sheet
        Text('Bottom Sheet', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        AppButton(
          label: 'Show Bottom Sheet',
          variant: AppButtonVariant.outlined,
          size: AppButtonSize.small,
          onPressed: () => AppBottomSheet.show(
            context,
            title: 'Pilih Workout',
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fitness_center_rounded),
                  title: Text('Push Up', style: AppTextStyles.bodyMedium),
                  subtitle: Text('15 menit', style: AppTextStyles.captionMedium),
                ),
                ListTile(
                  leading: const Icon(Icons.directions_run_rounded),
                  title: Text('Jogging', style: AppTextStyles.bodyMedium),
                  subtitle: Text('30 menit', style: AppTextStyles.captionMedium),
                ),
                ListTile(
                  leading: const Icon(Icons.self_improvement_rounded),
                  title: Text('Yoga', style: AppTextStyles.bodyMedium),
                  subtitle: Text('20 menit', style: AppTextStyles.captionMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
