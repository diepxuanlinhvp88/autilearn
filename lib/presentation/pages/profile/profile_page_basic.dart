import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_event.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../main.dart';

class ProfilePageBasic extends StatelessWidget {
  const ProfilePageBasic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 2, // Index for profile tab
              onTap: (index) {
                if (index != 2) { // If not profile tab
                  Navigator.of(context).pop();
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Bài học',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Hồ sơ',
                ),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.purple,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Hồ sơ của tôi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Hình nền
                        Image.asset(
                          'assets/images/Untitled.png',
                          fit: BoxFit.cover,
                        ),
                        // Lớp phủ gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        context.read<AuthBloc>().add(const SignOutRequested());
                      },
                    ),
                  ],
                ),

                // Thông tin người dùng
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -40),
                    child: Container(
                      padding: const EdgeInsets.only(top: 0),
                      child: Column(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 47,
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
                          ),
                          const SizedBox(height: 16),
                          // Tên người dùng
                          Text(
                            state.user.displayName ?? 'Người dùng',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Email
                          Text(
                            state.user.email ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Vai trò
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Giáo viên',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Phần tùy chọn
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề phần
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: const Text(
                            'Tùy chọn',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),

                        // Phân tích học tập
                        _buildOptionCard(
                          context,
                          icon: Icons.analytics,
                          title: 'Phân tích học tập',
                          subtitle: 'Xem tiến độ và kết quả học tập',
                          color: Colors.blue,
                          onTap: () => Navigator.pushNamed(context, AppRouter.studentAnalytics),
                        ),

                        // Huy hiệu
                        _buildOptionCard(
                          context,
                          icon: Icons.emoji_events,
                          title: 'Huy hiệu',
                          subtitle: 'Xem các huy hiệu đã đạt được',
                          color: Colors.amber,
                          onTap: () => Navigator.pushNamed(context, AppRouter.badges),
                        ),

                        // Cửa hàng
                        _buildOptionCard(
                          context,
                          icon: Icons.shopping_cart,
                          title: 'Cửa hàng',
                          subtitle: 'Mua sắm phần thưởng và vật phẩm',
                          color: Colors.green,
                          onTap: () => Navigator.pushNamed(context, AppRouter.rewardShop),
                        ),

                        // Tiêu đề phần
                        Container(
                          margin: const EdgeInsets.only(top: 24, bottom: 16),
                          child: const Text(
                            'Khác',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),

                        // Trợ giúp
                        _buildOptionCard(
                          context,
                          icon: Icons.help_outline,
                          title: 'Trợ giúp',
                          subtitle: 'Hướng dẫn sử dụng ứng dụng',
                          color: Colors.teal,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tính năng đang phát triển')),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Hiển thị màn hình loading hoặc chuyển hướng đến trang đăng nhập
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(subtitle),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
