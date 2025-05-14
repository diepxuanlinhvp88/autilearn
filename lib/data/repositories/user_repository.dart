import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/user_model.dart';
import '../../core/error/failures.dart';

class UserRepository {
  final FirebaseDataSource _firebaseDataSource;

  UserRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  Future<Either<Failure, UserModel>> getUserById(String userId) async {
    return _firebaseDataSource.getUserById(userId);
  }

  Future<Either<Failure, bool>> updateUser(UserModel user) async {
    return _firebaseDataSource.updateUser(user);
  }
}
