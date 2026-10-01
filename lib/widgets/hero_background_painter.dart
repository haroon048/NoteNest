import 'package:flutter/material.dart';

class HeroBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint paint = Paint()
      ..shader =
          const LinearGradient(
            colors: [
              Color(0xFF1E1B4B), // Dark Navy Deep
              Color(0xFF311B92), // Purple Glow
              Color(0xFF831843), // Sunset Crimson
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect) // .createShader(rect) add kar diya hai
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.lineTo(0, size.height * 0.7);

    // Smooth Curved Wave Graphics
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
