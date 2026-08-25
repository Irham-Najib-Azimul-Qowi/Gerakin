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

/// Tombol reusable GERAKIN (Sesuai DESIGN.md).
///
/// - Primary: Full-width / Custom, Purple (#7C5CFC), White text, 24px border radius.
/// - Secondary: Sky Blue tint (#5EC8FF / #E0F2FE), 24px border radius.
/// - Touch target minimum 48px untuk aksesibilitas pengguna kursi roda / disabilitas.
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

  double get _minHeight {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return 48; // Minimum 48px touch target
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 22;
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
      style: AppTextStyles.labelLarge.copyWith(
        fontSize: _fontSize,
        fontWeight: FontWeight.bold,
        color: variant == AppButtonVariant.primary
            ? AppColors.onPrimary
            : (variant == AppButtonVariant.secondary
                ? AppColors.onSecondaryContainer
                : AppColors.primary),
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _iconSize,
            color: variant == AppButtonVariant.primary
                ? AppColors.onPrimary
                : (variant == AppButtonVariant.secondary
                    ? AppColors.onSecondaryContainer
                    : AppColors.primary),
          ),
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
        borderRadius: AppRadius.borderRadiusXxl,
      ),
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.onDisabled,
          minimumSize: Size(48, _minHeight),
          padding: _padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXxl,
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
        minimumSize: Size(48, _minHeight),
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXxl,
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
        minimumSize: Size(48, _minHeight),
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXxl,
        ),
        side: BorderSide(
          color: _isEnabled ? AppColors.primary : AppColors.disabled,
          width: 1.5,
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
        minimumSize: Size(48, _minHeight),
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXxl,
        ),
      ),
      child: child,
    );
  }
}
