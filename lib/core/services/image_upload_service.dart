import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Chọn ảnh từ thư viện hoặc camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // Sử dụng cách tiếp cận khác để tránh lỗi kênh
      final result = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Giảm chất lượng ảnh để giảm kích thước
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      // Trả về null thay vì ném lại ngoại lệ
      return null;
    }
  }

  // Chọn ảnh từ camera
  Future<File?> pickImageFromCamera() async {
    return pickImage(source: ImageSource.camera);
  }



  // Tải ảnh lên Firebase Storage và trả về URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Tạo tên file duy nhất bằng UUID
      final String fileName = Uuid().v4();

      // Tham chiếu đến vị trí lưu trữ trên Firebase Storage
      final Reference ref = _storage.ref().child('question_images/$fileName.jpg');

      // Tải ảnh lên
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Đợi cho đến khi tải lên hoàn tất
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL tải xuống
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Xóa ảnh từ Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Lấy tham chiếu từ URL
      final Reference ref = _storage.refFromURL(imageUrl);

      // Xóa ảnh
      await ref.delete();

      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
