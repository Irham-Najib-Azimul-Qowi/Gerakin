import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Variant untuk [AppButton].
enum AppButtonVariant { primary, secondary, outlined, text }

/// Ukuran untuk [AppButton].
enum AppButtonSize { small, medium, large }

/// Tombol reusable GERAKIN.
///
/// Mendukung variant, ukuran, loading state, dan icon.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isExpanded;

  bool get _isEnabled => !isDisabled && !isLoading && onPressed != null;

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        );
      case AppButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.lg,
        );
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildContent();

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = _buildPrimary(child);
      case AppButtonVariant.secondary:
        button = _buildSecondary(child);
      case AppButtonVariant.outlined:
        button = _buildOutlined(child);
      case AppButtonVariant.text:
        button = _buildText(child);
    }

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == AppButtonVariant.primary
              ? AppColors.onPrimary
              : AppColors.primary,
        ),
      );
    }

    final textWidget = Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(fontSize: _fontSize),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize),
          SizedBox(width: AppSpacing.sm),
          textWidget,
        ],
      );
    }

    return textWidget;
  }

  Widget _buildPrimary(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: _isEnabled ? AppShadows.primaryGlow : AppShadows.none,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.onDisabled,
          padding: _padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }

  Widget _buildSecondary(Widget child) {
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryContainer,
        foregroundColor: AppColors.onSecondaryContainer,
        disabledBackgroundColor: AppColors.disabledBackground,
        disabledForegroundColor: AppColors.onDisabled,
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        elevation: 0,
      ),
      child: child,
    );
  }

  Widget _buildOutlined(Widget child) {
    return OutlinedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.onDisabled,
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        side: BorderSide(
          color: _isEnabled ? AppColors.primary : AppColors.disabled,
        ),
      ),
      child: child,
    );
  }

  Widget _buildText(Widget child) {
    return TextButton(
      onPressed: _isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.onDisabled,
        padding: _padding,
      ),
      child: child,
    );
  }
}
