import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';

class ImgurService {
  // Imgur API client ID - bạn cần đăng ký và lấy client ID từ Imgur
  // https://api.imgur.com/oauth2/addclient
  static const String clientId = '575114ce1d1b262'; // Thay thế bằng client ID của bạn
  static const String apiUrl = 'https://api.imgur.com/3/image';

  // Tải ảnh lên Imgur và trả về URL
  Future<Either<String, String>> uploadImage(File imageFile) async {
    try {
      // Đọc file ảnh dưới dạng bytes
      final List<int> imageBytes = await imageFile.readAsBytes();
      
      // Mã hóa bytes thành base64
      final String base64Image = base64Encode(imageBytes);
      
      // Tạo request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Client-ID $clientId',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
          'type': 'base64',
        }),
      );
      
      // Kiểm tra response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // Lấy URL của ảnh đã tải lên
          final String imageUrl = responseData['data']['link'];
          print('ImgurService: Image uploaded successfully. URL: $imageUrl');
          return Right(imageUrl);
        } else {
          print('ImgurService: Upload failed. Response: ${response.body}');
          return Left('Không thể tải ảnh lên Imgur: ${responseData['data']['error']}');
        }
      } else {
        print('ImgurService: Upload failed. Status code: ${response.statusCode}, Response: ${response.body}');
        return Left('Không thể tải ảnh lên Imgur. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('ImgurService: Error uploading image: $e');
      return Left('Lỗi khi tải ảnh lên Imgur: $e');
    }
  }

  // Tải ảnh lên Imgur từ URL và trả về URL mới
  Future<Either<String, String>> uploadImageFromUrl(String imageUrl) async {
    try {
      // Tạo request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Client-ID $clientId',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': imageUrl,
          'type': 'url',
        }),
      );
      
      // Kiểm tra response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // Lấy URL của ảnh đã tải lên
          final String newImageUrl = responseData['data']['link'];
          print('ImgurService: Image uploaded from URL successfully. New URL: $newImageUrl');
          return Right(newImageUrl);
        } else {
          print('ImgurService: Upload from URL failed. Response: ${response.body}');
          return Left('Không thể tải ảnh từ URL lên Imgur: ${responseData['data']['error']}');
        }
      } else {
        print('ImgurService: Upload from URL failed. Status code: ${response.statusCode}, Response: ${response.body}');
        return Left('Không thể tải ảnh từ URL lên Imgur. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('ImgurService: Error uploading image from URL: $e');
      return Left('Lỗi khi tải ảnh từ URL lên Imgur: $e');
    }
  }

  // Kiểm tra xem URL có phải là URL Imgur không
  bool isImgurUrl(String url) {
    return url.contains('imgur.com') || url.contains('i.imgur.com');
  }
}
