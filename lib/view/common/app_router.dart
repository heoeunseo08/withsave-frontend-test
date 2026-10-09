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
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final needsLogin = path == AppRoutes.add_post ||
          path == AppRoutes.profile || path.startsWith('/edit_post');

      if(!auth.isLogin && needsLogin){
        return '${AppRoutes.login}?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if(auth.isLogin && (path == AppRoutes.login || path == AppRoutes.signup)){
        return state.uri.queryParameters['from'] ?? AppRoutes.home;
      }
      return null;
    },
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
        builder: (context, state) =>
            DetailPostScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/edit_post/:id',
        builder: (context, state) =>
            EditPostScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
}
