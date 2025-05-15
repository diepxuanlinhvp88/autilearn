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

  // Cập nhật URL hình ảnh
  await updateDrawingTemplatesUrls();

  // Kết thúc ứng dụng
  print('Hoàn thành cập nhật URL hình ảnh. Ứng dụng sẽ tự động đóng sau 3 giây.');
  await Future.delayed(const Duration(seconds: 3));
}

Future<void> updateDrawingTemplatesUrls() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  final User? currentUser = auth.currentUser;
  if (currentUser == null) {
    print('Lỗi: Không có người dùng nào đang đăng nhập');
    return;
  }

  final String userId = currentUser.uid;
  print('Đang cập nhật URL hình ảnh cho người dùng: $userId (${currentUser.email})');

  // Danh sách URL hình ảnh mới
  final Map<String, Map<String, String>> newUrls = {
    'Con mèo': {
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/1864/1864514.png',
      'outlineImageUrl': 'https://cdn-icons-png.flaticon.com/512/1864/1864514.png',
    },
    'Con chó': {
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/616/616408.png',
      'outlineImageUrl': 'https://cdn-icons-png.flaticon.com/512/616/616408.png',
    },
    'Bông hoa': {
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/1152/1152912.png',
      'outlineImageUrl': 'https://cdn-icons-png.flaticon.com/512/1152/1152912.png',
    },
    'Ngôi nhà': {
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/619/619034.png',
      'outlineImageUrl': 'https://cdn-icons-png.flaticon.com/512/619/619034.png',
    },
    'Xe ô tô': {
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
      'outlineImageUrl': 'https://cdn-icons-png.flaticon.com/512/741/741407.png',
    },
  };

  try {
    // Lấy tất cả mẫu tô màu
    final templatesSnapshot = await firestore.collection('drawing_templates').get();
    
    if (templatesSnapshot.docs.isEmpty) {
      print('Không có mẫu tô màu nào trong cơ sở dữ liệu.');
      return;
    }
    
    print('Đã tìm thấy ${templatesSnapshot.docs.length} mẫu tô màu.');
    
    // Cập nhật URL hình ảnh cho từng mẫu
    int updatedCount = 0;
    for (final doc in templatesSnapshot.docs) {
      final data = doc.data();
      final title = data['title'] as String;
      
      if (newUrls.containsKey(title)) {
        await firestore.collection('drawing_templates').doc(doc.id).update({
          'imageUrl': newUrls[title]!['imageUrl'],
          'outlineImageUrl': newUrls[title]!['outlineImageUrl'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updatedCount++;
        print('Đã cập nhật URL hình ảnh cho mẫu: $title');
      }
    }
    
    print('Đã cập nhật URL hình ảnh cho $updatedCount mẫu tô màu.');
  } catch (e) {
    print('Lỗi khi cập nhật URL hình ảnh: $e');
  }
}
