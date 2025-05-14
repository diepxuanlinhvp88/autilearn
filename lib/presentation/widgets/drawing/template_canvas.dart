import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/imgur_service.dart';

class TemplateCanvas extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final String outlineImageUrl;
  final Function() onDrawingChanged;

  const TemplateCanvas({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.outlineImageUrl,
    required this.onDrawingChanged,
  }) : super(key: key);

  @override
  TemplateCanvasState createState() => TemplateCanvasState();
}

class TemplateCanvasState extends State<TemplateCanvas> {
  List<DrawingPoint?> points = [];
  bool isImageLoaded = false;
  final ImgurService _imgurService = ImgurService();
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (!isImageLoaded) return;

        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

        setState(() {
          points.add(
            DrawingPoint(
              offset: localPosition,
              paint: Paint()
                ..color = widget.selectedColor
                ..isAntiAlias = true
                ..strokeWidth = widget.strokeWidth
                ..strokeCap = StrokeCap.round,
            ),
          );
        });
        widget.onDrawingChanged();
      },
      onPanUpdate: (details) {
        if (!isImageLoaded) return;

        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

        setState(() {
          points.add(
            DrawingPoint(
              offset: localPosition,
              paint: Paint()
                ..color = widget.selectedColor
                ..isAntiAlias = true
                ..strokeWidth = widget.strokeWidth
                ..strokeCap = StrokeCap.round,
            ),
          );
        });
        widget.onDrawingChanged();
      },
      onPanEnd: (details) {
        setState(() {
          points.add(null);
        });
        widget.onDrawingChanged();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          key: _canvasKey,
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Hiển thị hình ảnh đường viền
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
                    // Đánh dấu hình ảnh đã tải xong
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

              // Canvas vẽ
              if (isImageLoaded)
                CustomPaint(
                  painter: DrawingPainter(points: points),
                  size: Size.infinite,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      points.clear();
    });
    widget.onDrawingChanged();
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
          PointMode.points,
          [points[i]!.offset],
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
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
