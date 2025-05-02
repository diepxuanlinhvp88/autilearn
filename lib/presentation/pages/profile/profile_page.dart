import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_event.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../data/models/user_model.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Hồ sơ của tôi'),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      _showLogoutConfirmationDialog(context);
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              (state.user.displayName?.isNotEmpty ?? false)
                                  ? state.user.displayName![0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // User name
                          Text(
                            state.user.displayName ?? 'Người dùng',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // User email
                          Text(
                            state.user.email ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // User role text
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, userState) {
                              if (userState is UserInitial) {
                                context.read<UserBloc>().add(LoadUserProfile(state.user.uid));
                                return const SizedBox.shrink();
                              }

                              if (userState is UserProfileLoaded) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getRoleIcon(userState.user.role),
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vai trò: ${_getRoleName(userState.user.role)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: 16),
                          // User role badge
                          // Hiển thị vai trò người dùng từ UserBloc
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, userState) {
                              // Kích hoạt LoadUserProfile để cập nhật UserBloc
                              if (userState is UserInitial) {
                                context.read<UserBloc>().add(LoadUserProfile(state.user.uid));
                                return const CircularProgressIndicator(color: Colors.white);
                              }

                              if (userState is UserError) {
                                print('Error getting user profile: ${userState.message}');
                                return Text('Error: ${userState.message}', style: const TextStyle(color: Colors.white));
                              }

                              String role = AppConstants.roleStudent;
                              if (userState is UserProfileLoaded) {
                                role = userState.user.role;
                                print('User role from UserBloc: $role');
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getRoleIcon(role),
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getRoleName(role),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Stats section
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        // Trigger loading user stats
                        if (userState is UserInitial || userState is UserProfileLoaded) {
                          context.read<UserBloc>().add(LoadUserStats(state.user.uid));
                        }

                        // Default values
                        int createdQuizCount = 0;
                        int publishedQuizCount = 0;
                        int totalQuestions = 0;

                        // Update with actual values if available
                        if (userState is UserStatsLoaded) {
                          createdQuizCount = userState.createdQuizCount;
                          publishedQuizCount = userState.publishedQuizCount;
                          totalQuestions = userState.totalQuestions;
                        }

                        // Get user role to determine which stats to show
                        String role = AppConstants.roleStudent;
                        if (userState is UserProfileLoaded) {
                          role = userState.user.role;
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role == AppConstants.roleStudent ? 'Thống kê học tập' : 'Thống kê bài học',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (role == AppConstants.roleStudent)
                                // Student stats
                                Row(
                                  children: [
                                    _buildStatCard(
                                      icon: Icons.star,
                                      color: Colors.amber,
                                      title: 'Điểm số',
                                      value: '250',
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStatCard(
                                      icon: Icons.emoji_events,
                                      color: Colors.orange,
                                      title: 'Huy hiệu',
                                      value: '5',
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStatCard(
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                      title: 'Hoàn thành',
                                      value: '12',
                                    ),
                                  ],
                                )
                              else
                                // Teacher/Parent stats
                                Row(
                                  children: [
                                    _buildStatCard(
                                      icon: Icons.book,
                                      color: Colors.blue,
                                      title: 'Bài học',
                                      value: createdQuizCount.toString(),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStatCard(
                                      icon: Icons.publish,
                                      color: Colors.green,
                                      title: 'Đã xuất bản',
                                      value: publishedQuizCount.toString(),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildStatCard(
                                      icon: Icons.question_answer,
                                      color: Colors.orange,
                                      title: 'Câu hỏi',
                                      value: totalQuestions.toString(),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Menu section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, userState) {
                              // Get user role
                              String role = AppConstants.roleStudent;
                              if (userState is UserProfileLoaded) {
                                role = userState.user.role;
                              }

                              return Column(
                                children: [
                                  if (role == AppConstants.roleTeacher || role == AppConstants.roleParent)
                                    _buildMenuCard(
                                      icon: Icons.create,
                                      title: 'Quản lý bài học',
                                      subtitle: 'Tạo và quản lý bài học của bạn',
                                      onTap: () {
                                        Navigator.of(context).pushNamed(AppRouter.manageQuizzes);
                                      },
                                    ),
                                  if (role == AppConstants.roleTeacher || role == AppConstants.roleParent)
                                    const SizedBox(height: 12),
                                  _buildMenuCard(
                                    icon: Icons.emoji_events,
                                    title: 'Thành tích của tôi',
                                    subtitle: 'Xem các huy hiệu và thành tích',
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRouter.achievements);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildMenuCard(
                                    icon: Icons.insights,
                                    title: 'Tiến trình học tập',
                                    subtitle: 'Xem quá trình học tập của bạn',
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRouter.progress);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            icon: Icons.settings,
                            title: 'Cài đặt',
                            subtitle: 'Thay đổi cài đặt ứng dụng',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tính năng đang phát triển'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            icon: Icons.help_outline,
                            title: 'Trợ giúp',
                            subtitle: 'Hướng dẫn sử dụng ứng dụng',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tính năng đang phát triển'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // Redirect to login page if not authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleName(String roleKey) {
    switch (roleKey) {
      case AppConstants.roleParent:
        return 'Phụ huynh';
      case AppConstants.roleTeacher:
        return 'Giáo viên';
      case AppConstants.roleStudent:
        return 'Học sinh';
      default:
        return 'Người dùng';
    }
  }

  IconData _getRoleIcon(String roleKey) {
    switch (roleKey) {
      case AppConstants.roleParent:
        return Icons.family_restroom;
      case AppConstants.roleTeacher:
        return Icons.school;
      case AppConstants.roleStudent:
        return Icons.face;
      default:
        return Icons.person;
    }
  }

  // Phương thức lấy vai trò người dùng trực tiếp từ Firestore
  Future<String> _getUserRole(String userId) async {
    try {
      print('Getting user role for userId: $userId');
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        print('User document does not exist');
        return AppConstants.roleStudent;
      }

      final data = doc.data() as Map<String, dynamic>?;
      final role = data?['role'] as String? ?? AppConstants.roleStudent;
      print('User role from Firestore: $role');
      return role;
    } catch (e) {
      print('Error getting user role: $e');
      return AppConstants.roleStudent;
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
