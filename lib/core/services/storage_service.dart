import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Either<String, String>> uploadFile({
    required File file,
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return Right(downloadUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> getDownloadURL({
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final downloadUrl = await ref.getDownloadURL();
      return Right(downloadUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> deleteFile({
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      await ref.delete();
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
