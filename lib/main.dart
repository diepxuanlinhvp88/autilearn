import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/app.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/sample_data_service.dart';
import 'core/services/user_role_service.dart';
import 'core/services/imgur_service.dart';
import 'core/services/badge_service.dart';
import 'core/services/drawing_service.dart';
import 'data/repositories/reward_repository.dart';
import 'data/repositories/analytics_repository.dart';
import 'data/repositories/assessment_repository.dart';
import 'data/repositories/schedule_repository.dart';
import 'data/datasources/firebase_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/badge_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/quiz/quiz_bloc.dart';
import 'presentation/blocs/user/user_progress_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/reward/reward_bloc.dart';
import 'presentation/blocs/analytics/analytics_bloc.dart';
import 'presentation/blocs/assessment/assessment_bloc.dart';
import 'presentation/blocs/schedule/schedule_bloc.dart';
import 'presentation/blocs/teacher_student/teacher_student_bloc.dart';
import 'data/repositories/teacher_student_repository.dart';
import 'presentation/blocs/firestore_error/firestore_error_bloc.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup dependency injection
  setupDependencyInjection();

  runApp(const AutiLearnApp());
}

void setupDependencyInjection() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<UserRoleService>(() => UserRoleService());
  getIt.registerLazySingleton<ImgurService>(() => ImgurService());
  getIt.registerLazySingleton<BadgeService>(() => BadgeService(firestore: FirebaseFirestore.instance));
  getIt.registerLazySingleton<DrawingService>(() => DrawingService());

  // Data sources
  getIt.registerLazySingleton<FirebaseDataSource>(() => FirebaseDataSource());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authService: getIt<AuthService>(),
      firebaseDataSource: getIt<FirebaseDataSource>(),
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ),
  );

  getIt.registerLazySingleton<QuizRepository>(() => QuizRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<UserRepository>(() => UserRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<RewardRepository>(() => RewardRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<AnalyticsRepository>(() => AnalyticsRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<AssessmentRepository>(() => AssessmentRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<ScheduleRepository>(() => ScheduleRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<BadgeRepository>(
    () => BadgeRepository(firestore: FirebaseFirestore.instance),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
    authService: getIt<AuthService>(),
    authRepository: getIt<AuthRepository>(),
    badgeRepository: getIt<BadgeRepository>(),
  ));

  getIt.registerFactory<QuizBloc>(() => QuizBloc(
        quizRepository: getIt<QuizRepository>(),
      ));

  getIt.registerFactory<UserProgressBloc>(() => UserProgressBloc(
        quizRepository: getIt<QuizRepository>(),
      ));

  getIt.registerFactory<UserBloc>(() => UserBloc(
        userRepository: getIt<UserRepository>(),
        quizRepository: getIt<QuizRepository>(),
        badgeRepository: getIt<BadgeRepository>(),
      ));

  getIt.registerFactory<RewardBloc>(() => RewardBloc(
        rewardRepository: getIt<RewardRepository>(),
      ));

  getIt.registerFactory<AnalyticsBloc>(() => AnalyticsBloc(
        analyticsRepository: getIt<AnalyticsRepository>(),
      ));

  getIt.registerFactory<AssessmentBloc>(() => AssessmentBloc(
        assessmentRepository: getIt<AssessmentRepository>(),
      ));

  getIt.registerFactory<ScheduleBloc>(() => ScheduleBloc(
        scheduleRepository: getIt<ScheduleRepository>(),
      ));

  getIt.registerLazySingleton<TeacherStudentRepository>(() => TeacherStudentRepository());
  getIt.registerFactory<TeacherStudentBloc>(
    () => TeacherStudentBloc(repository: getIt<TeacherStudentRepository>()),
  );

  // Register FirestoreErrorBloc
  getIt.registerFactory<FirestoreErrorBloc>(() => FirestoreErrorBloc());

  // Initialize sample data
  getIt<BadgeService>().createSampleBadges();
}
