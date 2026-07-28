import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/buttons/app_icon_button.dart';

/// Section tombol di Component Gallery.
class ButtonsSection extends StatelessWidget {
  const ButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buttons', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),

        // Variants
        Text('Variants', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(label: 'Primary', onPressed: () {}),
            AppButton(
              label: 'Secondary',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            AppButton(
              label: 'Outlined',
              variant: AppButtonVariant.outlined,
              onPressed: () {},
            ),
            AppButton(
              label: 'Text',
              variant: AppButtonVariant.text,
              onPressed: () {},
            ),
          ],
        ),
        Gap(AppSpacing.xxl),

        // Sizes
        Text('Sizes', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppButton(
              label: 'Small',
              size: AppButtonSize.small,
              onPressed: () {},
            ),
            AppButton(
              label: 'Medium',
              size: AppButtonSize.medium,
              onPressed: () {},
            ),
            AppButton(
              label: 'Large',
              size: AppButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
        Gap(AppSpacing.xxl),

        // With Icon
        Text('With Icon', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: 'Mulai',
              icon: Icons.play_arrow_rounded,
              onPressed: () {},
            ),
            AppButton(
              label: 'Simpan',
              icon: Icons.save_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: () {},
            ),
          ],
        ),
        Gap(AppSpacing.xxl),

        // States
        Text('States', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
            AppButton(label: 'Disabled', isDisabled: true, onPressed: () {}),
            AppButton(label: 'Expanded', isExpanded: true, onPressed: () {}),
          ],
        ),
        Gap(AppSpacing.xxl),

        // Icon Buttons
        Text('Icon Buttons', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppIconButton(
              icon: Icons.favorite_rounded,
              variant: AppIconButtonVariant.filled,
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.share_rounded,
              variant: AppIconButtonVariant.outlined,
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.bookmark_rounded,
              variant: AppIconButtonVariant.tonal,
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.more_vert_rounded,
              variant: AppIconButtonVariant.ghost,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
