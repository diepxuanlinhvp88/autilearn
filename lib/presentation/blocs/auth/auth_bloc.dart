import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription<dynamic>? _authStateSubscription;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc({required this.authService}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<EnsureUserInFirestore>(_onEnsureUserInFirestore);
    on<RefreshUserInfo>(_onRefreshUserInfo);

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
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authService.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) async {
        // Lấy thông tin người dùng từ Firestore
        try {
          print('AuthBloc: Getting user info from Firestore for user: ${user.uid}');
          final userDoc = await _firestore.collection('users').doc(user.uid).get();

          if (!userDoc.exists) {
            print('AuthBloc: User document does not exist in Firestore, creating it');
            // Tạo mới người dùng trong Firestore nếu chưa tồn tại
            await _firestore.collection('users').doc(user.uid).set({
              'name': user.displayName ?? 'Người dùng',
              'email': user.email ?? '',
              'role': AppConstants.roleStudent, // Mặc định là học sinh
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
            });
          } else {
            print('AuthBloc: User document exists in Firestore');
            // Cập nhật thông tin người dùng trong Firestore nếu cần
            final data = userDoc.data() as Map<String, dynamic>;
            print('AuthBloc: User role in Firestore: ${data['role']}');

            // Cập nhật thông tin người dùng trong UserBloc
            // Để đảm bảo UserBloc có thông tin mới nhất
            add(RefreshUserInfo(user.uid));
          }
        } catch (e) {
          print('AuthBloc: Error getting user info from Firestore: $e');
        }

        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Handling RegisterRequested event');
    emit(const AuthLoading());
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
      (user) {
        print('AuthBloc: Registration successful, user: ${user.uid}, role: ${event.role}');

        // Thông tin người dùng đã được lưu vào Firestore trong AuthService
        // Kiểm tra lại để đảm bảo
        _firestore.collection('users').doc(user.uid).get().then((doc) {
          if (!doc.exists) {
            print('AuthBloc: User document not found in Firestore, creating it');
            _firestore.collection('users').doc(user.uid).set({
              'name': event.name,
              'email': event.email,
              'role': event.role,
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
            });
          } else {
            print('AuthBloc: User document exists in Firestore');
            final data = doc.data() as Map<String, dynamic>;
            print('AuthBloc: User role in Firestore: ${data['role']}');
          }
        });

        emit(Authenticated(user));
      },
    );
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

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
