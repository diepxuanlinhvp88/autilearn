import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../core/services/drawing_service.dart';
import '../../../data/models/drawing_model.dart';
import '../../../presentation/widgets/common/confetti_animation.dart';

class DrawingResultPage extends StatefulWidget {
  final int score;
  final String drawingId;
  final String drawingType;

  const DrawingResultPage({
    Key? key,
    required this.score,
    required this.drawingId,
    required this.drawingType,
  }) : super(key: key);

  @override
  State<DrawingResultPage> createState() => _DrawingResultPageState();
}

class _DrawingResultPageState extends State<DrawingResultPage> with SingleTickerProviderStateMixin {
  final DrawingService _drawingService = DrawingService();
  
  late AnimationController _controller;
  DrawingModel? _drawing;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
    
    _loadDrawing();
  }

  Future<void> _loadDrawing() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _drawingService.getDrawingById(widget.drawingId);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading || _drawing == null
          ? const Center(child: CircularProgressIndicator())
          : ConfettiAnimation(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Biểu tượng thành công
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _controller,
                          curve: Curves.elasticOut,
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 64,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Tiêu đề
                      Text(
                        'Tuyệt vời!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Thông báo
                      Text(
                        widget.drawingType == AppConstants.freeDrawing
                            ? 'Bạn đã hoàn thành bài vẽ tự do'
                            : 'Bạn đã hoàn thành bài tô màu',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Hiển thị hình ảnh đã vẽ
                      if (_drawing?.imageUrl != null)
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _drawing!.imageUrl!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Các nút điều hướng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRouter.drawingHome,
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('Trang chủ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          ElevatedButton.icon(
                            onPressed: () {
                              if (widget.drawingType == AppConstants.freeDrawing) {
                                Navigator.of(context).pushReplacementNamed(
                                  AppRouter.freeDrawing,
                                  arguments: {'drawingId': widget.drawingId},
                                );
                              } else {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRouter.drawingHome,
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.brush),
                            label: Text(
                              widget.drawingType == AppConstants.freeDrawing
                                  ? 'Vẽ lại'
                                  : 'Vẽ tiếp',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
