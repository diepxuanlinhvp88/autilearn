import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SimpleCanvas extends StatefulWidget {
  final Color color;
  final double strokeWidth;
  final Function() onDrawingChanged;

  const SimpleCanvas({
    Key? key,
    required this.color,
    required this.strokeWidth,
    required this.onDrawingChanged,
  }) : super(key: key);

  @override
  SimpleCanvasState createState() => SimpleCanvasState();
}

class SimpleCanvasState extends State<SimpleCanvas> {
  final List<Offset?> points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(renderBox.globalToLocal(details.globalPosition));
            widget.onDrawingChanged();
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(renderBox.globalToLocal(details.globalPosition));
            widget.onDrawingChanged();
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
            widget.onDrawingChanged();
          });
        },
        child: CustomPaint(
          painter: SimplePainter(
            points: points,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      points.clear();
      widget.onDrawingChanged();
    });
  }
}

class SimplePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  SimplePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền trắng để đảm bảo canvas rỗng
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Vẽ đường viền để thấy rõ khu vực vẽ
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Vẽ các nét vẽ
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Vẽ các điểm và đường
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Vẽ đường giữa các điểm
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        // Vẽ điểm đơn
        canvas.drawCircle(points[i]!, strokeWidth / 2, paint);
      }
    }

    // Vẽ điểm cuối cùng nếu có
    if (points.isNotEmpty && points.last != null) {
      canvas.drawCircle(points.last!, strokeWidth / 2, paint);
    }
  }

  @override
  bool shouldRepaint(SimplePainter oldDelegate) => true;
}
