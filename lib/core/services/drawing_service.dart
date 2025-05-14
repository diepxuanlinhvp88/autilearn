import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';
import '../../data/models/drawing_model.dart';
import '../../data/models/drawing_template_model.dart';
import '../constants/app_constants.dart';
import 'imgur_service.dart';

class DrawingService {
  final FirebaseFirestore _firestore;
  final ImgurService _imgurService;

  DrawingService({
    FirebaseFirestore? firestore,
    ImgurService? imgurService,
  }) :
    _firestore = firestore ?? FirebaseFirestore.instance,
    _imgurService = imgurService ?? ImgurService();

  // Lưu hình ảnh vẽ lên Imgur và cập nhật URL trong Firestore
  Future<Either<Failure, String>> saveDrawing({
    required GlobalKey key,
    required String drawingId,
    required String userId,
  }) async {
    try {
      // Sử dụng RepaintBoundary để chuyển đổi widget thành hình ảnh
      final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return Left(ServerFailure('Không thể chuyển đổi hình ảnh'));
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Lưu tạm thời vào bộ nhớ
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/drawing_$drawingId.png');
      await tempFile.writeAsBytes(pngBytes);

      // Tải lên Imgur
      final uploadResult = await _imgurService.uploadImage(tempFile);

      return uploadResult.fold(
        (error) => Left(ServerFailure(error)),
        (imageUrl) async {
          // Cập nhật URL trong Firestore
          await _firestore.collection('drawings').doc(drawingId).update({
            'imageUrl': imageUrl,
            'isCompleted': true,
            'updatedAt': Timestamp.now(),
          });

          return Right(imageUrl);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Tạo bài vẽ mới
  Future<Either<Failure, DrawingModel>> createDrawing({
    required String title,
    required String description,
    required String type,
    required String creatorId,
    String? templateId,
  }) async {
    try {
      final drawingData = {
        'title': title,
        'description': description,
        'type': type,
        'creatorId': creatorId,
        'templateId': templateId,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _firestore.collection('drawings').add(drawingData);
      final doc = await docRef.get();

      return Right(DrawingModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Lấy danh sách bài vẽ của người dùng
  Future<Either<Failure, List<DrawingModel>>> getUserDrawings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('drawings')
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final drawings = querySnapshot.docs
          .map((doc) => DrawingModel.fromFirestore(doc))
          .toList();

      return Right(drawings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Lấy thông tin bài vẽ theo ID
  Future<Either<Failure, DrawingModel>> getDrawingById(String drawingId) async {
    try {
      final doc = await _firestore.collection('drawings').doc(drawingId).get();

      if (!doc.exists) {
        return Left(ServerFailure('Không tìm thấy bài vẽ'));
      }

      return Right(DrawingModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Lấy danh sách mẫu vẽ
  Future<Either<Failure, List<DrawingTemplateModel>>> getDrawingTemplates({
    String? category,
    bool? isPublished,
  }) async {
    try {
      print('Fetching drawing templates with filters: category=$category, isPublished=$isPublished');

      // Tạo truy vấn cơ bản
      Query query = _firestore.collection('drawing_templates');

      // Thêm các điều kiện lọc
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (isPublished != null) {
        query = query.where('isPublished', isEqualTo: isPublished);
      }

      // Thực hiện truy vấn mà không sắp xếp để tránh lỗi index
      final querySnapshot = await query.get();

      print('Found ${querySnapshot.docs.length} drawing templates');

      // Sắp xếp kết quả trong bộ nhớ thay vì trong truy vấn
      final templates = querySnapshot.docs
          .map((doc) => DrawingTemplateModel.fromFirestore(doc))
          .toList();

      // Sắp xếp theo thời gian tạo giảm dần
      templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // In ra thông tin của mẫu đầu tiên để kiểm tra
      if (templates.isNotEmpty) {
        print('First template: ${templates.first.title}, imageUrl: ${templates.first.imageUrl}');
      }

      return Right(templates);
    } catch (e) {
      print('Error fetching drawing templates: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // Lấy thông tin mẫu vẽ theo ID
  Future<Either<Failure, DrawingTemplateModel>> getTemplateById(String templateId) async {
    try {
      final doc = await _firestore.collection('drawing_templates').doc(templateId).get();

      if (!doc.exists) {
        return Left(ServerFailure('Không tìm thấy mẫu vẽ'));
      }

      return Right(DrawingTemplateModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Tạo mẫu vẽ mới (dành cho giáo viên)
  Future<Either<Failure, DrawingTemplateModel>> createTemplate({
    required String title,
    required String description,
    required String imageUrl,
    required String outlineImageUrl,
    required String creatorId,
    required String category,
    required int difficulty,
    bool isPublished = false,
  }) async {
    try {
      final templateData = {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'outlineImageUrl': outlineImageUrl,
        'creatorId': creatorId,
        'category': category,
        'difficulty': difficulty,
        'isPublished': isPublished,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _firestore.collection('drawing_templates').add(templateData);
      final doc = await docRef.get();

      return Right(DrawingTemplateModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
