import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TrendLineChart extends StatelessWidget {
  final double height;

  const TrendLineChart({
    super.key,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendChartPainter(),
          ),
        ),
        const SizedBox(height: 10),
        // Legend row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem(AppColors.chartLineGreen, 'Wheat'),
                const SizedBox(width: 10),
                _buildLegendItem(AppColors.chartLineAmber, 'Tomato'),
              ],
            ),
            const Flexible(
              child: Text(
                'Updated 10m ago',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw subtle horizontal grid lines
    final gridPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      double y = h * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Wheat curve points (Green)
    final wheatPoints = [
      Offset(0, h * 0.75),
      Offset(w * 0.2, h * 0.70),
      Offset(w * 0.45, h * 0.42),
      Offset(w * 0.7, h * 0.45),
      Offset(w * 1.0, h * 0.25),
    ];

    // Tomato curve points (Orange)
    final tomatoPoints = [
      Offset(0, h * 0.85),
      Offset(w * 0.25, h * 0.80),
      Offset(w * 0.5, h * 0.60),
      Offset(w * 0.75, h * 0.52),
      Offset(w * 1.0, h * 0.38),
    ];

    // Fill under wheat
    final fillPath = Path()..moveTo(0, h);
    fillPath.lineTo(wheatPoints[0].dx, wheatPoints[0].dy);
    _addSmoothCurve(fillPath, wheatPoints);
    fillPath.lineTo(w, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.12),
          AppColors.primary.withOpacity(0.01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(fillPath, fillPaint);

    // Stroke Wheat Line
    final wheatStroke = Paint()
      ..color = AppColors.chartLineGreen
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wheatPath = Path()..moveTo(wheatPoints[0].dx, wheatPoints[0].dy);
    _addSmoothCurve(wheatPath, wheatPoints);
    canvas.drawPath(wheatPath, wheatStroke);

    // Stroke Tomato Line
    final tomatoStroke = Paint()
      ..color = AppColors.chartLineAmber
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tomatoPath = Path()..moveTo(tomatoPoints[0].dx, tomatoPoints[0].dy);
    _addSmoothCurve(tomatoPath, tomatoPoints);
    canvas.drawPath(tomatoPath, tomatoStroke);

    // Draw active dot at endpoint
    final dotFill = Paint()..color = Colors.white;
    final dotStroke = Paint()
      ..color = AppColors.chartLineGreen
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lastPt = wheatPoints.last;
    canvas.drawCircle(lastPt, 4.5, dotFill);
    canvas.drawCircle(lastPt, 4.5, dotStroke);
  }

  void _addSmoothCurve(Path path, List<Offset> points) {
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPt1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPt2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(controlPt1.dx, controlPt1.dy, controlPt2.dx, controlPt2.dy, p1.dx, p1.dy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
