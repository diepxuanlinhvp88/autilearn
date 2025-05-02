import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/quiz_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';

class EditQuizPage extends StatefulWidget {
  final QuizModel quiz;

  const EditQuizPage({
    super.key,
    required this.quiz,
  });

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late String _selectedType;
  late String _selectedDifficulty;
  late String _category;
  late int _minAge;
  late int _maxAge;
  late bool _isPublished;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz.title);
    _descriptionController = TextEditingController(text: widget.quiz.description);
    _tagsController = TextEditingController(text: widget.quiz.tags.join(', '));
    _selectedType = widget.quiz.type;
    _selectedDifficulty = widget.quiz.difficulty;
    _category = widget.quiz.category ?? '';
    _minAge = widget.quiz.ageRangeMin ?? 3;
    _maxAge = widget.quiz.ageRangeMax ?? 12;
    _isPublished = widget.quiz.isPublished;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>(
      create: (context) => getIt<QuizBloc>(),
      child: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chỉnh sửa bài học'),
              actions: [
                if (state is! QuizLoading)
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveQuiz,
                    tooltip: 'Lưu bài học',
                  ),
              ],
            ),
            body: state is QuizLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'Tiêu đề',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập tiêu đề bài học',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tiêu đề';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Description
                          const Text(
                            'Mô tả',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập mô tả bài học',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Type
                          const Text(
                            'Loại bài học',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: AppConstants.choicesQuiz,
                                child: const Text('Trắc nghiệm'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.pairingQuiz,
                                child: const Text('Ghép đôi'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.sequentialQuiz,
                                child: const Text('Sắp xếp'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn loại bài học';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Difficulty
                          const Text(
                            'Độ khó',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: AppConstants.difficultyEasy,
                                child: const Text('Dễ'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.difficultyMedium,
                                child: const Text('Trung bình'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.difficultyHard,
                                child: const Text('Khó'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn độ khó';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category
                          const Text(
                            'Danh mục',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _category,
                            decoration: const InputDecoration(
                              hintText: 'Nhập danh mục (ví dụ: Động vật, Màu sắc)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _category = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Age range
                          const Text(
                            'Độ tuổi phù hợp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _minAge.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Từ',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _minAge = int.tryParse(value) ?? 3;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _maxAge.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Đến',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _maxAge = int.tryParse(value) ?? 12;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tags
                          const Text(
                            'Thẻ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập các thẻ, phân cách bằng dấu phẩy',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Published status
                          SwitchListTile(
                            title: const Text(
                              'Xuất bản',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: const Text(
                              'Bài học sẽ hiển thị cho người dùng',
                            ),
                            value: _isPublished,
                            onChanged: (value) {
                              setState(() {
                                _isPublished = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveQuiz,
                              child: const Text('Lưu thay đổi'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      final updatedQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        difficulty: _selectedDifficulty,
        tags: _tagsController.text.isEmpty
            ? []
            : _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .toList(),
        isPublished: _isPublished,
        updatedAt: DateTime.now(),
        category: _category.isEmpty ? null : _category,
        ageRangeMin: _minAge,
        ageRangeMax: _maxAge,
      );

      context.read<QuizBloc>().add(UpdateQuiz(updatedQuiz));
    }
  }
}
