import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';

class BadgeImageGenerator {
  static Future<ui.Image> generateBadgeImage({
    required String type,
    required Color primaryColor,
    required Color secondaryColor,
    required double size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, size, size);

    // Draw badge background
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Draw circular badge
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw badge border
    final borderPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 20;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - size / 40, borderPaint);

    // Draw badge details based on type
    switch (type.toLowerCase()) {
      case 'bronze':
        _drawBronzeBadge(canvas, size, secondaryColor);
        break;
      case 'silver':
        _drawSilverBadge(canvas, size, secondaryColor);
        break;
      case 'gold':
        _drawGoldBadge(canvas, size, secondaryColor);
        break;
      case 'platinum':
        _drawPlatinumBadge(canvas, size, secondaryColor);
        break;
      case 'diamond':
        _drawDiamondBadge(canvas, size, secondaryColor);
        break;
    }

    final picture = recorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  static void _drawBronzeBadge(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 30;

    // Draw star shape
    final path = Path();
    final center = Offset(size / 2, size / 2);
    final radius = size / 3;

    for (var i = 0; i < 5; i++) {
      final angle = i * 4 * pi / 5 - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  static void _drawSilverBadge(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 30;

    // Draw pentagon
    final path = Path();
    final center = Offset(size / 2, size / 2);
    final radius = size / 3;

    for (var i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5 - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  static void _drawGoldBadge(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 30;

    // Draw sun rays
    final center = Offset(size / 2, size / 2);
    final radius = size / 3;
    const rayCount = 12;

    for (var i = 0; i < rayCount; i++) {
      final angle = i * 2 * pi / rayCount;
      final start = Offset(
        center.dx + radius * 0.6 * cos(angle),
        center.dy + radius * 0.6 * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw center circle
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  static void _drawPlatinumBadge(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 30;

    // Draw octagon
    final path = Path();
    final center = Offset(size / 2, size / 2);
    final radius = size / 3;
    const sides = 8;

    for (var i = 0; i < sides; i++) {
      final angle = i * 2 * pi / sides - pi / sides;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw inner design
    canvas.drawCircle(center, radius * 0.7, paint);
  }

  static void _drawDiamondBadge(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 30;

    // Draw diamond shape
    final path = Path();
    final center = Offset(size / 2, size / 2);
    final radius = size / 3;

    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy);
    path.close();

    canvas.drawPath(path, paint);

    // Draw inner lines
    canvas.drawLine(
      Offset(center.dx - radius * 0.7, center.dy),
      Offset(center.dx + radius * 0.7, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.7),
      Offset(center.dx, center.dy + radius * 0.7),
      paint,
    );
  }
}