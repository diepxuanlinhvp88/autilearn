import 'dart:ui';
import 'package:flutter/material.dart';

class SimpleDrawingCanvas extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final Function() onDrawingChanged;

  const SimpleDrawingCanvas({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onDrawingChanged,
  }) : super(key: key);

  @override
  SimpleDrawingCanvasState createState() => SimpleDrawingCanvasState();
}

class SimpleDrawingCanvasState extends State<SimpleDrawingCanvas> {
  final List<DrawingLine> lines = <DrawingLine>[];
  DrawingLine? line;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: SimplePainter(
            lines: lines,
            currentLine: line,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      line = DrawingLine(
        points: [localPosition],
        color: widget.selectedColor,
        width: widget.strokeWidth,
      );
    });
    widget.onDrawingChanged();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (line == null) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      line!.points.add(localPosition);
    });
    widget.onDrawingChanged();
  }

  void _onPanEnd(DragEndDetails details) {
    if (line == null) return;
    
    setState(() {
      lines.add(line!);
      line = null;
    });
    widget.onDrawingChanged();
  }

  void clear() {
    setState(() {
      lines.clear();
      line = null;
    });
    widget.onDrawingChanged();
  }
}

class SimplePainter extends CustomPainter {
  final List<DrawingLine> lines;
  final DrawingLine? currentLine;

  SimplePainter({required this.lines, this.currentLine});

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ các đường đã hoàn thành
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      _drawLine(canvas, line.points, paint);
    }

    // Vẽ đường đang vẽ
    if (currentLine != null) {
      final paint = Paint()
        ..color = currentLine!.color
        ..strokeWidth = currentLine!.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      _drawLine(canvas, currentLine!.points, paint);
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      // Nếu chỉ có 1 điểm, vẽ một điểm
      if (points.isNotEmpty) {
        canvas.drawPoints(PointMode.points, [points[0]], paint);
      }
      return;
    }

    // Vẽ đường cong qua các điểm
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SimplePainter oldDelegate) {
    return oldDelegate.lines != lines || oldDelegate.currentLine != currentLine;
  }
}

class DrawingLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawingLine({
    required this.points,
    required this.color,
    required this.width,
  });
}
