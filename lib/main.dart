import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/repositories/comment_repository.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';
import 'package:withsave_frontend_test/model/repositories/user_repository.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';
import 'package:withsave_frontend_test/view/common/app_router.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';
import 'package:withsave_frontend_test/view_model/post_list_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiClient();
  final userRepo = UserRepository(api);
  final postRepo = PostRepository(api);
  final commentRepo = CommentRepository(api);
  final auth = AuthViewModel(userRepo);

  api.onUnauthorized = auth.onSessionExpired;
  await auth.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: postRepo),
        Provider.value(value: commentRepo),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(
          create: (context) => PostListViewModel(postRepo)..refresh(),
        ),
      ],
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = AppRouter(context.read<AuthViewModel>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '커뮤니티',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F5D50),
      ),
      routerConfig: _router,
    );
  }
}
