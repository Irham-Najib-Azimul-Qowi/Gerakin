import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Helper untuk menampilkan bottom sheet standar GERAKIN.
class AppBottomSheet {
  AppBottomSheet._();

  /// Menampilkan bottom sheet dengan judul dan konten.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    bool isDismissible = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xs,
                AppSpacing.xxl,
                AppSpacing.lg,
              ),
              child: Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingPageHorizontal,
                child: child,
              ),
            ),
            Gap(AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
