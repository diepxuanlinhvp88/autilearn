import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/user/user_bloc.dart';

/// Widget để truyền các BLoC từ trang chính vào các trang con
class BlocWrapper extends StatelessWidget {
  final Widget child;

  const BlocWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy các BLoC từ trang chính
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final quizBloc = BlocProvider.of<QuizBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    // Truyền các BLoC vào trang con
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: quizBloc),
        BlocProvider.value(value: userBloc),
      ],
      child: child,
    );
  }
}
