import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Section tipografi di Component Gallery.
class TypographySection extends StatelessWidget {
  const TypographySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Typography', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.sm),
        Text(
          'Plus Jakarta Sans',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.neutral500,
          ),
        ),
        Gap(AppSpacing.lg),
        _TypographyItem('Display Large', AppTextStyles.displayLarge),
        _TypographyItem('Display Medium', AppTextStyles.displayMedium),
        _TypographyItem('Display Small', AppTextStyles.displaySmall),
        Divider(height: AppSpacing.xxl),
        _TypographyItem('Headline Large', AppTextStyles.headlineLarge),
        _TypographyItem('Headline Medium', AppTextStyles.headlineMedium),
        _TypographyItem('Headline Small', AppTextStyles.headlineSmall),
        Divider(height: AppSpacing.xxl),
        _TypographyItem('Title Large', AppTextStyles.titleLarge),
        _TypographyItem('Title Medium', AppTextStyles.titleMedium),
        _TypographyItem('Title Small', AppTextStyles.titleSmall),
        Divider(height: AppSpacing.xxl),
        _TypographyItem('Body Large', AppTextStyles.bodyLarge),
        _TypographyItem('Body Medium', AppTextStyles.bodyMedium),
        _TypographyItem('Body Small', AppTextStyles.bodySmall),
        Divider(height: AppSpacing.xxl),
        _TypographyItem('Caption Large', AppTextStyles.captionLarge),
        _TypographyItem('Caption Medium', AppTextStyles.captionMedium),
        _TypographyItem('Caption Small', AppTextStyles.captionSmall),
        Divider(height: AppSpacing.xxl),
        _TypographyItem('Label Large', AppTextStyles.labelLarge),
        _TypographyItem('Label Medium', AppTextStyles.labelMedium),
        _TypographyItem('Label Small', AppTextStyles.labelSmall),
      ],
    );
  }
}

class _TypographyItem extends StatelessWidget {
  const _TypographyItem(this.name, this.style);

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: style.copyWith(color: AppColors.onSurface)),
          Gap(AppSpacing.xxs),
          Text(
            'Size: ${style.fontSize}  •  Weight: ${style.fontWeight?.value}',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
