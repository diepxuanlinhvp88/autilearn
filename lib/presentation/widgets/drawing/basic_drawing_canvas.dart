import 'dart:ui';
import 'package:flutter/material.dart';

class BasicDrawingCanvas extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final Function() onDrawingChanged;
  final bool isErasing; // Thêm trạng thái tẩy

  const BasicDrawingCanvas({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onDrawingChanged,
    this.isErasing = false, // Mặc định là không tẩy
  }) : super(key: key);

  @override
  BasicDrawingCanvasState createState() => BasicDrawingCanvasState();
}

class BasicDrawingCanvasState extends State<BasicDrawingCanvas> {
  final List<DrawingPoint?> points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _DrawingPainter(
            points: points,
            color: widget.selectedColor,
            strokeWidth: widget.strokeWidth,
          ),
          size: Size.infinite,
          isComplex: true,
          willChange: true,
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      points.add(DrawingPoint(
        offset: localPosition,
        paint: Paint()
          ..color = widget.isErasing ? Colors.white : widget.selectedColor
          ..strokeWidth = widget.strokeWidth
          ..strokeCap = StrokeCap.round
          ..blendMode = widget.isErasing ? BlendMode.clear : BlendMode.srcOver,
        isEraser: widget.isErasing,
      ));
    });
    widget.onDrawingChanged();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      points.add(DrawingPoint(
        offset: localPosition,
        paint: Paint()
          ..color = widget.isErasing ? Colors.white : widget.selectedColor
          ..strokeWidth = widget.strokeWidth
          ..strokeCap = StrokeCap.round
          ..blendMode = widget.isErasing ? BlendMode.clear : BlendMode.srcOver,
        isEraser: widget.isErasing,
      ));
    });
    widget.onDrawingChanged();
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      points.add(null); // Add null to indicate end of a line
    });
    widget.onDrawingChanged();
  }

  void clear() {
    setState(() {
      points.clear();
    });
    widget.onDrawingChanged();
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  final Color color;
  final double strokeWidth;

  _DrawingPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền trắng
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Vẽ các đường
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Vẽ đường giữa các điểm
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        // Vẽ điểm đơn
        canvas.drawCircle(
          points[i]!.offset,
          points[i]!.paint.strokeWidth / 2,
          points[i]!.paint,
        );
      }
    }

    // Vẽ điểm cuối cùng nếu có
    if (points.isNotEmpty && points.last != null) {
      canvas.drawCircle(
        points.last!.offset,
        points.last!.paint.strokeWidth / 2,
        points.last!.paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) {
    // Always repaint to ensure drawing is visible
    return true;
  }
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final bool isEraser; // Thêm trạng thái tẩy cho điểm vẽ

  DrawingPoint({
    required this.offset,
    required this.paint,
    this.isEraser = false, // Mặc định là không tẩy
  });
}
