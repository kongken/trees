import 'dart:math';
import 'package:flutter/material.dart';

class TreePainter extends CustomPainter {
  final double progress;
  final Color trunkColor;
  final Color leafColor;
  final Color fruitColor;
  final bool isDormant;

  TreePainter({
    required this.progress,
    this.trunkColor = const Color(0xFF795548),
    this.leafColor = const Color(0xFF4CAF50),
    this.fruitColor = const Color(0xFFFF8A65),
    this.isDormant = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.88;

    _drawGround(canvas, size, groundY);

    if (progress < 0.01) {
      _drawSeed(canvas, centerX, groundY, size);
    } else if (progress < 0.25) {
      _drawSeedling(canvas, centerX, groundY, size, progress / 0.25);
    } else if (progress < 0.50) {
      _drawSmallTree(
          canvas, centerX, groundY, size, (progress - 0.25) / 0.25);
    } else if (progress < 0.75) {
      _drawMediumTree(
          canvas, centerX, groundY, size, (progress - 0.50) / 0.25);
    } else {
      _drawFullTree(canvas, centerX, groundY, size, (progress - 0.75) / 0.25);
    }
  }

  void _drawGround(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..color = const Color(0xFF8D6E63).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, groundY + 8);
    path.quadraticBezierTo(size.width / 2, groundY - 2, size.width, groundY + 8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, groundPaint);
  }

  void _drawSeed(Canvas canvas, double cx, double groundY, Size size) {
    final seedPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, groundY - 4),
          width: size.width * 0.08,
          height: size.width * 0.06),
      seedPaint,
    );
  }

  void _drawSeedling(
      Canvas canvas, double cx, double groundY, Size size, double t) {
    final trunkHeight = size.height * 0.15 * t;
    final trunkPaint = Paint()
      ..color = isDormant ? Colors.grey : const Color(0xFF6D4C41)
      ..strokeWidth = max(2, size.width * 0.02)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, groundY),
      Offset(cx, groundY - trunkHeight),
      trunkPaint,
    );

    if (t > 0.3) {
      final leafPaint = Paint()
        ..color = isDormant
            ? Colors.grey.withValues(alpha: 0.5)
            : leafColor.withValues(alpha: 0.7 + 0.3 * t)
        ..style = PaintingStyle.fill;

      final leafSize = size.width * 0.06 * t;
      _drawLeaf(canvas, cx - leafSize * 0.5, groundY - trunkHeight + 2,
          leafSize, -0.5, leafPaint);

      if (t > 0.6) {
        _drawLeaf(canvas, cx + leafSize * 0.3, groundY - trunkHeight + 6,
            leafSize * 0.8, 0.5, leafPaint);
      }
    }
  }

  void _drawSmallTree(
      Canvas canvas, double cx, double groundY, Size size, double t) {
    final trunkHeight = size.height * (0.15 + 0.15 * t);
    final trunkWidth = max(3.0, size.width * 0.03);

    final trunkPaint = Paint()
      ..color = isDormant ? Colors.grey : trunkColor
      ..strokeWidth = trunkWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, groundY),
      Offset(cx, groundY - trunkHeight),
      trunkPaint,
    );

    final branchLen = size.width * 0.08 * (0.5 + 0.5 * t);
    _drawBranch(
        canvas, cx, groundY - trunkHeight * 0.6, branchLen, -0.7, trunkPaint);
    if (t > 0.4) {
      _drawBranch(canvas, cx, groundY - trunkHeight * 0.75, branchLen * 0.8,
          0.6, trunkPaint);
    }

    final leafPaint = Paint()
      ..color = isDormant
          ? const Color(0xFFBDBDBD)
          : leafColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final canopyRadius = size.width * 0.12 * (0.6 + 0.4 * t);
    canvas.drawCircle(
      Offset(cx, groundY - trunkHeight - canopyRadius * 0.3),
      canopyRadius,
      leafPaint,
    );

    if (t > 0.3) {
      canvas.drawCircle(
        Offset(cx - canopyRadius * 0.6, groundY - trunkHeight + canopyRadius * 0.2),
        canopyRadius * 0.7,
        leafPaint,
      );
    }
    if (t > 0.6) {
      canvas.drawCircle(
        Offset(cx + canopyRadius * 0.5, groundY - trunkHeight + canopyRadius * 0.3),
        canopyRadius * 0.6,
        leafPaint,
      );
    }
  }

  void _drawMediumTree(
      Canvas canvas, double cx, double groundY, Size size, double t) {
    final trunkHeight = size.height * (0.30 + 0.15 * t);
    final trunkWidth = max(4.0, size.width * 0.04);

    final trunkPaint = Paint()
      ..color = isDormant ? Colors.grey : trunkColor
      ..strokeWidth = trunkWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, groundY),
      Offset(cx, groundY - trunkHeight),
      trunkPaint,
    );

    final branchPaint = Paint()
      ..color = isDormant ? Colors.grey : trunkColor
      ..strokeWidth = trunkWidth * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branchLen = size.width * 0.12;
    _drawBranch(
        canvas, cx, groundY - trunkHeight * 0.45, branchLen, -0.6, branchPaint);
    _drawBranch(
        canvas, cx, groundY - trunkHeight * 0.6, branchLen * 0.9, 0.5, branchPaint);
    _drawBranch(
        canvas, cx, groundY - trunkHeight * 0.75, branchLen * 0.7, -0.4, branchPaint);

    final leafPaint = Paint()
      ..color = isDormant
          ? const Color(0xFFBDBDBD)
          : leafColor
      ..style = PaintingStyle.fill;

    final canopyR = size.width * 0.16 * (0.7 + 0.3 * t);

    canvas.drawCircle(
      Offset(cx, groundY - trunkHeight - canopyR * 0.2),
      canopyR,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(cx - canopyR * 0.7, groundY - trunkHeight + canopyR * 0.3),
      canopyR * 0.75,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(cx + canopyR * 0.6, groundY - trunkHeight + canopyR * 0.2),
      canopyR * 0.7,
      leafPaint,
    );

    final darkLeafPaint = Paint()
      ..color = isDormant
          ? const Color(0xFFA0A0A0)
          : leafColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(cx - canopyR * 0.3, groundY - trunkHeight - canopyR * 0.5),
      canopyR * 0.5,
      darkLeafPaint,
    );
  }

  void _drawFullTree(
      Canvas canvas, double cx, double groundY, Size size, double t) {
    final trunkHeight = size.height * 0.50;
    final trunkWidth = max(5.0, size.width * 0.05);

    final trunkPaint = Paint()
      ..color = isDormant ? Colors.grey : trunkColor
      ..strokeWidth = trunkWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, groundY),
      Offset(cx, groundY - trunkHeight),
      trunkPaint,
    );

    final branchPaint = Paint()
      ..color = isDormant ? Colors.grey : trunkColor
      ..strokeWidth = trunkWidth * 0.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawBranch(canvas, cx, groundY - trunkHeight * 0.4,
        size.width * 0.14, -0.6, branchPaint);
    _drawBranch(canvas, cx, groundY - trunkHeight * 0.55,
        size.width * 0.12, 0.5, branchPaint);
    _drawBranch(canvas, cx, groundY - trunkHeight * 0.7,
        size.width * 0.10, -0.4, branchPaint);
    _drawBranch(canvas, cx, groundY - trunkHeight * 0.85,
        size.width * 0.08, 0.3, branchPaint);

    final leafPaint = Paint()
      ..color = isDormant
          ? const Color(0xFFBDBDBD)
          : leafColor
      ..style = PaintingStyle.fill;

    final canopyR = size.width * 0.20;

    canvas.drawCircle(
      Offset(cx, groundY - trunkHeight - canopyR * 0.1),
      canopyR,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(cx - canopyR * 0.8, groundY - trunkHeight + canopyR * 0.4),
      canopyR * 0.8,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(cx + canopyR * 0.7, groundY - trunkHeight + canopyR * 0.3),
      canopyR * 0.75,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(cx - canopyR * 0.3, groundY - trunkHeight - canopyR * 0.6),
      canopyR * 0.6,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(cx + canopyR * 0.4, groundY - trunkHeight - canopyR * 0.5),
      canopyR * 0.55,
      leafPaint,
    );

    if (t > 0.2 && !isDormant) {
      _drawFruits(canvas, cx, groundY - trunkHeight, canopyR, t);
    }

    if (progress >= 1.0 && !isDormant) {
      _drawGlow(canvas, cx, groundY - trunkHeight - canopyR * 0.2,
          canopyR * 1.5);
    }
  }

  void _drawFruits(Canvas canvas, double cx, double topY, double r, double t) {
    final fruitPaint = Paint()
      ..color = fruitColor
      ..style = PaintingStyle.fill;

    final random = Random(42);
    final fruitCount = (t * 8).ceil();

    for (int i = 0; i < fruitCount; i++) {
      final angle = random.nextDouble() * pi * 2;
      final dist = r * 0.3 + random.nextDouble() * r * 0.5;
      final fx = cx + cos(angle) * dist;
      final fy = topY + sin(angle) * dist * 0.6;
      final fruitR = r * 0.06 + random.nextDouble() * r * 0.04;
      canvas.drawCircle(Offset(fx, fy), fruitR, fruitPaint);
    }
  }

  void _drawGlow(Canvas canvas, double cx, double cy, double radius) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD54F).withValues(alpha: 0.3),
          const Color(0xFFFFD54F).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      );
    canvas.drawCircle(Offset(cx, cy), radius, glowPaint);
  }

  void _drawBranch(Canvas canvas, double startX, double startY,
      double length, double angle, Paint paint) {
    final endX = startX + cos(angle) * length;
    final endY = startY - sin(angle.abs()) * length * 0.5;
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  void _drawLeaf(Canvas canvas, double x, double y, double leafSize,
      double angle, Paint paint) {
    final path = Path();
    path.moveTo(x, y);
    path.quadraticBezierTo(
      x + cos(angle) * leafSize * 1.5,
      y - leafSize * 0.8,
      x + cos(angle) * leafSize * 2,
      y,
    );
    path.quadraticBezierTo(
      x + cos(angle) * leafSize * 1.5,
      y + leafSize * 0.3,
      x,
      y,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDormant != isDormant ||
        oldDelegate.leafColor != leafColor;
  }
}
