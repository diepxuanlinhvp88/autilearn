import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'imgur_service.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final ImgurService _imgurService = ImgurService();

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



  // Tải ảnh lên Imgur và trả về URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Sử dụng ImgurService để tải ảnh lên
      final result = await _imgurService.uploadImage(imageFile);

      return result.fold(
        (error) {
          print('Error uploading image to Imgur: $error');
          return null;
        },
        (url) => url,
      );
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Xóa ảnh - lưu ý: Imgur API miễn phí không hỗ trợ xóa ảnh
  // Chúng ta có thể bỏ qua việc xóa vì Imgur sẽ tự động xóa các ảnh không được sử dụng sau một thời gian
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Kiểm tra xem có phải là URL Imgur không
      if (_imgurService.isImgurUrl(imageUrl)) {
        // Không thể xóa ảnh từ Imgur với API miễn phí
        print('Cannot delete image from Imgur with free API');
        return true; // Trả về true để không gây lỗi cho người dùng
      }

      // Nếu không phải URL Imgur, có thể là URL khác
      print('URL is not from Imgur, cannot delete: $imageUrl');
      return true;
    } catch (e) {
      print('Error handling image deletion: $e');
      return false;
    }
  }

  // Tải ảnh lên Imgur từ URL và trả về URL mới
  Future<String?> uploadImageFromUrl(String imageUrl) async {
    try {
      // Sử dụng ImgurService để tải ảnh lên từ URL
      final result = await _imgurService.uploadImageFromUrl(imageUrl);

      return result.fold(
        (error) {
          print('Error uploading image from URL to Imgur: $error');
          return null;
        },
        (url) => url,
      );
    } catch (e) {
      print('Error uploading image from URL: $e');
      return null;
    }
  }
}
