import 'package:flutter/material.dart';

/// Widget pembungkus aman untuk me-render gambar ilustrasi & thumbnail latihan.
///
/// Dilengkapi dengan [errorBuilder] fallback placeholder agar aplikasi tidak crash
/// jika file gambar belum di-upload di folder assets.
class IllustrationImageWidget extends StatelessWidget {
  const IllustrationImageWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12.0,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFF1E293B),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF00E676),
                  size: 32,
                ),
                SizedBox(height: 6),
                Text(
                  'Ilustrasi GerakIn',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
