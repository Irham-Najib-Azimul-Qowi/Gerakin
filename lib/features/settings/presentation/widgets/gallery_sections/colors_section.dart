import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Section warna di Component Gallery.
class ColorsSection extends StatelessWidget {
  const ColorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colors', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),
        _ColorGroup(title: 'Primary', colors: const [
          _ColorItem('primary', AppColors.primary),
          _ColorItem('primaryLight', AppColors.primaryLight),
          _ColorItem('primaryDark', AppColors.primaryDark),
          _ColorItem('primaryContainer', AppColors.primaryContainer),
        ]),
        Gap(AppSpacing.lg),
        _ColorGroup(title: 'Secondary', colors: const [
          _ColorItem('secondary', AppColors.secondary),
          _ColorItem('secondaryLight', AppColors.secondaryLight),
          _ColorItem('secondaryDark', AppColors.secondaryDark),
          _ColorItem('secondaryContainer', AppColors.secondaryContainer),
        ]),
        Gap(AppSpacing.lg),
        _ColorGroup(title: 'Semantic', colors: const [
          _ColorItem('success', AppColors.success),
          _ColorItem('warning', AppColors.warning),
          _ColorItem('error', AppColors.error),
          _ColorItem('info', AppColors.info),
        ]),
        Gap(AppSpacing.lg),
        _ColorGroup(title: 'Neutral', colors: const [
          _ColorItem('neutral100', AppColors.neutral100),
          _ColorItem('neutral300', AppColors.neutral300),
          _ColorItem('neutral500', AppColors.neutral500),
          _ColorItem('neutral700', AppColors.neutral700),
          _ColorItem('neutral900', AppColors.neutral900),
        ]),
      ],
    );
  }
}

class _ColorGroup extends StatelessWidget {
  const _ColorGroup({required this.title, required this.colors});

  final String title;
  final List<_ColorItem> colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleSmall),
        Gap(AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: colors,
        ),
      ],
    );
  }
}

class _ColorItem extends StatelessWidget {
  const _ColorItem(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLight =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: isLight
                ? Border.all(color: AppColors.outlineVariant)
                : null,
          ),
          child: Center(
            child: Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: AppTextStyles.captionSmall.copyWith(
                color: isLight ? AppColors.onSurface : AppColors.onPrimary,
              ),
            ),
          ),
        ),
        Gap(AppSpacing.xs),
        SizedBox(
          width: 64,
          child: Text(
            name,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
