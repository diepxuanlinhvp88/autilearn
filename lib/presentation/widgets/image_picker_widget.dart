import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/image_upload_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageSelected;
  final Function() onImageRemoved;

  const ImagePickerWidget({
    Key? key,
    this.initialImageUrl,
    required this.onImageSelected,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  String? _imageUrl;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn nguồn ảnh'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Thư viện ảnh'),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: Colors.purple),
                        SizedBox(width: 10),
                        Text('Nhập URL ảnh'),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEnterUrlDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sử dụng service đã được cập nhật
      final File? pickedImage = await _imageUploadService.pickImage(source: source);

      if (pickedImage != null) {
        setState(() {
          _imageFile = pickedImage;
        });

        try {
          // Tải ảnh lên Firebase Storage
          final String? downloadUrl = await _imageUploadService.uploadImage(pickedImage);

          if (downloadUrl != null) {
            setState(() {
              _imageUrl = downloadUrl;
            });

            // Gọi callback để cập nhật URL ảnh
            widget.onImageSelected(downloadUrl);
          } else {
            // Nếu không thể tải lên Firebase Storage, hiển thị hộp thoại để nhập URL thủ công
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể tải ảnh lên Firebase Storage. Bạn có thể nhập URL ảnh thủ công.'),
                  duration: Duration(seconds: 5),
                ),
              );

              // Hiển thị hộp thoại để nhập URL thủ công
              await Future.delayed(const Duration(seconds: 1));
              _showEnterUrlDialog();
            }
          }
        } catch (e) {
          print('Error uploading image to Firebase Storage: $e');
          // Nếu có lỗi khi tải lên, hiển thị hộp thoại để nhập URL thủ công
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể tải ảnh lên Firebase Storage. Bạn có thể nhập URL ảnh thủ công.'),
                duration: Duration(seconds: 5),
              ),
            );

            // Hiển thị hộp thoại để nhập URL thủ công
            await Future.delayed(const Duration(seconds: 1));
            _showEnterUrlDialog();
          }
        }
      } else {
        // Nếu người dùng không chọn ảnh hoặc có lỗi khi chọn ảnh
        print('No image selected or error occurred');
      }
    } catch (e) {
      print('Error picking or uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi khi chọn hoặc tải ảnh lên. Vui lòng thử lại sau.'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  Future<void> _showEnterUrlDialog() async {
    String url = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController urlController = TextEditingController();

        return AlertDialog(
          title: const Text('Nhập URL hình ảnh'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/image.jpg',
              labelText: 'URL hình ảnh',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              url = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                url = urlController.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    // Sau khi hộp thoại đóng, kiểm tra URL và cập nhật nếu không rỗng
    if (url.isNotEmpty) {
      _setImageUrl(url);
    }
  }

  void _setImageUrl(String url) {
    setState(() {
      _imageUrl = url;
      _imageFile = null;
    });

    // Gọi callback để cập nhật URL ảnh
    widget.onImageSelected(url);
  }

  void _removeImage() {
    if (_imageUrl != null) {
      // Nếu có URL ảnh, xóa ảnh từ Firebase Storage
      if (_imageUrl!.startsWith('https://firebasestorage.googleapis.com')) {
        _imageUploadService.deleteImage(_imageUrl!);
      }

      setState(() {
        _imageUrl = null;
        _imageFile = null;
      });

      // Gọi callback để thông báo ảnh đã bị xóa
      widget.onImageRemoved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildImageContent(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.photo_library),
              label: Text(_imageUrl == null ? 'Chọn ảnh' : 'Thay đổi ảnh'),
            ),
            if (_imageUrl != null) ...[
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete),
                label: const Text('Xóa ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_imageFile != null) {
      // Hiển thị ảnh đã chọn từ thiết bị
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (_imageUrl != null) {
      // Hiển thị ảnh từ URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  const Text('Không thể tải ảnh'),
                  const SizedBox(height: 8),
                  Text('URL: ${_imageUrl!.substring(0, _imageUrl!.length > 30 ? 30 : _imageUrl!.length)}...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showEnterUrlDialog,
                    child: const Text('Sửa URL'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Hiển thị placeholder khi chưa có ảnh
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Chưa có ảnh'),
          ],
        ),
      );
    }
  }
}
