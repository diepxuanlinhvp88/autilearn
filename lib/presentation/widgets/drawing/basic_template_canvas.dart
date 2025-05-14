import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/imgur_service.dart';

class BasicTemplateCanvas extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final String outlineImageUrl;
  final Function() onDrawingChanged;

  const BasicTemplateCanvas({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.outlineImageUrl,
    required this.onDrawingChanged,
  }) : super(key: key);

  @override
  BasicTemplateCanvasState createState() => BasicTemplateCanvasState();
}

class BasicTemplateCanvasState extends State<BasicTemplateCanvas> {
  final List<DrawingPoint?> points = [];
  bool isImageLoaded = false;
  final ImgurService _imgurService = ImgurService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image (template)
            Positioned.fill(
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
                  // Mark image as loaded
                  if (!isImageLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        isImageLoaded = true;
                      });
                    });
                  }
                  return Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
            
            // Drawing canvas
            if (isImageLoaded)
              CustomPaint(
                painter: _DrawingPainter(
                  points: points,
                  color: widget.selectedColor,
                  strokeWidth: widget.strokeWidth,
                ),
                size: Size.infinite,
              ),
          ],
        ),
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
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Draw line between points
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        // Draw point
        canvas.drawPoints(
          PointMode.points,
          [points[i]!.offset],
          points[i]!.paint,
        );
      }
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
