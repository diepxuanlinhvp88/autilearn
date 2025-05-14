import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../firebase_options.dart';
import '../core/services/auth_service.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/user/user_bloc.dart';
import '../main.dart';
import '../presentation/blocs/auth/auth_event.dart';
import 'routes.dart';
import '../presentation/blocs/quiz/quiz_bloc.dart';
import '../presentation/blocs/reward/reward_bloc.dart';
import '../presentation/blocs/assessment/assessment_bloc.dart';
import '../presentation/blocs/schedule/schedule_bloc.dart';
import '../presentation/blocs/teacher_student/teacher_student_bloc.dart';
import '../presentation/blocs/firestore_error/firestore_error_bloc.dart';

class AutiLearnApp extends StatelessWidget {
  const AutiLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
        BlocProvider<QuizBloc>(
          create: (context) => getIt<QuizBloc>(),
        ),
        BlocProvider<RewardBloc>(
          create: (context) => getIt<RewardBloc>(),
        ),
        BlocProvider<AssessmentBloc>(
          create: (context) => getIt<AssessmentBloc>(),
        ),
        BlocProvider<ScheduleBloc>(
          create: (context) => getIt<ScheduleBloc>(),
        ),
        BlocProvider<TeacherStudentBloc>(
          create: (context) => getIt<TeacherStudentBloc>(),
        ),
        BlocProvider<FirestoreErrorBloc>(
          create: (context) => getIt<FirestoreErrorBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          print('AutiLearnApp: AuthBloc state: ${context.watch<AuthBloc>().state}');
          return MaterialApp(
            title: 'AutiLearn',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
              ),
            ),
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.splash,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
