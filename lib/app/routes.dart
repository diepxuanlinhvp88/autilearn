import 'package:flutter/material.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/quiz/choices_quiz_page.dart';
import '../presentation/pages/quiz/pairing_quiz_page.dart';
import '../presentation/pages/quiz/sequential_quiz_page.dart';
import '../presentation/pages/teacher/create_quiz_page.dart';
import '../presentation/pages/teacher/manage_quizzes_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String choicesQuiz = '/quiz/choices';
  static const String pairingQuiz = '/quiz/pairing';
  static const String sequentialQuiz = '/quiz/sequential';
  static const String createQuiz = '/teacher/create-quiz';
  static const String manageQuizzes = '/teacher/manage-quizzes';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case choicesQuiz:
        return MaterialPageRoute(builder: (_) => const ChoicesQuizPage());
      case pairingQuiz:
        return MaterialPageRoute(builder: (_) => const PairingQuizPage());
      case sequentialQuiz:
        return MaterialPageRoute(builder: (_) => const SequentialQuizPage());
      case createQuiz:
        return MaterialPageRoute(builder: (_) => const CreateQuizPage());
      case manageQuizzes:
        return MaterialPageRoute(builder: (_) => const ManageQuizzesPage());
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
