import 'package:flutter/material.dart';

class TornPaperClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;

  TornPaperClipper({this.toothWidth = 12, this.toothHeight = 8});

  Path createPath(Size size) {
    final path = Path()..moveTo(0, toothHeight);

    double x = 0;
    bool peak = true;

    while (x < size.width) {
      x = (x + toothWidth).clamp(0.0, size.width);

      path.lineTo(x, peak ? 0 : toothHeight);
      peak = !peak;
    }

    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  Path getClip(Size size) => createPath(size);

  @override
  bool shouldReclip(covariant TornPaperClipper oldClipper) {
    return oldClipper.toothWidth != toothWidth ||
        oldClipper.toothHeight != toothHeight;
  }
}

class TornPaperBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double toothWidth;
  final double toothHeight;

  TornPaperBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.toothWidth = 12,
    this.toothHeight = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = TornPaperClipper(
      toothWidth: toothWidth,
      toothHeight: toothHeight,
    );

    final path = clipper.createPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TornPaperBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.toothWidth != toothWidth ||
        oldDelegate.toothHeight != toothHeight;
  }
}
