import 'package:flutter/material.dart';
import 'dart:ui';

class SimpleTemplateCanvas extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final String outlineImageUrl;
  final Function() onDrawingChanged;
  final bool isErasing; // Thêm trạng thái tẩy

  const SimpleTemplateCanvas({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.outlineImageUrl,
    required this.onDrawingChanged,
    this.isErasing = false, // Mặc định là không tẩy
  }) : super(key: key);

  @override
  SimpleTemplateCanvasState createState() => SimpleTemplateCanvasState();
}

class SimpleTemplateCanvasState extends State<SimpleTemplateCanvas> with TickerProviderStateMixin {
  final List<DrawingPoint?> points = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _controller.addListener(() {
      setState(() {
        // Force rebuild
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building SimpleTemplateCanvas with ${points.length} points');
    return Stack(
      children: [
        // Nền trắng
        Container(
          color: Colors.white,
        ),

        // Hình ảnh mẫu với độ trong suốt
        Opacity(
          opacity: 0.3,
          child: Image.network(
            widget.outlineImageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              );
            },
          ),
        ),

        // Canvas vẽ
        RepaintBoundary(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: _DrawingPainter(
                points: points,
                color: widget.selectedColor,
                strokeWidth: widget.strokeWidth,
              ),
              size: Size.infinite,
              isComplex: true, // Hint that this is a complex painting
              willChange: true, // Hint that this will change frequently
            ),
          ),
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    print('PanStart: $localPosition, color: ${widget.selectedColor}, isErasing: ${widget.isErasing}, points: ${points.length}');

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

    // Trigger animation to force redraw
    _controller.reset();
    _controller.forward();

    widget.onDrawingChanged();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    print('PanUpdate: $localPosition, color: ${widget.selectedColor}, isErasing: ${widget.isErasing}, points: ${points.length}');

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

    // Trigger animation to force redraw
    if (!_controller.isAnimating) {
      _controller.reset();
      _controller.forward();
    }

    widget.onDrawingChanged();
  }

  void _onPanEnd(DragEndDetails details) {
    print('PanEnd: points: ${points.length}');

    setState(() {
      points.add(null); // Thêm null để đánh dấu kết thúc đường vẽ
    });

    // Trigger animation to force redraw
    _controller.reset();
    _controller.forward();

    widget.onDrawingChanged();
  }

  void clear() {
    setState(() {
      points.clear();
    });

    // Trigger animation to force redraw
    _controller.reset();
    _controller.forward();

    widget.onDrawingChanged();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    print('Drawing ${points.length} points');

    // Vẽ nền trắng
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withOpacity(0.01), // Transparent white to force redraw
    );

    // Vẽ các đường
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Vẽ đường giữa các điểm
        print('Drawing line from ${points[i]!.offset} to ${points[i + 1]!.offset} with color ${points[i]!.paint.color}, isEraser: ${points[i]!.isEraser}');
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        // Vẽ điểm đơn
        print('Drawing point at ${points[i]!.offset} with color ${points[i]!.paint.color}, isEraser: ${points[i]!.isEraser}');
        canvas.drawCircle(
          points[i]!.offset,
          points[i]!.paint.strokeWidth / 2,
          points[i]!.paint,
        );
      }
    }

    // Vẽ điểm cuối cùng nếu có
    if (points.isNotEmpty && points.last != null) {
      print('Drawing last point at ${points.last!.offset} with color ${points.last!.paint.color}, isEraser: ${points.last!.isEraser}');
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
