import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/firestore_error_handler.dart';

// Events
abstract class FirestoreErrorEvent extends Equatable {
  const FirestoreErrorEvent();

  @override
  List<Object?> get props => [];
}

class FirestoreErrorOccurred extends FirestoreErrorEvent {
  final dynamic error;

  const FirestoreErrorOccurred(this.error);

  @override
  List<Object?> get props => [error];
}

class FirestoreErrorHandled extends FirestoreErrorEvent {
  const FirestoreErrorHandled();
}

class CreateIndexRequested extends FirestoreErrorEvent {
  final String url;

  const CreateIndexRequested(this.url);

  @override
  List<Object?> get props => [url];
}

// States
abstract class FirestoreErrorState extends Equatable {
  const FirestoreErrorState();

  @override
  List<Object?> get props => [];
}

class FirestoreErrorInitial extends FirestoreErrorState {
  const FirestoreErrorInitial();
}

class FirestoreErrorLoading extends FirestoreErrorState {
  const FirestoreErrorLoading();
}

class FirestoreIndexError extends FirestoreErrorState {
  final String message;
  final String url;

  const FirestoreIndexError({
    required this.message,
    required this.url,
  });

  @override
  List<Object?> get props => [message, url];
}

class FirestoreGeneralError extends FirestoreErrorState {
  final String message;

  const FirestoreGeneralError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class FirestoreIndexCreating extends FirestoreErrorState {
  const FirestoreIndexCreating();
}

class FirestoreIndexCreated extends FirestoreErrorState {
  const FirestoreIndexCreated();
}

class FirestoreIndexCreationFailed extends FirestoreErrorState {
  final String message;

  const FirestoreIndexCreationFailed({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

// Bloc
class FirestoreErrorBloc extends Bloc<FirestoreErrorEvent, FirestoreErrorState> {
  FirestoreErrorBloc() : super(const FirestoreErrorInitial()) {
    on<FirestoreErrorOccurred>(_onFirestoreErrorOccurred);
    on<FirestoreErrorHandled>(_onFirestoreErrorHandled);
    on<CreateIndexRequested>(_onCreateIndexRequested);
  }

  void _onFirestoreErrorOccurred(
    FirestoreErrorOccurred event,
    Emitter<FirestoreErrorState> emit,
  ) {
    final error = event.error;

    if (error is DatabaseFailure && error.isMissingIndexError) {
      emit(FirestoreIndexError(
        message: FirestoreErrorHandler.getFriendlyErrorMessage(error),
        url: error.indexUrl!,
      ));
    } else {
      emit(FirestoreGeneralError(
        message: FirestoreErrorHandler.getFriendlyErrorMessage(error),
      ));
    }
  }

  void _onFirestoreErrorHandled(
    FirestoreErrorHandled event,
    Emitter<FirestoreErrorState> emit,
  ) {
    emit(const FirestoreErrorInitial());
  }

  Future<void> _onCreateIndexRequested(
    CreateIndexRequested event,
    Emitter<FirestoreErrorState> emit,
  ) async {
    emit(const FirestoreIndexCreating());

    try {
      final success = await FirestoreErrorHandler.openIndexUrl(event.url);
      if (success) {
        emit(const FirestoreIndexCreated());
      } else {
        await FirestoreErrorHandler.copyIndexUrlToClipboard(event.url);
        emit(const FirestoreIndexCreationFailed(
          message: 'Không thể mở URL. URL đã được sao chép vào clipboard.',
        ));
      }
    } catch (e) {
      emit(FirestoreIndexCreationFailed(
        message: 'Lỗi khi tạo index: $e',
      ));
    }
  }
}
