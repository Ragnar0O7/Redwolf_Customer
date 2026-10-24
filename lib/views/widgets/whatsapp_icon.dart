import 'package:flutter/material.dart';

/// Pure vector WhatsApp icon rendered via CustomPainter.
/// Zero asset dependencies, 100% crisp at any resolution.
class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const WhatsAppIcon({
    super.key,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _WhatsAppPainter(
          badgeColor: color == null ? const Color(0xFF25D366) : null,
          iconColor: color ?? Colors.white,
        ),
      ),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color? badgeColor;
  final Color iconColor;

  _WhatsAppPainter({
    this.badgeColor,
    required this.iconColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    if (badgeColor != null) {
      // 1. Draw solid WhatsApp green bubble with tail
      final bgPaint = Paint()
        ..color = badgeColor!
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      // Circle centered at (12, 11.5) with radius 10.5
      final bgPath = Path();
      bgPath.addOval(Rect.fromCircle(center: Offset(12.0 * s, 11.5 * s), radius: 10.5 * s));
      
      // Speech bubble tail pointing towards bottom-left
      final tailPath = Path()
        ..moveTo(4.8 * s, 16.2 * s)
        ..lineTo(2.0 * s, 21.6 * s)
        ..lineTo(7.4 * s, 19.4 * s)
        ..close();
      bgPath.addPath(tailPath, Offset.zero);

      canvas.drawPath(bgPath, bgPaint);
    } else {
      // Monochrome outline bubble when tinted
      final outlinePaint = Paint()
        ..color = iconColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s
        ..isAntiAlias = true;

      final outlinePath = Path();
      outlinePath.addOval(Rect.fromCircle(center: Offset(12.0 * s, 11.5 * s), radius: 9.5 * s));
      final tailPath = Path()
        ..moveTo(4.8 * s, 16.2 * s)
        ..lineTo(2.2 * s, 21.2 * s)
        ..lineTo(7.4 * s, 19.4 * s);
      outlinePath.addPath(tailPath, Offset.zero);
      canvas.drawPath(outlinePath, outlinePaint);
    }

    // 2. Draw official telephone handset path
    final phonePaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final phonePath = Path();
    phonePath.moveTo(s * 17.472, s * 14.382);
    phonePath.cubicTo(s * 17.175, s * 14.233, s * 15.714, s * 13.515, s * 15.442, s * 13.415);
    phonePath.cubicTo(s * 15.169, s * 13.316, s * 14.971, s * 13.267, s * 14.772, s * 13.565);
    phonePath.cubicTo(s * 14.575, s * 13.862, s * 14.005, s * 14.531, s * 13.832, s * 14.729);
    phonePath.cubicTo(s * 13.659, s * 14.928, s * 13.485, s * 14.952, s * 13.188, s * 14.804);
    phonePath.cubicTo(s * 12.891, s * 14.654, s * 11.933, s * 14.341, s * 10.798, s * 13.329);
    phonePath.cubicTo(s * 9.915, s * 12.541, s * 9.318, s * 11.568, s * 9.145, s * 11.270);
    phonePath.cubicTo(s * 8.972, s * 10.973, s * 9.127, s * 10.812, s * 9.275, s * 10.664);
    phonePath.cubicTo(s * 9.409, s * 10.531, s * 9.573, s * 10.317, s * 9.721, s * 10.144);
    phonePath.cubicTo(s * 9.870, s * 9.970, s * 9.919, s * 9.846, s * 10.019, s * 9.647);
    phonePath.cubicTo(s * 10.118, s * 9.449, s * 10.069, s * 9.276, s * 9.994, s * 9.127);
    phonePath.cubicTo(s * 9.919, s * 8.978, s * 9.325, s * 7.515, s * 9.078, s * 6.920);
    phonePath.cubicTo(s * 8.836, s * 6.341, s * 8.591, s * 6.420, s * 8.409, s * 6.410);
    phonePath.cubicTo(s * 8.236, s * 6.402, s * 8.038, s * 6.400, s * 7.839, s * 6.400);
    phonePath.cubicTo(s * 7.641, s * 6.400, s * 7.319, s * 6.474, s * 7.047, s * 6.772);
    phonePath.cubicTo(s * 6.775, s * 7.069, s * 6.007, s * 7.788, s * 6.007, s * 9.251);
    phonePath.cubicTo(s * 6.007, s * 10.713, s * 7.072, s * 12.126, s * 7.220, s * 12.325);
    phonePath.cubicTo(s * 7.369, s * 12.523, s * 9.316, s * 15.525, s * 12.297, s * 16.812);
    phonePath.cubicTo(s * 13.006, s * 17.118, s * 13.559, s * 17.301, s * 13.991, s * 17.437);
    phonePath.cubicTo(s * 14.703, s * 17.664, s * 15.351, s * 17.632, s * 15.862, s * 17.555);
    phonePath.cubicTo(s * 16.433, s * 17.470, s * 17.620, s * 16.836, s * 17.868, s * 16.142);
    phonePath.cubicTo(s * 18.116, s * 15.448, s * 18.116, s * 14.853, s * 18.041, s * 14.729);
    phonePath.cubicTo(s * 17.967, s * 14.605, s * 17.769, s * 14.531, s * 17.471, s * 14.382);
    phonePath.close();

    canvas.drawPath(phonePath, phonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
