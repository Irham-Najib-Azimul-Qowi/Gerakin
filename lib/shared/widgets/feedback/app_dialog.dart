import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Helper untuk menampilkan dialog standar GERAKIN.
class AppDialog {
  AppDialog._();

  /// Dialog sukses.
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Dialog error.
  static Future<void> error(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      icon: Icons.error_rounded,
      iconColor: AppColors.error,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Dialog konfirmasi dengan dua tombol.
  static Future<bool?> confirmation(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: AppSpacing.paddingAllXxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 56,
                color: AppColors.warning,
              ),
              Gap(AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                Gap(AppSpacing.sm),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              Gap(AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                      ),
                      child: Text(cancelText),
                    ),
                  ),
                  Gap(AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? message,
    required String buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: AppSpacing.paddingAllXxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: iconColor),
              Gap(AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                Gap(AppSpacing.sm),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              Gap(AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onPressed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
