import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/routes.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_event.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../main.dart';

class ProfilePageSimple extends StatelessWidget {
  const ProfilePageSimple({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Hồ sơ của tôi'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                  ),
                ],
              ),
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Hình nền
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Untitled.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Thông tin người dùng
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.purple,
                          child: Text(
                            (state.user.displayName?.isNotEmpty ?? false)
                                ? state.user.displayName![0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.user.displayName ?? 'Người dùng',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.user.email ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phần tùy chọn
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tùy chọn',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phân tích học tập
                        _buildOptionCard(
                          context,
                          icon: Icons.analytics,
                          title: 'Phân tích học tập',
                          subtitle: 'Xem tiến độ và kết quả học tập',
                          onTap: () => Navigator.pushNamed(context, AppRouter.studentAnalytics),
                        ),

                        // Huy hiệu
                        _buildOptionCard(
                          context,
                          icon: Icons.emoji_events,
                          title: 'Huy hiệu',
                          subtitle: 'Xem các huy hiệu đã đạt được',
                          onTap: () => Navigator.pushNamed(context, AppRouter.badges),
                        ),

                        // Cửa hàng
                        _buildOptionCard(
                          context,
                          icon: Icons.shopping_cart,
                          title: 'Cửa hàng',
                          subtitle: 'Mua sắm phần thưởng và vật phẩm',
                          onTap: () => Navigator.pushNamed(context, AppRouter.rewardShop),
                        ),

                        // Tiến trình học tập
                        _buildOptionCard(
                          context,
                          icon: Icons.insights,
                          title: 'Tiến trình học tập',
                          subtitle: 'Xem quá trình học tập của bạn',
                          onTap: () => Navigator.pushNamed(context, AppRouter.progress),
                        ),

                        // Lịch học
                        _buildOptionCard(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Lịch học',
                          subtitle: 'Xem lịch học và nhắc nhở',
                          onTap: () => Navigator.pushNamed(context, AppRouter.calendar),
                        ),

                        // Trợ giúp
                        _buildOptionCard(
                          context,
                          icon: Icons.help_outline,
                          title: 'Trợ giúp',
                          subtitle: 'Hướng dẫn sử dụng ứng dụng',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tính năng đang phát triển')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Redirect to login page if not authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
