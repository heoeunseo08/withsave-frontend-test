import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:withsave_frontend_test/view/detail_post_screen.dart';
import 'package:withsave_frontend_test/view/edit_post_screen.dart';
import 'package:withsave_frontend_test/view/home_screen.dart';
import 'package:withsave_frontend_test/view/login_screen.dart';
import 'package:withsave_frontend_test/view/profile_screen.dart';
import 'package:withsave_frontend_test/view/signup_screen.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String add_post = '/add_post';

  static String edit_post(int id) => '/edit_post/$id';

  static String detail_post(int id) => '/detail_post/$id';
}

GoRouter AppRouter(AuthViewModel auth) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.add_post,
        builder: (context, state) => const EditPostScreen(),
      ),
      GoRoute(
        path: '/detail_post/:id',
        redirect: _homeIfBadId,
        builder: (context, state) =>
            DetailPostScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/edit_post/:id',
        redirect: _homeIfBadId,
        builder: (context, state) =>
            EditPostScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
}

// 주소에 숫자가 아닌 id가 들어오면 오류 화면 대신 홈으로 보낸다.
String? _homeIfBadId(BuildContext context, GoRouterState state) =>
    int.tryParse(state.pathParameters['id']!) == null ? AppRoutes.home : null;
