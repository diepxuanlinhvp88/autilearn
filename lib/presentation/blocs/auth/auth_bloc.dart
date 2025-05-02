import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      (user) => emit(Authenticated(user)),
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

  Future<void> _onEnsureUserInFirestore(
    EnsureUserInFirestore event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('Ensuring user exists in Firestore: ${event.userId}');
      final userDoc = await _firestore.collection('users').doc(event.userId).get();

      if (!userDoc.exists) {
        print('User document does not exist in Firestore, creating it');
        final userData = {
          'name': event.name ?? 'Người dùng',
          'email': event.email ?? '',
          'role': event.role,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('users').doc(event.userId).set(userData);
        print('User document created successfully with role: ${event.role}');
      } else {
        print('User document already exists in Firestore');
        // Kiểm tra xem có cần cập nhật vai trò không
        final data = userDoc.data() as Map<String, dynamic>;
        if (!data.containsKey('role') || data['role'] == null || data['role'] == '') {
          print('Updating user role in Firestore');
          await _firestore.collection('users').doc(event.userId).update({
            'role': event.role,
            'updatedAt': Timestamp.now(),
          });
          print('User role updated to: ${event.role}');
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
