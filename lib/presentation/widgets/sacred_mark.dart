import 'package:flutter/material.dart';

class SacredMark extends StatelessWidget {
  const SacredMark({
    this.size = 36,
    this.color = const Color(0xFFB9794D),
    this.strokeWidth = 1.25,
    super.key,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SacredMarkPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _SacredMarkPainter extends CustomPainter {
  const _SacredMarkPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - strokeWidth;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, linePaint);
    canvas.drawLine(
      Offset(center.dx, size.height * .20),
      Offset(center.dx, size.height * .80),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * .28, center.dy),
      Offset(size.width * .72, center.dy),
      linePaint,
    );
    canvas.drawCircle(center, size.shortestSide * .08, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SacredMarkPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
