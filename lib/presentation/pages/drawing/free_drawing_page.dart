import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../core/services/drawing_service.dart';
import '../../../data/models/drawing_model.dart';
import '../../../presentation/widgets/drawing/basic_drawing_canvas.dart';
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
  final GlobalKey<BasicDrawingCanvasState> _canvasKey = GlobalKey<BasicDrawingCanvasState>();

  DrawingModel? _drawing;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;
  bool _isErasing = false; // Thêm trạng thái tẩy

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin bài vẽ')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final userId = authState.user.uid;

        print('FreeDrawingPage: Saving drawing with ID: ${widget.drawingId}');
        print('FreeDrawingPage: Canvas key valid: ${_canvasKey.currentContext != null}');

        // Đảm bảo RepaintBoundary đã được render
        await Future.delayed(const Duration(milliseconds: 500));

        final result = await _drawingService.saveDrawing(
          key: _canvasKey,
          drawingId: widget.drawingId!,
          userId: userId,
        );

        result.fold(
          (failure) {
            print('FreeDrawingPage: Error saving drawing: ${failure.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${failure.message}')),
            );
            setState(() {
              _isSaving = false;
            });
          },
          (imageUrl) {
            print('FreeDrawingPage: Drawing saved successfully. URL: $imageUrl');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn chưa đăng nhập')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      print('FreeDrawingPage: Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi không xác định: $e')),
      );
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
                      border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
                    ),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BasicDrawingCanvas(
                          selectedColor: _selectedColor,
                          strokeWidth: _strokeWidth,
                          isErasing: _isErasing, // Truyền trạng thái tẩy
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
                      // Bảng màu và công cụ
                      Row(
                        children: [
                          // Bảng màu
                          Expanded(
                            child: ColorPalette(
                              selectedColor: _selectedColor,
                              onColorSelected: (color) {
                                setState(() {
                                  _selectedColor = color;
                                  _isErasing = false; // Tắt chế độ tẩy khi chọn màu
                                });
                              },
                            ),
                          ),

                          // Nút tẩy
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isErasing = !_isErasing; // Bật/tắt chế độ tẩy
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isErasing ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isErasing ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_fix_high,
                                color: _isErasing ? Colors.blue : Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
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
                              if (_canvasKey.currentState != null && _canvasKey.currentWidget is BasicDrawingCanvas) {
                                final canvasState = (_canvasKey.currentState as BasicDrawingCanvasState);
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
