import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../core/services/drawing_service.dart';
import '../../../data/models/drawing_model.dart';
import '../../../data/models/drawing_template_model.dart';
import '../../../main.dart';

class DrawingHomePage extends StatefulWidget {
  const DrawingHomePage({Key? key}) : super(key: key);

  @override
  State<DrawingHomePage> createState() => _DrawingHomePageState();
}

class _DrawingHomePageState extends State<DrawingHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DrawingService _drawingService = DrawingService();

  List<DrawingModel> _userDrawings = [];
  List<DrawingTemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.uid;

      // Tải danh sách bài vẽ của người dùng
      final drawingsResult = await _drawingService.getUserDrawings(userId);
      drawingsResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${failure.message}')),
          );
        },
        (drawings) {
          setState(() {
            _userDrawings = drawings;
          });
        },
      );

      // Tải danh sách mẫu vẽ
      final templatesResult = await _drawingService.getDrawingTemplates(isPublished: true);
      templatesResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${failure.message}')),
          );
        },
        (templates) {
          setState(() {
            _templates = templates;
          });
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học vẽ'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.testDrawing);
            },
            tooltip: 'Kiểm tra vẽ',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Vẽ tự do'),
            Tab(text: 'Tô màu theo mẫu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab vẽ tự do
          _buildFreeDrawingTab(),

          // Tab tô màu theo mẫu
          _buildTemplateDrawingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _createNewFreeDrawing();
          } else {
            // Không cần tạo mới cho tô màu theo mẫu
            // Người dùng sẽ chọn từ danh sách mẫu có sẵn
          }
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFreeDrawingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userDrawings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.brush, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có bài vẽ nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút + để tạo bài vẽ mới',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewFreeDrawing,
              icon: const Icon(Icons.add),
              label: const Text('Tạo bài vẽ mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userDrawings.length,
      itemBuilder: (context, index) {
        final drawing = _userDrawings[index];
        if (drawing.type == AppConstants.freeDrawing) {
          return _buildDrawingCard(drawing);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTemplateDrawingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_templates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có mẫu vẽ nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Vui lòng thử lại sau',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildDrawingCard(DrawingModel drawing) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.freeDrawing,
            arguments: {'drawingId': drawing.id},
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh bài vẽ
            if (drawing.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  drawing.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(
                  child: Icon(Icons.brush, size: 48, color: Colors.grey),
                ),
              ),

            // Thông tin bài vẽ
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drawing.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drawing.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        drawing.isCompleted ? Icons.check_circle : Icons.pending,
                        color: drawing.isCompleted ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        drawing.isCompleted ? 'Đã hoàn thành' : 'Đang thực hiện',
                        style: TextStyle(
                          fontSize: 12,
                          color: drawing.isCompleted ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(DrawingTemplateModel template) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _startTemplateDrawing(template);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh mẫu
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                template.outlineImageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Thông tin mẫu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        template.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                        template.difficulty,
                        (index) => const Icon(Icons.star, size: 14, color: Colors.amber),
                      ),
                      ...List.generate(
                        5 - template.difficulty,
                        (index) => const Icon(Icons.star_border, size: 14, color: Colors.amber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewFreeDrawing() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bài vẽ mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Nhập tiêu đề bài vẽ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả bài vẽ',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
                );
                return;
              }

              Navigator.of(context).pop();

              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                final userId = authState.user.uid;

                // Tạo bài vẽ mới
                final result = await _drawingService.createDrawing(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  type: AppConstants.freeDrawing,
                  creatorId: userId,
                );

                result.fold(
                  (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${failure.message}')),
                    );
                  },
                  (drawing) {
                    // Chuyển đến màn hình vẽ
                    Navigator.of(context).pushNamed(
                      AppRouter.freeDrawing,
                      arguments: {'drawingId': drawing.id},
                    ).then((_) => _loadData());
                  },
                );
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _startTemplateDrawing(DrawingTemplateModel template) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.uid;

      // Tạo bài vẽ mới từ mẫu
      final result = await _drawingService.createDrawing(
        title: 'Tô màu: ${template.title}',
        description: template.description,
        type: AppConstants.templateDrawing,
        creatorId: userId,
        templateId: template.id,
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${failure.message}')),
          );
        },
        (drawing) {
          // Chuyển đến màn hình tô màu
          Navigator.of(context).pushNamed(
            AppRouter.templateDrawing,
            arguments: {
              'drawingId': drawing.id,
              'templateId': template.id,
            },
          ).then((_) => _loadData());
        },
      );
    }
  }
}
