import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/quiz_model.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/quiz/choices_quiz_page.dart';
import '../presentation/pages/quiz/pairing_quiz_page.dart';
import '../presentation/pages/quiz/sequential_quiz_page.dart';
import '../presentation/pages/quiz/emotions_quiz_page.dart';
import '../presentation/pages/drawing/drawing_home_page.dart';
import '../presentation/pages/drawing/free_drawing_page.dart';
import '../presentation/pages/drawing/template_drawing_page.dart';
import '../presentation/pages/drawing/drawing_result_page.dart';
import '../presentation/pages/drawing/test_drawing_page.dart';
import '../presentation/pages/teacher/manage_students_page.dart';

import '../presentation/pages/reward/badges_page.dart';
import '../presentation/pages/reward/reward_shop_page.dart';
import '../presentation/pages/analytics/student_analytics_page.dart';
import '../presentation/pages/analytics/teacher_analytics_page.dart';
// Ẩn đánh giá kỹ năng
// import '../presentation/pages/assessment/assessment_list_page.dart';
import '../presentation/pages/schedule/schedule_list_page.dart';
import '../presentation/pages/schedule/calendar_page.dart';
import '../presentation/pages/teacher/create_quiz_page.dart';
import '../presentation/pages/teacher/edit_quiz_page.dart';
import '../presentation/pages/teacher/manage_quizzes_page.dart';
import '../presentation/pages/teacher/question_list_page.dart';
import '../presentation/pages/teacher/create_question_page.dart';
import '../presentation/pages/teacher/edit_question_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/profile/profile_page_basic.dart';
import '../presentation/pages/profile/achievements_page.dart';
import '../presentation/pages/profile/progress_page.dart';
import '../presentation/pages/reward/badges_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String choicesQuiz = '/quiz/choices';
  static const String pairingQuiz = '/quiz/pairing';
  static const String sequentialQuiz = '/quiz/sequential';
  static const String emotionsQuiz = '/quiz/emotions';
  static const String drawingHome = '/drawing';
  static const String freeDrawing = '/drawing/free';
  static const String templateDrawing = '/drawing/template';
  static const String drawingResult = '/drawing/result';
  static const String testDrawing = '/drawing/test';
  static const String badges = '/profile/badges';
  static const String rewardShop = '/profile/reward-shop';
  static const String studentAnalytics = '/analytics/student';
  static const String teacherAnalytics = '/analytics/teacher';
  static const String assessments = '/assessment/list';
  static const String scheduleList = '/schedule/list';
  static const String calendar = '/schedule/calendar';
  static const String manageQuizzes = '/teacher/manage-quizzes';
  static const String createQuiz = '/teacher/create-quiz';
  static const String editQuiz = '/teacher/edit-quiz';
  static const String questionList = '/teacher/question-list';
  static const String createQuestion = '/teacher/create-question';
  static const String editQuestion = '/teacher/edit-question';
  static const String profile = '/profile';
  static const String achievements = '/profile/achievements';
  static const String progress = '/profile/progress';
  static const String manageStudents = '/manage-students';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
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
      case emotionsQuiz:
        final quizId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => EmotionsQuizPage(quizId: quizId));
      case drawingHome:
        return MaterialPageRoute(builder: (_) => const DrawingHomePage());
      case freeDrawing:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => FreeDrawingPage(
          drawingId: args?['drawingId'],
        ));
      case templateDrawing:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => TemplateDrawingPage(
          templateId: args?['templateId'],
        ));
      case drawingResult:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => DrawingResultPage(
          score: args['score'],
          drawingId: args['drawingId'],
          drawingType: args['drawingType'],
        ));
      case testDrawing:
        return MaterialPageRoute(builder: (_) => const TestDrawingPage());
      case badges:
        return MaterialPageRoute(builder: (_) => const BadgesPage());
      case rewardShop:
        return MaterialPageRoute(builder: (_) => const RewardShopPage());
      case studentAnalytics:
        return MaterialPageRoute(builder: (_) => const StudentAnalyticsPage());
      case teacherAnalytics:
        return MaterialPageRoute(builder: (_) => const TeacherAnalyticsPage());
      // Ẩn đánh giá kỹ năng
      case assessments:
        // final studentId = settings.arguments as String?;
        // return MaterialPageRoute(builder: (_) => AssessmentListPage(studentId: studentId));
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Tính năng đã bỏ')),
            body: const Center(
              child: Text('Tính năng đánh giá kỹ năng đã bỏ'),
            ),
          ),
        );
      case scheduleList:
        return MaterialPageRoute(builder: (_) => const ScheduleListPage());
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarPage());

      case createQuiz:
        return MaterialPageRoute(
          builder: (context) {
            print('AppRouter: Creating CreateQuizPage route');
            print('AppRouter: AuthBloc state: ${BlocProvider.of<AuthBloc>(context).state}');
            return const CreateQuizPage();
          },
        );
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
        return MaterialPageRoute(builder: (_) => const ProfilePageBasic());
      case achievements:
        return MaterialPageRoute(builder: (_) => const AchievementsPage());
      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressPage());
      case badges:
        return MaterialPageRoute(builder: (_) => const BadgesPage());
      case manageStudents:
        return MaterialPageRoute(builder: (_) => const ManageStudentsPage());
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
