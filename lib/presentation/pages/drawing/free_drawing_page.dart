import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../core/services/drawing_service.dart';
import '../../../data/models/drawing_model.dart';
import '../../../presentation/widgets/drawing/simple_canvas.dart';
import '../../../presentation/widgets/drawing/color_palette.dart';
import '../../../presentation/widgets/drawing/brush_size_selector.dart';

class FreeDrawingPage extends StatefulWidget {
  final String? drawingId;

  const FreeDrawingPage({
    Key? key,
    this.drawingId,
  }) : super(key: key);

  @override
  State<FreeDrawingPage> createState() => _FreeDrawingPageState();
}

class _FreeDrawingPageState extends State<FreeDrawingPage> {
  final DrawingService _drawingService = DrawingService();
  final GlobalKey _canvasKey = GlobalKey();

  DrawingModel? _drawing;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;

  @override
  void initState() {
    super.initState();
    _loadDrawing();
  }

  Future<void> _loadDrawing() async {
    if (widget.drawingId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _drawingService.getDrawingById(widget.drawingId!);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${failure.message}')),
        );
        setState(() {
          _isLoading = false;
        });
      },
      (drawing) {
        setState(() {
          _drawing = drawing;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _saveDrawing() async {
    if (widget.drawingId == null || _drawing == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.uid;

      final result = await _drawingService.saveDrawing(
        key: _canvasKey,
        drawingId: widget.drawingId!,
        userId: userId,
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${failure.message}')),
          );
          setState(() {
            _isSaving = false;
          });
        },
        (imageUrl) {
          setState(() {
            _isSaving = false;
            _hasChanges = false;
            _drawing = _drawing!.copyWith(
              imageUrl: imageUrl,
              isCompleted: true,
            );
          });

          // Hiển thị kết quả
          Navigator.of(context).pushReplacementNamed(
            AppRouter.drawingResult,
            arguments: {
              'score': 100,
              'drawingId': widget.drawingId,
              'drawingType': AppConstants.freeDrawing,
            },
          );
        },
      );
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_drawing?.title ?? 'Vẽ tự do'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveDrawing,
              tooltip: 'Lưu bài vẽ',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Canvas vẽ
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SimpleCanvas(
                          color: _selectedColor,
                          strokeWidth: _strokeWidth,
                          onDrawingChanged: () {
                            setState(() {
                              _hasChanges = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Công cụ vẽ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Bảng màu
                      ColorPalette(
                        selectedColor: _selectedColor,
                        onColorSelected: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Chọn kích thước bút
                      BrushSizeSelector(
                        selectedSize: _strokeWidth,
                        onSizeSelected: (size) {
                          setState(() {
                            _strokeWidth = size;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nút xóa và hoàn thành
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_canvasKey.currentState != null && _canvasKey.currentWidget is SimpleCanvas) {
                                final canvasState = (_canvasKey.currentState as SimpleCanvasState);
                                canvasState.clear();
                              }
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Xóa tất cả'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _hasChanges && !_isSaving ? _saveDrawing : null,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: const Text('Hoàn thành'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
