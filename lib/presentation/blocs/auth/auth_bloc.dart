import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/sample_data_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/badge_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final AuthRepository _authRepository;
  final BadgeRepository _badgeRepository;
  StreamSubscription<dynamic>? _authStateSubscription;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc({
    required this.authService,
    required AuthRepository authRepository,
    required BadgeRepository badgeRepository,
  })  : _authRepository = authRepository,
        _badgeRepository = badgeRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<EnsureUserInFirestore>(_onEnsureUserInFirestore);
    on<RefreshUserInfo>(_onRefreshUserInfo);
    on<SignUpRequested>(_onSignUpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);

    // Listen to auth state changes
    _authStateSubscription = authService.authStateChanges.listen((user) {
      if (user != null) {
        add(const AuthCheckRequested());
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = authService.currentUser;
    if (user != null) {
      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      try {
        print('AuthBloc: Checking if user exists in Firestore: ${user.uid}');
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          print('AuthBloc: User document not found in Firestore, creating it');
          // Tạo mới người dùng trong Firestore nếu chưa tồn tại
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Người dùng',
            'email': user.email ?? '',
            'role': user.email?.contains('giaovien') == true ? AppConstants.roleTeacher : AppConstants.roleStudent,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'avatar': 'https://i.imgur.com/6VBx3io.png', // Avatar mặc định
          });
          print('AuthBloc: User document created in Firestore');

          // Tạo badge mặc định cho người dùng mới
          try {
            final result = await _badgeRepository.assignBadgeToUser(user.uid, 'bronze_badge');
            result.fold(
              (failure) => print('AuthBloc: Failed to assign badge: ${failure.message}'),
              (_) => print('AuthBloc: Assigned default bronze badge to user')
            );
          } catch (e) {
            print('AuthBloc: Error assigning default badge: $e');
          }

          // Tạo dữ liệu mẫu cho người dùng mới

        } else {
          print('AuthBloc: User document exists in Firestore');
        }
      } catch (e) {
        print('AuthBloc: Error checking/creating user in Firestore: $e');
      }

      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final result = await authService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await result.fold(
        (failure) async => emit(AuthError(failure.message)),
        (user) async {
          try {
            // Lấy thông tin người dùng từ Firestore một lần duy nhất
            final userDoc = await _firestore.collection('users').doc(user.uid).get();

            if (!userDoc.exists) {
              // Tạo mới người dùng trong Firestore nếu chưa tồn tại
              await _firestore.collection('users').doc(user.uid).set({
                'name': user.displayName ?? 'Người dùng',
                'email': user.email ?? '',
                'role': AppConstants.roleStudent,
                'createdAt': Timestamp.now(),
                'updatedAt': Timestamp.now(),
              });
            }

            emit(Authenticated(user));
          } catch (e) {
            print('AuthBloc: Error handling Firestore operations: $e');
            // Vẫn emit Authenticated vì người dùng đã đăng nhập thành công
            emit(Authenticated(user));
          }
        },
      );
    } catch (e) {
      print('AuthBloc: Unexpected error during sign in: $e');
      emit(AuthError('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Handling RegisterRequested event');
    emit(const AuthLoading());

    try {
      // Sử dụng phương thức registerWithEmailAndPassword để đăng ký và lưu thông tin
      final result = await authService.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );

      result.fold(
        (failure) {
          print('AuthBloc: Registration failed: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (user) async {
          print('AuthBloc: Registration successful, user: ${user.uid}');

          // Kiểm tra lại để đảm bảo thông tin đã được lưu vào Firestore
          try {
            final userDoc = await _firestore.collection('users').doc(user.uid).get();
            if (!userDoc.exists) {
              print('AuthBloc: User document still not found in Firestore, creating it directly');
              // Thử lại một lần nữa
              await _firestore.collection('users').doc(user.uid).set({
                'name': event.name,
                'email': event.email,
                'role': event.role,
                'createdAt': Timestamp.now(),
                'updatedAt': Timestamp.now(),
              }, SetOptions(merge: true));
              print('AuthBloc: User document created directly');
            } else {
              print('AuthBloc: User document exists in Firestore');
              final data = userDoc.data() as Map<String, dynamic>;
              print('AuthBloc: User role in Firestore: ${data['role']}');
            }
          } catch (e) {
            print('AuthBloc: Error checking user in Firestore: $e');
          }

          // Cập nhật thông tin người dùng sau khi đăng ký thành công
          try {
            await Future.delayed(const Duration(seconds: 1)); // Đợi một chút để tránh lỗi
            final profileResult = await authService.updateUserProfile(user.uid, event.name);
            profileResult.fold(
              (failure) => print('AuthBloc: Failed to update user profile: ${failure.message}'),
              (_) => print('AuthBloc: User profile updated successfully'),
            );
          } catch (e) {
            print('AuthBloc: Error updating user profile: $e');
          }

          emit(Authenticated(user));
        },
      );
    } catch (e) {
      print('AuthBloc: Error during registration process: $e');
      emit(AuthError('Registration failed: $e'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authService.signOut();
    emit(const Unauthenticated());
  }

  Future<void> _onRefreshUserInfo(
    RefreshUserInfo event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('AuthBloc: Refreshing user info for user: ${event.userId}');

      // Lấy thông tin người dùng hiện tại
      final currentState = state;
      if (currentState is Authenticated) {
        // Lấy thông tin người dùng từ Firestore
        final userDoc = await _firestore.collection('users').doc(event.userId).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          print('AuthBloc: User role in Firestore: ${data['role']}');

          // Cập nhật thông tin người dùng trong UserBloc
          // Bằng cách gọi sự kiện LoadUserProfile
          // UserBloc sẽ tự động lấy thông tin người dùng từ Firestore
        }
      }
    } catch (e) {
      print('AuthBloc: Error refreshing user info: $e');
    }
  }

  Future<void> _onEnsureUserInFirestore(
    EnsureUserInFirestore event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('Ensuring user exists in Firestore: ${event.userId}');
      final userDoc = await _firestore.collection('users').doc(event.userId).get();

      if (!userDoc.exists) {
        print('AuthBloc: User document does not exist in Firestore, creating it');
        final userData = {
          'name': event.name ?? 'Người dùng',
          'email': event.email ?? '',
          'role': event.role,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('users').doc(event.userId).set(userData);
        print('AuthBloc: User document created successfully with role: ${event.role} and name: ${event.name}');
      } else {
        print('AuthBloc: User document already exists in Firestore');
        // Cập nhật thông tin người dùng
        final data = userDoc.data() as Map<String, dynamic>;
        final updates = <String, dynamic>{
          'updatedAt': Timestamp.now(),
        };

        // Cập nhật tên nếu có
        if (event.name != null && event.name!.isNotEmpty) {
          updates['name'] = event.name;
        }

        // Cập nhật email nếu có
        if (event.email != null && event.email!.isNotEmpty) {
          updates['email'] = event.email;
        }

        // Cập nhật vai trò
        if (!data.containsKey('role') || data['role'] == null || data['role'] == '' || data['role'] != event.role) {
          updates['role'] = event.role;
        }

        if (updates.length > 1) { // Nếu có thông tin cần cập nhật (ngoài updatedAt)
          await _firestore.collection('users').doc(event.userId).update(updates);
          print('AuthBloc: User information updated in Firestore: $updates');
        }
      }

      // Không cần emit state mới vì đây chỉ là thao tác ngầm
    } catch (e) {
      print('Error ensuring user in Firestore: $e');
      // Không emit lỗi để tránh ảnh hưởng đến luồng chính
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Sử dụng phương thức registerWithEmailAndPassword để đăng ký và lưu thông tin
      final result = await authService.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );

      await result.fold(
        (failure) async => emit(AuthError(failure.toString())),
        (user) async {
          print('AuthBloc: Registration successful in signUp, user: ${user.uid}');

          // Kiểm tra lại để đảm bảo thông tin đã được lưu vào Firestore
          try {
            final userDoc = await _firestore.collection('users').doc(user.uid).get();
            if (!userDoc.exists) {
              print('AuthBloc: User document still not found in Firestore, creating it directly in signUp');
              // Thử lại một lần nữa
              await _firestore.collection('users').doc(user.uid).set({
                'name': event.name,
                'email': event.email,
                'role': event.role,
                'createdAt': Timestamp.now(),
                'updatedAt': Timestamp.now(),
              }, SetOptions(merge: true));
              print('AuthBloc: User document created directly in signUp');
            } else {
              print('AuthBloc: User document exists in Firestore in signUp');
              final data = userDoc.data() as Map<String, dynamic>;
              print('AuthBloc: User role in Firestore in signUp: ${data['role']}');
            }
          } catch (e) {
            print('AuthBloc: Error checking user in Firestore in signUp: $e');
          }

          // Get the bronze badge
          try {
            final bronzeBadgeResult = await _badgeRepository.getBronzeBadge();

            await bronzeBadgeResult.fold(
              (failure) async {
                print('AuthBloc: Failed to get bronze badge: ${failure.toString()}');
                emit(Authenticated(user)); // Vẫn xác thực người dùng mặc dù không có huy hiệu
              },
              (bronzeBadge) async {
                try {
                  // Assign bronze badge to new user
                  await _badgeRepository.updateUserBadge(user.uid, bronzeBadge.id);
                  print('AuthBloc: Bronze badge assigned to user: ${user.uid}');
                  emit(Authenticated(user));
                } catch (e) {
                  print('AuthBloc: Error assigning bronze badge: $e');
                  emit(Authenticated(user)); // Vẫn xác thực người dùng mặc dù có lỗi
                }
              },
            );
          } catch (e) {
            print('AuthBloc: Error getting bronze badge: $e');
            emit(Authenticated(user)); // Vẫn xác thực người dùng mặc dù có lỗi
          }
        },
      );
    } catch (e) {
      print('AuthBloc: Error during signUp process: $e');
      emit(AuthError('Registration failed: $e'));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Handling ResetPasswordRequested event for email: ${event.email}');
    emit(const AuthLoading());

    try {
      final result = await authService.resetPassword(event.email);

      result.fold(
        (failure) {
          print('AuthBloc: Password reset failed: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (_) {
          print('AuthBloc: Password reset email sent successfully');
          emit(const PasswordResetEmailSent());
        },
      );
    } catch (e) {
      print('AuthBloc: Error during password reset process: $e');
      emit(AuthError('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
