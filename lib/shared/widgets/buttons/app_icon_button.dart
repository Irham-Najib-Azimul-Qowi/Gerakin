import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Variant untuk [AppIconButton].
enum AppIconButtonVariant { filled, outlined, tonal, ghost }

/// Tombol ikon reusable GERAKIN.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.size = 40,
    this.iconSize = 20,
    this.tooltip,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor,
            ),
          )
        : Icon(icon, size: iconSize);

    Widget button;
    switch (variant) {
      case AppIconButtonVariant.filled:
        button = _buildFilled(child);
      case AppIconButtonVariant.outlined:
        button = _buildOutlined(child);
      case AppIconButtonVariant.tonal:
        button = _buildTonal(child);
      case AppIconButtonVariant.ghost:
        button = _buildGhost(child);
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppIconButtonVariant.filled:
        return AppColors.onPrimary;
      case AppIconButtonVariant.outlined:
      case AppIconButtonVariant.ghost:
        return AppColors.onSurfaceVariant;
      case AppIconButtonVariant.tonal:
        return AppColors.onSecondaryContainer;
    }
  }

  Widget _buildFilled(Widget child) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: child,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.onDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          padding: EdgeInsets.all(AppSpacing.sm),
        ),
      ),
    );
  }

  Widget _buildOutlined(Widget child) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: child,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          disabledForegroundColor: AppColors.onDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
            side: BorderSide(
              color: onPressed != null
                  ? AppColors.outlineVariant
                  : AppColors.disabled,
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.sm),
        ),
      ),
    );
  }

  Widget _buildTonal(Widget child) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: child,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.onDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          padding: EdgeInsets.all(AppSpacing.sm),
        ),
      ),
    );
  }

  Widget _buildGhost(Widget child) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: child,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          disabledForegroundColor: AppColors.onDisabled,
          padding: EdgeInsets.all(AppSpacing.sm),
        ),
      ),
    );
  }
}
