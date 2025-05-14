import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/quiz_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../app/routes.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy vai trò người dùng từ Firestore
  Future<String> _getUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting user role: $e');
      return '';
    }
  }
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = AppConstants.choicesQuiz;
  String _selectedDifficulty = AppConstants.difficultyEasy;
  final _tagsController = TextEditingController();
  int _minAge = 3;
  int _maxAge = 12;
  String? _category;
  final List<String> _categories = [
    'Toán học',
    'Ngôn ngữ',
    'Khoa học',
    'Kỹ năng sống',
    'Nghệ thuật',
    'Thể thao',
    'Khác',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In ra trạng thái hiện tại của AuthBloc để gỡ lỗi
    final authState = context.watch<AuthBloc>().state;
    print('CreateQuizPage: Current AuthState: $authState');

    return BlocProvider<QuizBloc>(
      create: (context) => getIt<QuizBloc>(),
      child: Builder(
        builder: (context) {
        // Trả về một Widget mặc định để tránh lỗi
        Widget result = const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

        if (authState is Authenticated) {
          // Kiểm tra vai trò người dùng
          return FutureBuilder<String>(
            future: _getUserRole(authState.user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final userRole = snapshot.data ?? '';

              // Chỉ cho phép giáo viên và phụ huynh truy cập
              if (userRole == AppConstants.roleTeacher || userRole == AppConstants.roleParent) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tạo bài học mới'),
            ),
            body: BlocConsumer<QuizBloc, QuizState>(
              listener: (context, state) {
                if (state is QuizOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to question list page for the new quiz
                  if (state.message.contains('created successfully')) {
                    // Extract quiz ID from the state
                    final quizId = state.data as String?;
                    if (quizId != null) {
                      Navigator.of(context).pushReplacementNamed(
                        AppRouter.questionList,
                        arguments: {
                          'quizId': quizId,
                          'quizTitle': _titleController.text.trim(),
                          'quizType': _selectedType,
                        },
                      );
                    } else {
                      Navigator.of(context).pushReplacementNamed(AppRouter.manageQuizzes);
                    }
                  } else {
                    Navigator.of(context).pushReplacementNamed(AppRouter.manageQuizzes);
                  }
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề bài học',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tiêu đề bài học';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Mô tả bài học',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mô tả bài học';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Quiz type
                          const Text(
                            'Loại bài học:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.quiz),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: AppConstants.choicesQuiz,
                                child: const Text('Bài học lựa chọn'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.pairingQuiz,
                                child: const Text('Bài học ghép đôi'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.sequentialQuiz,
                                child: const Text('Bài học sắp xếp'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.emotionsQuiz,
                                child: const Text('Nhận diện cảm xúc'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Difficulty
                          const Text(
                            'Độ khó:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.trending_up),
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
                          ),
                          const SizedBox(height: 16),
                          // Category
                          const Text(
                            'Danh mục:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                              hintText: 'Chọn danh mục',
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _category = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Tags
                          TextFormField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              labelText: 'Thẻ (phân cách bằng dấu phẩy)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.tag),
                              hintText: 'Ví dụ: toán học, số đếm, màu sắc',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Age range
                          const Text(
                            'Độ tuổi phù hợp:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _minAge.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Tuổi tối thiểu',
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
                                    labelText: 'Tuổi tối đa',
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
                          const SizedBox(height: 24),
                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state is QuizLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        final quiz = QuizModel(
                                          id: '',
                                          title: _titleController.text.trim(),
                                          description: _descriptionController.text.trim(),
                                          type: _selectedType,
                                          creatorId: authState.user.uid,
                                          difficulty: _selectedDifficulty,
                                          tags: _tagsController.text.isEmpty
                                              ? []
                                              : _tagsController.text
                                                  .split(',')
                                                  .map((tag) => tag.trim())
                                                  .toList(),
                                          isPublished: false,
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                          questionCount: 0,
                                          category: _category ?? 'Chung',
                                          ageRangeMin: _minAge,
                                          ageRangeMax: _maxAge,
                                        );

                                        context.read<QuizBloc>().add(CreateQuiz(quiz));
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: state is QuizLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Tạo bài học',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

              // Nếu là học sinh, hiển thị thông báo không có quyền truy cập
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Tạo bài học mới'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.lock,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Bạn không có quyền truy cập',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chỉ giáo viên và phụ huynh mới có thể tạo bài học',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (authState is Unauthenticated) {
          // Redirect to login page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          });
          result = const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return result;
        },
      ),
    );
  }
}
