import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../../core/services/auth_service.dart';
import '../models/user_model.dart';
import '../datasources/firebase_datasource.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseDataSource _firebaseDataSource;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required AuthService authService,
    required FirebaseDataSource firebaseDataSource,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _firebaseDataSource = firebaseDataSource,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(ServerFailure('Failed to sign in'));
      }

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(ServerFailure('Failed to create user'));
      }

      // Không cập nhật thông tin người dùng ngay lập tức để tránh lỗi
      // Thông tin sẽ được cập nhật sau trong AuthBloc

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<Either<Failure, UserModel>> getUserProfile(String userId) async {
    return _firebaseDataSource.getUserById(userId);
  }

  Future<Either<Failure, bool>> updateUserProfile(UserModel user) async {
    return _firebaseDataSource.updateUser(user);
  }

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(ServerFailure('Failed to create user'));
      }

      // Không cập nhật thông tin người dùng ngay lập tức để tránh lỗi
      // Thông tin sẽ được cập nhật sau trong AuthBloc

      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Nếu chưa tồn tại, tạo mới
          await _firestore.collection('users').doc(user.uid).set({
            'name': name,
            'email': email,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('AuthRepository: User information saved to Firestore with role: $role');
        } else {
          print('AuthRepository: User already exists in Firestore');
        }
      } catch (e) {
        print('AuthRepository: Error checking/saving user in Firestore: $e');
        // Không throw exception để tiếp tục quá trình đăng ký
      }

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
