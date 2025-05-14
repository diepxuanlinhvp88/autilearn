// import 'package:flutter/material.dart';
// import '../core/utils/badge_uploader.dart';
// import '../core/services/badge_service.dart';
// import 'package:get_it/get_it.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeFirebase();
//   runApp(const BadgeUploadApp());
// }
//
// Future<void> initializeFirebase() async {
//   // Initialize Firebase if needed
// }
//
// class BadgeUploadApp extends StatelessWidget {
//   const BadgeUploadApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BadgeUploadScreen(),
//     );
//   }
// }
//
// class BadgeUploadScreen extends StatefulWidget {
//   @override
//   State<BadgeUploadScreen> createState() => _BadgeUploadScreenState();
// }
//
// class _BadgeUploadScreenState extends State<BadgeUploadScreen> {
//   final BadgeUploader _uploader = BadgeUploader();
//   final BadgeService _badgeService = GetIt.instance<BadgeService>();
//   Map<String, String> _uploadedUrls = {};
//   String _status = 'Sẵn sàng để upload';
//   bool _isUploading = false;
//
//   Future<void> _uploadBadges() async {
//     if (_isUploading) return;
//
//     setState(() {
//       _isUploading = true;
//       _status = 'Đang tạo và upload huy hiệu...';
//     });
//
//     try {
//       final urls = await _uploader.uploadAllBadges();
//       setState(() {
//         _uploadedUrls = urls;
//         _status = 'Upload thành công!';
//       });
//
//       // Cập nhật URLs trong Firestore
//       await _badgeService.updateBadgeUrls(urls);
//       setState(() {
//         _status = 'Đã cập nhật URLs trong cơ sở dữ liệu!';
//       });
//     } catch (e) {
//       setState(() {
//         _status = 'Lỗi: $e';
//       });
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Huy Hiệu'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Trạng thái: $_status',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 20),
//             if (_isUploading)
//               const CircularProgressIndicator()
//             else
//               ElevatedButton(
//                 onPressed: _uploadBadges,
//                 child: const Text('Bắt đầu Upload'),
//               ),
//             const SizedBox(height: 20),
//             if (_uploadedUrls.isNotEmpty) ...[
//               Text(
//                 'URLs đã upload:',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _uploadedUrls.length,
//                   itemBuilder: (context, index) {
//                     final entry = _uploadedUrls.entries.elementAt(index);
//                     return ListTile(
//                       title: Text(entry.key),
//                       subtitle: Text(entry.value),
//                       leading: Image.network(
//                         entry.value,
//                         width: 50,
//                         height: 50,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Icon(Icons.error),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }