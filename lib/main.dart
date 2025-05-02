import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/sample_data_service.dart';
import 'core/services/user_role_service.dart';
import 'data/datasources/firebase_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/quiz/quiz_bloc.dart';
import 'presentation/blocs/user/user_progress_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await initializeApp();

  // Setup dependency injection
  setupDependencies();

  runApp(const AutiLearnApp());
}

void setupDependencies() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<UserRoleService>(() => UserRoleService());

  // Data sources
  getIt.registerLazySingleton<FirebaseDataSource>(() => FirebaseDataSource());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
        authService: getIt<AuthService>(),
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<QuizRepository>(() => QuizRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  getIt.registerLazySingleton<UserRepository>(() => UserRepository(
        firebaseDataSource: getIt<FirebaseDataSource>(),
      ));

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
        authService: getIt<AuthService>(),
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
      ));
}
