import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseDataSource _firebaseDataSource;

  UserRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  Future<Either<String, UserModel>> getUserById(String userId) async {
    return _firebaseDataSource.getUserById(userId);
  }

  Future<Either<String, bool>> updateUser(UserModel user) async {
    return _firebaseDataSource.updateUser(user);
  }
}
