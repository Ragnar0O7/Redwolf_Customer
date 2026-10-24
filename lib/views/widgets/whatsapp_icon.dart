import 'package:flutter/material.dart';

/// Pixel-perfect WhatsApp brand icon widget.
/// 
/// If [color] is null, displays the authentic WhatsApp green badge with white handset.
/// If [color] is specified, tints the icon silhouette using the provided color.
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
    return Image.asset(
      'img/whatsapp.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.chat_bubble_rounded,
          size: size,
          color: color ?? const Color(0xFF25D366),
        );
      },
    );
  }
}
