import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Tạo dữ liệu mẫu
  await createDrawingTemplates();

  // Kết thúc ứng dụng
  print('Hoàn thành tạo mẫu tô màu. Ứng dụng sẽ tự động đóng sau 3 giây.');
  await Future.delayed(const Duration(seconds: 3));
}

Future<void> createDrawingTemplates() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  final User? currentUser = auth.currentUser;
  if (currentUser == null) {
    print('Lỗi: Không có người dùng nào đang đăng nhập');
    return;
  }

  final String userId = currentUser.uid;
  print('Đang tạo mẫu tô màu cho người dùng: $userId (${currentUser.email})');

  // Danh sách mẫu tô màu
  final List<Map<String, dynamic>> templates = [
    {
      'title': 'Con mèo',
      'description': 'Tô màu hình con mèo dễ thương',
      'imageUrl': 'https://i.imgur.com/JXK8H81.png',
      'outlineImageUrl': 'https://i.imgur.com/JXK8H81.png',
      'category': 'Động vật',
      'difficulty': 1,
      'isPublished': true,
    },
    {
      'title': 'Con chó',
      'description': 'Tô màu hình con chó đáng yêu',
      'imageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'outlineImageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'category': 'Động vật',
      'difficulty': 1,
      'isPublished': true,
    },
    {
      'title': 'Bông hoa',
      'description': 'Tô màu hình bông hoa xinh đẹp',
      'imageUrl': 'https://i.imgur.com/pKVJYf2.png',
      'outlineImageUrl': 'https://i.imgur.com/pKVJYf2.png',
      'category': 'Thực vật',
      'difficulty': 2,
      'isPublished': true,
    },
    {
      'title': 'Ngôi nhà',
      'description': 'Tô màu hình ngôi nhà nhỏ',
      'imageUrl': 'https://i.imgur.com/QFjYjZQ.png',
      'outlineImageUrl': 'https://i.imgur.com/QFjYjZQ.png',
      'category': 'Kiến trúc',
      'difficulty': 2,
      'isPublished': true,
    },
    {
      'title': 'Xe ô tô',
      'description': 'Tô màu hình chiếc xe ô tô',
      'imageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'outlineImageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'category': 'Phương tiện',
      'difficulty': 3,
      'isPublished': true,
    },
  ];

  try {
    // Kiểm tra xem đã có mẫu tô màu nào chưa
    final existingTemplates = await firestore.collection('drawing_templates').get();
    
    if (existingTemplates.docs.isNotEmpty) {
      print('Đã có ${existingTemplates.docs.length} mẫu tô màu trong cơ sở dữ liệu.');
      print('Bạn có muốn xóa và tạo lại không? (y/n)');
      
      // Tự động xóa và tạo lại
      print('Tự động xóa và tạo lại...');
      
      // Xóa tất cả mẫu tô màu hiện có
      for (final doc in existingTemplates.docs) {
        await firestore.collection('drawing_templates').doc(doc.id).delete();
      }
      
      print('Đã xóa ${existingTemplates.docs.length} mẫu tô màu.');
    }
    
    // Tạo mẫu tô màu mới
    for (final template in templates) {
      await firestore.collection('drawing_templates').add({
        ...template,
        'creatorId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    print('Đã tạo ${templates.length} mẫu tô màu thành công!');
  } catch (e) {
    print('Lỗi khi tạo mẫu tô màu: $e');
  }
}
