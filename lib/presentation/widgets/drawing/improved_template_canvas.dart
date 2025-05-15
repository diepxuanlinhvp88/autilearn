import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/imgur_service.dart';

class ImprovedTemplateCanvas extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final String outlineImageUrl;
  final Function() onDrawingChanged;

  const ImprovedTemplateCanvas({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.outlineImageUrl,
    required this.onDrawingChanged,
  }) : super(key: key);

  @override
  ImprovedTemplateCanvasState createState() => ImprovedTemplateCanvasState();
}

class ImprovedTemplateCanvasState extends State<ImprovedTemplateCanvas> {
  final List<DrawingPoint?> points = [];
  bool isImageLoaded = false;
  final ImgurService _imgurService = ImgurService();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Canvas vẽ
          GestureDetector(
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
            ),
          ),
          
          // Hình ảnh mẫu với độ trong suốt
          Positioned.fill(
            child: IgnorePointer(
              child: CachedNetworkImage(
                imageUrl: _imgurService.getDirectImageUrl(widget.outlineImageUrl),
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) {
                  print('Error loading image: $error, URL: $url');
                  return const Center(
                    child: Icon(Icons.error),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  // Đánh dấu hình ảnh đã tải xong
                  if (!isImageLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        isImageLoaded = true;
                      });
                    });
                  }
                  return Opacity(
                    opacity: 0.3, // Độ trong suốt cao hơn để thấy rõ nét vẽ
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (!isImageLoaded) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      points.add(DrawingPoint(
        offset: localPosition,
        paint: Paint()
          ..color = widget.selectedColor
          ..strokeWidth = widget.strokeWidth
          ..strokeCap = StrokeCap.round,
      ));
    });
    widget.onDrawingChanged();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!isImageLoaded) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      points.add(DrawingPoint(
        offset: localPosition,
        paint: Paint()
          ..color = widget.selectedColor
          ..strokeWidth = widget.strokeWidth
          ..strokeCap = StrokeCap.round,
      ));
    });
    widget.onDrawingChanged();
  }

  void _onPanEnd(DragEndDetails details) {
    if (!isImageLoaded) return;
    
    setState(() {
      points.add(null); // Thêm null để đánh dấu kết thúc đường vẽ
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
    
    // Vẽ các nét vẽ
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
        canvas.drawPoints(
          PointMode.points,
          [points[i]!.offset],
          points[i]!.paint,
        );
      }
    }
    
    // Vẽ điểm cuối cùng nếu có
    if (points.isNotEmpty && points.last != null) {
      canvas.drawPoints(
        PointMode.points,
        [points.last!.offset],
        points.last!.paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({
    required this.offset,
    required this.paint,
  });
}
