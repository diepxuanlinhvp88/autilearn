import 'package:flutter/material.dart';
import '../data/models/quiz_model.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/quiz/choices_quiz_page.dart';
import '../presentation/pages/quiz/pairing_quiz_page.dart';
import '../presentation/pages/quiz/sequential_quiz_page.dart';
import '../presentation/pages/teacher/create_quiz_page.dart';
import '../presentation/pages/teacher/edit_quiz_page.dart';
import '../presentation/pages/teacher/manage_quizzes_page.dart';
import '../presentation/pages/teacher/question_list_page.dart';
import '../presentation/pages/teacher/create_question_page.dart';
import '../presentation/pages/teacher/edit_question_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/profile/achievements_page.dart';
import '../presentation/pages/profile/progress_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String choicesQuiz = '/quiz/choices';
  static const String pairingQuiz = '/quiz/pairing';
  static const String sequentialQuiz = '/quiz/sequential';
  static const String createQuiz = '/teacher/create-quiz';
  static const String editQuiz = '/teacher/edit-quiz';
  static const String manageQuizzes = '/teacher/manage-quizzes';
  static const String questionList = '/teacher/question-list';
  static const String createQuestion = '/teacher/create-question';
  static const String editQuestion = '/teacher/edit-question';
  static const String profile = '/profile';
  static const String achievements = '/profile/achievements';
  static const String progress = '/profile/progress';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case choicesQuiz:
        final quizId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => ChoicesQuizPage(quizId: quizId));
      case pairingQuiz:
        final quizId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => PairingQuizPage(quizId: quizId));
      case sequentialQuiz:
        final quizId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => SequentialQuizPage(quizId: quizId));
      case createQuiz:
        return MaterialPageRoute(builder: (_) => const CreateQuizPage());
      case editQuiz:
        final quiz = settings.arguments as QuizModel;
        return MaterialPageRoute(builder: (_) => EditQuizPage(quiz: quiz));
      case manageQuizzes:
        return MaterialPageRoute(builder: (_) => const ManageQuizzesPage());
      case questionList:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestionListPage(
            quizId: args['quizId'],
            quizTitle: args['quizTitle'],
            quizType: args['quizType'],
          ),
        );
      case createQuestion:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CreateQuestionPage(
            quizId: args['quizId'],
            quizType: args['quizType'],
            order: args['order'],
          ),
        );
      case editQuestion:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditQuestionPage(
            question: args['question'],
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case achievements:
        return MaterialPageRoute(builder: (_) => const AchievementsPage());
      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
