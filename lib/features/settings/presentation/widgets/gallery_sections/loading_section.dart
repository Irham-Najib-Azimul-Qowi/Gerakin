import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/loading/loading_card.dart';

/// Section loading di Component Gallery.
class LoadingSection extends StatelessWidget {
  const LoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Loading', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),

        Text('Loading Card (Shimmer)', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        const LoadingCard(height: 80),
        Gap(AppSpacing.sm),
        const LoadingCard(height: 120),
        Gap(AppSpacing.sm),
        Row(
          children: [
            Expanded(child: LoadingCard(height: 100)),
            Gap(AppSpacing.sm),
            Expanded(child: LoadingCard(height: 100)),
          ],
        ),
      ],
    );
  }
}
