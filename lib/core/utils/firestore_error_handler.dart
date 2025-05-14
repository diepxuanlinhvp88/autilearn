import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lớp xử lý lỗi Firestore, đặc biệt là lỗi liên quan đến index
class FirestoreErrorHandler {
  /// Kiểm tra xem lỗi có phải là lỗi thiếu index không
  static bool isMissingIndexError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'failed-precondition' && 
             error.message != null && 
             error.message!.contains('index');
    }
    return false;
  }

  /// Trích xuất URL tạo index từ thông báo lỗi
  static String? extractIndexUrl(dynamic error) {
    if (!isMissingIndexError(error)) return null;
    
    final errorMessage = (error as FirebaseException).message ?? '';
    
    // Tìm URL trong thông báo lỗi
    final RegExp urlRegex = RegExp(
      r'https:\/\/console\.firebase\.google\.com\/project\/[^\/]+\/firestore\/indexes\?create_index=(?:[a-zA-Z0-9_\-\.~%]|&amp;)+',
      caseSensitive: false,
    );
    
    final match = urlRegex.firstMatch(errorMessage);
    if (match != null) {
      String url = match.group(0)!;
      // Thay thế &amp; bằng & nếu cần
      url = url.replaceAll('&amp;', '&');
      return url;
    }
    
    return null;
  }

  /// Mở URL tạo index trong trình duyệt
  static Future<bool> openIndexUrl(String url) async {
    final Uri uri = Uri.parse(url);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Sao chép URL vào clipboard
  static Future<void> copyIndexUrlToClipboard(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
  }

  /// Hiển thị thông báo lỗi thân thiện với người dùng
  static String getFriendlyErrorMessage(dynamic error) {
    if (isMissingIndexError(error)) {
      return 'Cần tạo index cho truy vấn này. Bạn có thể nhấn nút bên dưới để tạo index tự động.';
    }
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Bạn không có quyền truy cập dữ liệu này.';
        case 'unavailable':
          return 'Dịch vụ Firebase hiện không khả dụng. Vui lòng thử lại sau.';
        case 'not-found':
          return 'Không tìm thấy dữ liệu yêu cầu.';
        default:
          return 'Đã xảy ra lỗi: ${error.message}';
      }
    }
    
    return 'Đã xảy ra lỗi không xác định: $error';
  }
}
