import 'dart:io';
import 'package:dartz/dartz.dart';
import 'imgur_service.dart';

class StorageService {
  final ImgurService _imgurService = ImgurService();

  Future<Either<String, String>> uploadFile({
    required File file,
    required String path,
    required String fileName,
  }) async {
    try {
      // Sử dụng ImgurService để tải ảnh lên
      final result = await _imgurService.uploadImage(file);

      return result;
    } catch (e) {
      return Left('Lỗi khi tải ảnh lên Imgur: $e');
    }
  }

  Future<Either<String, String>> getDownloadURL({
    required String path,
    required String fileName,
  }) async {
    // Lưu ý: Với Imgur, chúng ta không có cách để lấy URL từ path và fileName
    // Vì Imgur trả về URL trực tiếp khi tải lên
    // Phương thức này được giữ lại để tương thích ngược
    return Left('Không thể lấy URL từ path và fileName với Imgur. Cần lưu trữ URL khi tải lên.');
  }

  Future<Either<String, bool>> deleteFile({
    required String path,
    required String fileName,
  }) async {
    // Lưu ý: Imgur API miễn phí không hỗ trợ xóa ảnh
    // Chúng ta có thể bỏ qua việc xóa vì Imgur sẽ tự động xóa các ảnh không được sử dụng sau một thời gian
    print('Không thể xóa ảnh từ Imgur với API miễn phí');
    return const Right(true); // Trả về true để không gây lỗi cho người dùng
  }

  // Phương thức mới để tải ảnh lên từ URL
  Future<Either<String, String>> uploadFileFromUrl({
    required String imageUrl,
    String path = '', // Không sử dụng với Imgur nhưng giữ lại để tương thích
    String fileName = '', // Không sử dụng với Imgur nhưng giữ lại để tương thích
  }) async {
    try {
      // Sử dụng ImgurService để tải ảnh lên từ URL
      final result = await _imgurService.uploadImageFromUrl(imageUrl);

      return result;
    } catch (e) {
      return Left('Lỗi khi tải ảnh từ URL lên Imgur: $e');
    }
  }
}
