import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/widgets/teacher/question_form_widget.dart';
import '../../../presentation/widgets/teacher/question_preview_widget.dart';

class CreateQuestionPage extends StatefulWidget {
  final String quizId;
  final String quizType;
  final int order;

  const CreateQuestionPage({
    super.key,
    required this.quizId,
    required this.quizType,
    required this.order,
  });

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  QuestionModel? _previewQuestion;

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
            Navigator.of(context).pop();
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
              title: const Text('Tạo câu hỏi mới'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form
                  QuestionFormWidget(
                    quizType: widget.quizType,
                    onSave: (question) {
                      // Update with quiz ID and order
                      final updatedQuestion = question.copyWith(
                        quizId: widget.quizId,
                        order: widget.order,
                      );
                      
                      setState(() {
                        _previewQuestion = updatedQuestion;
                      });
                      
                      // Create question
                      context.read<QuizBloc>().add(CreateQuestion(updatedQuestion));
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preview
                  if (_previewQuestion != null)
                    QuestionPreviewWidget(question: _previewQuestion!),
                ],
              ),
            ),
            bottomNavigationBar: state is QuizLoading
                ? const LinearProgressIndicator()
                : null,
          );
        },
      ),
    );
  }
}
