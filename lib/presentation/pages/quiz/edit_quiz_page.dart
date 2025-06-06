import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../data/models/quiz_model.dart';
import '../../../main.dart';

class EditQuizPage extends StatefulWidget {
  final QuizModel quiz;

  const EditQuizPage({
    Key? key,
    required this.quiz,
  }) : super(key: key);

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _type;
  late int _difficulty;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _title = widget.quiz.title;
    _description = widget.quiz.description;
    _type = widget.quiz.type;
    _difficulty = widget.quiz.difficulty as int;
    _imageUrl = widget.quiz.imageUrl!;
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo UserBloc đã được tải
    if (context.read<UserBloc>().state is! UserProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
      }
    }
    
    return BlocProvider<QuizBloc>(
      create: (context) => getIt<QuizBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa bài học'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: state is QuizLoading
                      ? null
                      : () => _saveQuiz(context),
                  tooltip: 'Lưu thay đổi',
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is QuizUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật bài học'),
                  backgroundColor: Colors.green,
                ),
              );
              
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề bài học',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      initialValue: _title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tiêu đề bài học';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _title = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      initialValue: _description,
                      maxLines: 3,
                      onChanged: (value) {
                        _description = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Loại bài học',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _type,
                      items: [
                        DropdownMenuItem<String>(
                          value: 'choices_quiz',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text('Bài học lựa chọn'),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'pairing_quiz',
                          child: Row(
                            children: [
                              Icon(Icons.compare_arrows, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              const Text('Bài học ghép đôi'),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'sequential_quiz',
                          child: Row(
                            children: [
                              Icon(Icons.sort, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              const Text('Bài học sắp xếp'),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'emotions_quiz',
                          child: Row(
                            children: [
                              Icon(Icons.emoji_emotions, color: Colors.purple.shade700),
                              const SizedBox(width: 8),
                              const Text('Bài học nhận diện cảm xúc'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _type = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Độ khó:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _difficulty.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _getDifficultyText(_difficulty),
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'URL hình ảnh (tùy chọn)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                      initialValue: _imageUrl,
                      onChanged: (value) {
                        _imageUrl = value;
                      },
                    ),
                    if (_imageUrl.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Xem trước hình ảnh:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Text('Không thể tải hình ảnh'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Rất dễ';
      case 2:
        return 'Dễ';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Khó';
      case 5:
        return 'Rất khó';
      default:
        return 'Trung bình';
    }
  }

  void _saveQuiz(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final updatedQuiz = widget.quiz.copyWith(
        title: _title,
        description: _description,
        type: _type,
        difficulty: _difficulty.toString(),
        imageUrl: _imageUrl,
        updatedAt: DateTime.now(),
      );
      
      context.read<QuizBloc>().add(UpdateQuiz(updatedQuiz));
    }
  }
}
