import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';
import 'firestore_error_handler.dart';

/// Lớp tiện ích để xử lý các truy vấn Firestore và bắt lỗi
class FirestoreQueryHelper {
  /// Thực hiện truy vấn Firestore và xử lý lỗi
  static Future<Either<Failure, T>> executeQuery<T>(
    Future<T> Function() query,
  ) async {
    try {
      final result = await query();
      return Right(result);
    } catch (e) {
      if (FirestoreErrorHandler.isMissingIndexError(e)) {
        // Trả về lỗi cụ thể cho việc thiếu index
        final indexUrl = FirestoreErrorHandler.extractIndexUrl(e);
        return Left(
          DatabaseFailure(
            'Cần tạo index cho truy vấn này. ${indexUrl != null ? 'URL: $indexUrl' : ''}',
            indexUrl: indexUrl,
          ),
        );
      }
      
      if (e is FirebaseException) {
        return Left(DatabaseFailure(e.message ?? 'Lỗi Firebase không xác định'));
      }
      
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
