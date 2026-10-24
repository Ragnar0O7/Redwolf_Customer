import 'package:flutter/material.dart';

/// Pure vector WhatsApp outline icon rendered via CustomPainter.
/// Accurately renders the official brand outline speech bubble with the telephone handset.
class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppIcon({
    super.key,
    this.size = 20.0,
    this.color = const Color(0xFFED1F24),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _WhatsAppOutlinePainter(color: color),
      ),
    );
  }
}

class _WhatsAppOutlinePainter extends CustomPainter {
  final Color color;

  _WhatsAppOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()..fillType = PathFillType.evenOdd;

    // Subpath 1: Outer speech bubble contour
    path.moveTo(s * 0.057, s * 24.000);
    path.lineTo(s * 1.744, s * 17.837);
    path.cubicTo(s * 0.703, s * 16.033, s * 0.156, s * 13.988, s * 0.157, s * 11.891);
    path.cubicTo(s * 0.160, s * 5.335, s * 5.495, s * 0.000, s * 12.050, s * 0.000);
    path.cubicTo(s * 15.231, s * 0.001, s * 18.217, s * 1.240, s * 20.463, s * 3.488);
    path.cubicTo(s * 22.708, s * 5.736, s * 23.944, s * 8.724, s * 23.943, s * 11.902);
    path.cubicTo(s * 23.940, s * 18.459, s * 18.605, s * 23.794, s * 12.050, s * 23.794);
    path.cubicTo(s * 10.060, s * 23.793, s * 8.099, s * 23.294, s * 6.362, s * 22.346);
    path.lineTo(s * 0.057, s * 24.000);
    path.close();

    // Subpath 2: Inner speech bubble cutout (creates outline stroke)
    path.moveTo(s * 6.654, s * 20.193);
    path.cubicTo(s * 8.330, s * 21.188, s * 9.930, s * 21.784, s * 12.046, s * 21.785);
    path.cubicTo(s * 17.494, s * 21.785, s * 21.932, s * 17.351, s * 21.935, s * 11.900);
    path.cubicTo(s * 21.937, s * 6.438, s * 17.520, s * 2.010, s * 12.054, s * 2.008);
    path.cubicTo(s * 6.602, s * 2.008, s * 2.167, s * 6.442, s * 2.165, s * 11.892);
    path.cubicTo(s * 2.164, s * 14.117, s * 2.816, s * 15.783, s * 3.911, s * 17.526);
    path.lineTo(s * 2.912, s * 21.174);
    path.lineTo(s * 6.654, s * 20.193);
    path.close();

    // Subpath 3: Phone handset inside bubble
    path.moveTo(s * 18.041, s * 14.729);
    path.cubicTo(s * 17.967, s * 14.605, s * 17.769, s * 14.531, s * 17.471, s * 14.382);
    path.cubicTo(s * 17.174, s * 14.233, s * 15.713, s * 13.514, s * 15.440, s * 13.415);
    path.cubicTo(s * 15.168, s * 13.316, s * 14.970, s * 13.266, s * 14.771, s * 13.564);
    path.cubicTo(s * 14.573, s * 13.861, s * 14.003, s * 14.531, s * 13.830, s * 14.729);
    path.cubicTo(s * 13.657, s * 14.927, s * 13.483, s * 14.952, s * 13.186, s * 14.803);
    path.cubicTo(s * 12.889, s * 14.654, s * 11.931, s * 14.341, s * 10.796, s * 13.328);
    path.cubicTo(s * 9.913, s * 12.540, s * 9.316, s * 11.567, s * 9.143, s * 11.269);
    path.cubicTo(s * 8.970, s * 10.972, s * 9.125, s * 10.811, s * 9.273, s * 10.663);
    path.cubicTo(s * 9.407, s * 10.530, s * 9.570, s * 10.316, s * 9.719, s * 10.142);
    path.cubicTo(s * 9.870, s * 9.970, s * 9.919, s * 9.846, s * 10.019, s * 9.647);
    path.cubicTo(s * 10.118, s * 9.449, s * 10.069, s * 9.275, s * 9.994, s * 9.126);
    path.cubicTo(s * 9.919, s * 8.978, s * 9.325, s * 7.515, s * 9.078, s * 6.920);
    path.cubicTo(s * 8.836, s * 6.341, s * 8.591, s * 6.419, s * 8.409, s * 6.410);
    path.lineTo(s * 7.839, s * 6.400);
    path.cubicTo(s * 7.641, s * 6.400, s * 7.319, s * 6.474, s * 7.047, s * 6.772);
    path.cubicTo(s * 7.196, s * 6.970, s * 9.142, s * 9.972, s * 12.123, s * 11.259);
    path.cubicTo(s * 12.832, s * 11.565, s * 13.386, s * 11.748, s * 13.817, s * 11.885);
    path.cubicTo(s * 14.529, s * 12.111, s * 15.177, s * 12.079, s * 15.689, s * 12.003);
    path.cubicTo(s * 16.260, s * 11.918, s * 17.447, s * 11.284, s * 17.695, s * 10.590);
    path.cubicTo(s * 17.943, s * 9.895, s * 17.943, s * 9.300, s * 17.868, s * 9.176);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WhatsAppOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
