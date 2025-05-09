import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/widgets/teacher/question_form_widget.dart';
import '../../../presentation/widgets/teacher/question_preview_widget.dart';

class EditQuestionPage extends StatefulWidget {
  final QuestionModel question;

  const EditQuestionPage({
    super.key,
    required this.question,
  });

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  QuestionModel? _previewQuestion;

  @override
  void initState() {
    super.initState();
    _previewQuestion = widget.question;
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
              title: const Text('Chỉnh sửa câu hỏi'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form
                  QuestionFormWidget(
                    quizType: widget.question.type,
                    initialQuestion: widget.question,
                    onSave: (question) {
                      print('EditQuestionPage: onSave callback received question');
                      print('EditQuestionPage: Original question ID: ${widget.question.id}');
                      print('EditQuestionPage: Received question ID: ${question.id}');

                      // Preserve ID and order
                      final updatedQuestion = question.copyWith(
                        id: widget.question.id,
                        quizId: widget.question.quizId,
                        order: widget.question.order,
                      );

                      print('EditQuestionPage: Updated question ID: ${updatedQuestion.id}');
                      print('EditQuestionPage: Updated question: $updatedQuestion');

                      setState(() {
                        _previewQuestion = updatedQuestion;
                      });

                      // Update question
                      print('EditQuestionPage: Dispatching UpdateQuestion event');
                      context.read<QuizBloc>().add(UpdateQuestion(updatedQuestion));
                    },
                    onPreview: (question) {
                      // Preserve ID and order
                      final updatedQuestion = question.copyWith(
                        id: widget.question.id,
                        quizId: widget.question.quizId,
                        order: widget.question.order,
                      );

                      setState(() {
                        _previewQuestion = updatedQuestion;
                      });
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
