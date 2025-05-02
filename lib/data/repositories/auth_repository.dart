import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/auth_failure.dart';
import '../../core/services/auth_service.dart';
import '../models/user_model.dart';
import '../datasources/firebase_datasource.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseDataSource _firebaseDataSource;

  AuthRepository({
    required AuthService authService,
    required FirebaseDataSource firebaseDataSource,
  })  : _authService = authService,
        _firebaseDataSource = firebaseDataSource;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<Either<AuthFailure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<Either<AuthFailure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    print('Registering user with email: $email, name: $name, role: $role');
    final result = await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      role: role,
    );

    return result.fold(
      (failure) {
        print('Registration failed: ${failure.message}');
        return Left(failure);
      },
      (user) async {
        print('User registered successfully with UID: ${user.uid}');
        // Create user document in Firestore
        final userModel = UserModel(
          id: user.uid,
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        print('Creating user document in Firestore with role: $role');
        final result = await _firebaseDataSource.createUser(userModel);
        result.fold(
          (error) => print('Error creating user document: $error'),
          (_) => print('User document created successfully'),
        );
        return Right(user);
      },
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<Either<String, UserModel>> getUserProfile(String userId) async {
    return _firebaseDataSource.getUserById(userId);
  }

  Future<Either<String, bool>> updateUserProfile(UserModel user) async {
    return _firebaseDataSource.updateUser(user);
  }
}
