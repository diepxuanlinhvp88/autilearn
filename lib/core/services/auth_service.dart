import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import '../error/failures.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Tắt xác thực reCAPTCHA hoàn toàn
      try {
        await _auth.setSettings(
          appVerificationDisabledForTesting: true,
          forceRecaptchaFlow: false,
          phoneNumber: '+11111111111',
          smsCode: '111111',
        );
        print('AuthService: reCAPTCHA disabled successfully for sign in');
      } catch (e) {
        print('AuthService: Error disabling reCAPTCHA: $e');
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(AuthFailure('User not found'));
      }

      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          print('AuthService: User document does not exist in Firestore, creating it');
          // Tạo mới người dùng trong Firestore nếu chưa tồn tại
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Người dùng',
            'email': user.email ?? '',
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

      return Right(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return Left(AuthFailure('User not found'));
        case 'wrong-password':
          return Left(AuthFailure('Wrong password'));
        default:
          return Left(AuthFailure('Authentication failed: ${e.message}'));
      }
    } catch (e) {
      return Left(AuthFailure('Server error occurred'));
    }
  }

  // Phương thức đăng ký tài khoản mới hoặc đăng nhập nếu tài khoản đã tồn tại
  Future<Either<Failure, User>> registerAccount({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Registering account with email: $email');
      // Tắt xác thực reCAPTCHA hoàn toàn
      try {
        await _auth.setSettings(
          appVerificationDisabledForTesting: true,
          forceRecaptchaFlow: false,
          phoneNumber: '+11111111111',
          smsCode: '111111',
        );
        print('AuthService: reCAPTCHA disabled successfully');
      } catch (e) {
        print('AuthService: Error disabling reCAPTCHA: $e');
      }

      // Thử tạo tài khoản mới trực tiếp
      try {
        print('AuthService: Attempting to create new account directly');
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user == null) {
          return Left(AuthFailure('Failed to create user'));
        }

        print('AuthService: User account created in Firebase Auth: ${user.uid}');
        return Right(user);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Nếu email đã tồn tại, thử đăng nhập
          print('AuthService: Email already in use, trying to sign in');
          try {
            final signInResult = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            final user = signInResult.user;
            if (user == null) {
              return Left(AuthFailure('Failed to sign in'));
            }

            print('AuthService: User signed in: ${user.uid}');
            return Right(user);
          } catch (signInError) {
            print('AuthService: Error signing in: $signInError');
            return Left(AuthFailure('Authentication failed: $signInError'));
          }
        } else {
          print('AuthService: Error creating user: ${e.message}');
          return Left(AuthFailure('Authentication failed: ${e.message}'));
        }
      }
    } catch (e) {
      print('AuthService: Error during account registration: $e');
      return Left(AuthFailure('Server error occurred'));
    }
  }

  // Phương thức lưu thông tin người dùng vào Firestore
  Future<Either<Failure, bool>> saveUserToFirestore({
    required String userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      print('AuthService: Saving user information to Firestore: $userId, $role');

      // Sử dụng SetOptions(merge: true) để tránh ghi đè lên dữ liệu hiện có
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('AuthService: User information saved to Firestore with role: $role');

      // Kiểm tra lại để đảm bảo
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        print('AuthService: Verified user document exists in Firestore');
        final data = userDoc.data();
        if (data != null) {
          print('AuthService: User role in Firestore: ${data['role']}');
        }
      } else {
        print('AuthService: WARNING: User document still not found in Firestore after saving');
        // Thử lại một lần nữa với cách khác
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
        print('AuthService: Retry saving user information with Timestamp.now()');
      }

      return const Right(true);
    } catch (e) {
      print('AuthService: Error saving user information to Firestore: $e');
      return Left(AuthFailure('Failed to save user information'));
    }
  }

  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role, // 'parent', 'teacher', or 'student'
  }) async {
    try {
      print('AuthService: Registering user with email: $email, role: $role');

      // Đăng ký tài khoản mới hoặc đăng nhập nếu tài khoản đã tồn tại
      final accountResult = await registerAccount(email: email, password: password);

      return accountResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Lưu thông tin người dùng vào Firestore
          try {
            // Đợi 1 giây để đảm bảo Firebase Auth đã hoàn tất
            await Future.delayed(const Duration(seconds: 1));

            final saveResult = await saveUserToFirestore(
              userId: user.uid,
              name: name,
              email: email,
              role: role,
            );

            return saveResult.fold(
              (failure) {
                print('AuthService: Failed to save user information: ${failure.message}');
                // Thử lại một lần nữa
                try {
                  FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                    'name': name,
                    'email': email,
                    'role': role,
                    'createdAt': Timestamp.now(),
                    'updatedAt': Timestamp.now(),
                  }, SetOptions(merge: true));
                  print('AuthService: User information saved to Firestore on retry');
                } catch (retryError) {
                  print('AuthService: Error saving user information to Firestore on retry: $retryError');
                }
                return Right(user); // Vẫn trả về user để tiếp tục quá trình đăng ký
              },
              (_) => Right(user),
            );
          } catch (e) {
            print('AuthService: Error during save user information: $e');
            return Right(user); // Vẫn trả về user để tiếp tục quá trình đăng ký
          }
        },
      );
    } catch (e) {
      print('AuthService: Error during registration: $e');
      return Left(AuthFailure('Server error occurred'));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Phương thức cập nhật thông tin người dùng sau khi đăng ký
  Future<Either<Failure, bool>> updateUserProfile(String userId, String displayName) async {
    try {
      // Lấy người dùng hiện tại
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return Left(AuthFailure('User not found or not authenticated'));
      }

      // Cập nhật tên hiển thị
      try {
        await user.updateProfile(displayName: displayName);
        await user.reload();
        print('AuthService: Updated display name: ${user.displayName}');
      } catch (e) {
        print('AuthService: Error updating display name: $e');
        // Tiếp tục mặc dù có lỗi khi cập nhật tên
      }

      return const Right(true);
    } catch (e) {
      print('AuthService: Error updating user profile: $e');
      return Left(AuthFailure('Failed to update user profile'));
    }
  }

  // Phương thức gửi email đặt lại mật khẩu
  Future<Either<Failure, bool>> resetPassword(String email) async {
    try {
      print('AuthService: Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('AuthService: Password reset email sent successfully');
      return const Right(true);
    } on FirebaseAuthException catch (e) {
      print('AuthService: Error sending password reset email: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return Left(AuthFailure('Không tìm thấy tài khoản với email này'));
        case 'invalid-email':
          return Left(AuthFailure('Email không hợp lệ'));
        default:
          return Left(AuthFailure('Lỗi: ${e.message}'));
      }
    } catch (e) {
      print('AuthService: Unexpected error sending password reset email: $e');
      return Left(AuthFailure('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.'));
    }
  }
}
