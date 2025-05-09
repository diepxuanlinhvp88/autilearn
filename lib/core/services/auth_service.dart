import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/auth_failure.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Either<AuthFailure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Set reCAPTCHA verification to false for debug mode
      await _firebaseAuth.setSettings(appVerificationDisabledForTesting: true);

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

        if (!userDoc.exists) {
          print('AuthService: User document does not exist in Firestore, creating it');
          // Tạo mới người dùng trong Firestore nếu chưa tồn tại
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': userCredential.user!.displayName ?? 'Người dùng',
            'email': userCredential.user!.email ?? '',
            'role': 'student', // Mặc định là học sinh
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        } else {
          print('AuthService: User document exists in Firestore');
          final data = userDoc.data() as Map<String, dynamic>;
          print('AuthService: User role in Firestore: ${data['role']}');
        }
      } catch (e) {
        print('AuthService: Error checking user in Firestore: $e');
      }

      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Left(AuthFailure.userNotFound());
      } else if (e.code == 'wrong-password') {
        return Left(AuthFailure.wrongPassword());
      } else {
        return Left(AuthFailure.serverError());
      }
    } catch (e) {
      return Left(AuthFailure.serverError());
    }
  }

  Future<Either<AuthFailure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role, // 'parent', 'teacher', or 'student'
  }) async {
    try {
      print('AuthService: Registering user with email: $email, role: $role');
      // Set reCAPTCHA verification to false for debug mode
      await _firebaseAuth.setSettings(appVerificationDisabledForTesting: true);

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AuthService: User created in Firebase Auth, updating display name');
      // Update user profile with name
      await userCredential.user!.updateDisplayName(name);

      // Đợi cập nhật hoàn tất
      await userCredential.user!.reload();

      // Kiểm tra xem tên đã được cập nhật chưa
      print('AuthService: Updated display name: ${userCredential.user!.displayName}');

      // Lưu thông tin người dùng vào Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
        print('AuthService: User information saved to Firestore with role: $role');
      } catch (e) {
        print('AuthService: Error saving user information to Firestore: $e');
      }

      // Add custom claims or user data to Firestore here
      print('AuthService: Registration successful, user: ${userCredential.user!.uid}, role: $role');

      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      print('AuthService: FirebaseAuthException during registration: ${e.code}');
      if (e.code == 'email-already-in-use') {
        return Left(AuthFailure.emailAlreadyInUse());
      } else if (e.code == 'weak-password') {
        return Left(AuthFailure.weakPassword());
      } else {
        return Left(AuthFailure.serverError());
      }
    } catch (e) {
      print('AuthService: Error during registration: $e');
      return Left(AuthFailure.serverError());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
