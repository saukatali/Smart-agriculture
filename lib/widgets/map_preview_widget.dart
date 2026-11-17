import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MapPreviewWidget extends StatelessWidget {
  final double height;

  const MapPreviewWidget({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _AgHubMapPainter(),
            ),
          ),
          // Floating badge on map
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, size: 12, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Radius: 50km active supply zone',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgHubMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Land base
    final bgPaint = Paint()..color = const Color(0xFFE8F0E4);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Subtle field parcels
    final parcelPaint = Paint()..color = const Color(0xFFDFEAD8);
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.4, h * 0.4), parcelPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.3, w * 0.4, h * 0.7), parcelPaint);

    // River (Curving blue band)
    final riverPaint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(0, h * 0.75);
    riverPath.cubicTo(w * 0.35, h * 0.85, w * 0.4, h * 0.25, w, h * 0.3);
    canvas.drawPath(riverPath, riverPaint);

    // Roads (subtle white lines)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.35), Offset(w, h * 0.65), roadPaint);
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.45, h), roadPaint);

    // Center zone circle
    final zoneFill = Paint()..color = AppColors.primary.withOpacity(0.08);
    final zoneStroke = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final hubCenter = Offset(w * 0.5, h * 0.45);
    canvas.drawCircle(hubCenter, 28, zoneFill);
    canvas.drawCircle(hubCenter, 28, zoneStroke);

    // Hub Pin Icon
    final pinPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(hubCenter, 4, pinPaint);
    final pinOuter = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(hubCenter, 4, pinOuter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
