import 'package:flutter/material.dart';

/// Widget grafik garis custom yang ringan dan adaptif menggunakan [CustomPainter].
class CustomSparklineChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final Color lineColor;
  final List<Color>? gradientColors;
  final double height;
  final String unit;

  const CustomSparklineChart({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = Colors.teal,
    this.gradientColors,
    this.height = 130,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [lineColor.withValues(alpha: 0.35), lineColor.withValues(alpha: 0.0)];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            if (data.isEmpty)
              SizedBox(
                height: height,
                child: const Center(
                  child: Text(
                    'Belum ada data latihan',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rerata: ${(data.reduce((a, b) => a + b) / data.length).toStringAsFixed(1)}$unit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Min: ${data.reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} | Max: ${data.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: height,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SparklinePainter(data, lineColor, colors),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final List<Color> fillColors;

  _SparklinePainter(this.data, this.lineColor, this.fillColors);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height;

    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);

    if (minVal == maxVal) {
      minVal -= 10;
      maxVal += 10;
    }

    final valRange = maxVal - minVal;
    final stepX = width / (data.length - 1 == 0 ? 1 : data.length - 1);

    final path = Path();
    final fillPath = Path();

    double getX(int index) => index * stepX;
    double getY(double val) {
      final ratio = (val - minVal) / valRange;
      return height - (ratio * height * 0.76 + height * 0.12);
    }

    path.moveTo(getX(0), getY(data[0]));
    fillPath.moveTo(getX(0), height);
    fillPath.lineTo(getX(0), getY(data[0]));

    for (int i = 1; i < data.length; i++) {
      final x = getX(i);
      final y = getY(data[i]);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(getX(data.length - 1), height);
    fillPath.close();

    // Lukis shader gradien pengisi area bawah
    final rect = Offset.zero & size;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: fillColors,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Lukis garis grafik outline
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, linePaint);

    // Lukis titik-titik data penunjuk akurat
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final offset = Offset(getX(i), getY(data[i]));
      canvas.drawCircle(offset, 4.0, borderPaint);
      canvas.drawCircle(offset, 3.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
