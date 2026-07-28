import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';

/// Card container dasar yang digunakan sebagai section wrapper.
///
/// Semua card spesifik (WorkoutCard, dll.) bisa menggunakan ini sebagai base.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.shadow,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadow;
  final Border? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? AppSpacing.paddingAllLg,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLow,
        borderRadius: borderRadius ?? AppRadius.borderRadiusLg,
        boxShadow: shadow ?? AppShadows.sm,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
