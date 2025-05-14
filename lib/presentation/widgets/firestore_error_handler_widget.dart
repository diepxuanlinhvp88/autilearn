import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/firestore_error/firestore_error_bloc.dart';

/// Widget để xử lý và hiển thị lỗi Firestore
class FirestoreErrorHandlerWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const FirestoreErrorHandlerWidget({
    Key? key,
    required this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FirestoreErrorBloc, FirestoreErrorState>(
      listener: (context, state) {
        if (state is FirestoreIndexCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã mở trang tạo index. Vui lòng tạo index và thử lại sau khi index được tạo.'),
              duration: Duration(seconds: 5),
            ),
          );
          context.read<FirestoreErrorBloc>().add(const FirestoreErrorHandled());
        } else if (state is FirestoreIndexCreationFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FirestoreIndexError) {
          return _buildIndexErrorWidget(context, state);
        } else if (state is FirestoreGeneralError) {
          return _buildGeneralErrorWidget(context, state);
        } else if (state is FirestoreIndexCreating) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return child;
      },
    );
  }

  Widget _buildIndexErrorWidget(BuildContext context, FirestoreIndexError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sau khi tạo index, có thể mất vài phút để hoàn tất. Vui lòng thử lại sau khi index được tạo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  OutlinedButton(
                    onPressed: () {
                      context.read<FirestoreErrorBloc>().add(const FirestoreErrorHandled());
                      onRetry!();
                    },
                    child: const Text('Thử lại'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FirestoreErrorBloc>().add(CreateIndexRequested(state.url));
                  },
                  child: const Text('Tạo index'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralErrorWidget(BuildContext context, FirestoreGeneralError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  context.read<FirestoreErrorBloc>().add(const FirestoreErrorHandled());
                  onRetry!();
                },
                child: const Text('Thử lại'),
              ),
          ],
        ),
      ),
    );
  }
}
