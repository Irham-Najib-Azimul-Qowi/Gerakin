import 'package:flutter/material.dart';
import '../models/live_alert.dart';

/// Widget Banner Peringatan Visual Bertingkat (Live Alert Banner).
///
/// Variasi Warna & Sifat:
/// - [AlertSeverity.critical]: Warna Merah Neon + Sticky (selama kondisi berlanjut).
/// - [AlertSeverity.warning]: Warna Kuning/Amber + Auto-dismiss (4-5 detik).
/// - [AlertSeverity.info]: Warna Teal/Hijau + Toast ringkas.
class LiveAlertBanner extends StatelessWidget {
  const LiveAlertBanner({
    super.key,
    required this.alert,
    this.onDismiss,
  });

  final LiveAlert? alert;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (alert == null) return const SizedBox.shrink();

    final LiveAlert activeAlert = alert!;

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;
    final Color iconBackgroundColor;

    switch (activeAlert.severity) {
      case AlertSeverity.critical:
        backgroundColor = const Color(0xFF7F1D1D).withValues(alpha: 0.92);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFFEE2E2);
        iconBackgroundColor = const Color(0xFFDC2626);
        break;
      case AlertSeverity.warning:
        backgroundColor = const Color(0xFF78350F).withValues(alpha: 0.92);
        borderColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFFFFFBEB);
        iconBackgroundColor = const Color(0xFFD97706);
        break;
      case AlertSeverity.info:
        backgroundColor = const Color(0xFF064E3B).withValues(alpha: 0.92);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFFECFDF5);
        iconBackgroundColor = const Color(0xFF059669);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey('${activeAlert.message}_${activeAlert.timestamp.millisecondsSinceEpoch}'),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                activeAlert.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeAlert.severity == AlertSeverity.critical
                        ? 'PERINGATAN KRITIS'
                        : (activeAlert.severity == AlertSeverity.warning
                            ? 'PERHATIAN'
                            : 'INFO PERFORMA'),
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeAlert.message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null && activeAlert.severity != AlertSeverity.critical)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
