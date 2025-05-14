import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../presentation/blocs/firestore_error/firestore_error_bloc.dart';
import '../../../presentation/widgets/firestore_error_handler_widget.dart';

/// Trang ví dụ về cách sử dụng FirestoreErrorHandlerWidget
class FirestoreErrorExamplePage extends StatefulWidget {
  const FirestoreErrorExamplePage({Key? key}) : super(key: key);

  @override
  State<FirestoreErrorExamplePage> createState() => _FirestoreErrorExamplePageState();
}

class _FirestoreErrorExamplePageState extends State<FirestoreErrorExamplePage> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _indexUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví dụ về xử lý lỗi Firestore'),
      ),
      body: FirestoreErrorHandlerWidget(
        onRetry: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      // Khi có lỗi, FirestoreErrorHandlerWidget sẽ tự động hiển thị lỗi
      // Chúng ta cần thông báo cho FirestoreErrorBloc về lỗi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_indexUrl != null) {
          context.read<FirestoreErrorBloc>().add(
                FirestoreErrorOccurred(
                  DatabaseFailure(
                    _errorMessage,
                    indexUrl: _indexUrl,
                  ),
                ),
              );
        } else {
          context.read<FirestoreErrorBloc>().add(
                FirestoreErrorOccurred(
                  DatabaseFailure(_errorMessage),
                ),
              );
        }
      });
      
      // Trả về một container trống vì FirestoreErrorHandlerWidget sẽ hiển thị lỗi
      return Container();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nhấn nút bên dưới để mô phỏng lỗi Firestore',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _simulateIndexError,
            child: const Text('Mô phỏng lỗi thiếu index'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _simulateGeneralError,
            child: const Text('Mô phỏng lỗi thông thường'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Tải dữ liệu (không lỗi)'),
          ),
        ],
      ),
    );
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _indexUrl = null;
    });

    // Mô phỏng tải dữ liệu
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _simulateIndexError() {
    setState(() {
      _isLoading = true;
    });

    // Mô phỏng lỗi thiếu index
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Cần tạo index cho truy vấn này.';
          _indexUrl = 'https://console.firebase.google.com/project/autilearn-b095b/firestore/indexes?create_index=Cj8KHQoJcXVlc3Rpb25zEgVvcmRlciABEgVhc2NpaRoMCghxdWl6X2lkZBIACgkKBV9uYW1lEgIQARoMCghfX25hbWVfXxIAGgwKCF9fbmFtZV9fEgA';
        });
      }
    });
  }

  void _simulateGeneralError() {
    setState(() {
      _isLoading = true;
    });

    // Mô phỏng lỗi thông thường
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại sau.';
          _indexUrl = null;
        });
      }
    });
  }
}
