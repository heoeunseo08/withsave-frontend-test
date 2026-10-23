import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/view/common/message.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';

import 'common/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Column(
        spacing: 24,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          SizedBox(width: MediaQuery.widthOf(context)),
          Text(
            "Frontend Test login",
            style: TextStyle(fontSize: 24),
          ),
          loginBox(authVM),
          Row(
            mainAxisAlignment: .center,
            children: [
              Text("아직 회원가입 안 하셨다면?  "),
              TextButton(
                onPressed: () async {
                  final signedUp = await context.push<bool>(AppRoutes.signup);
                  // 회원가입하면 이미 로그인된 상태이므로 로그인 화면도 함께 닫는다.
                  if (signedUp == true && mounted) _close();
                },
                child: Text(
                  "회원가입 하러가기",
                  style: TextStyle(
                    color: Color(0xFF2F5D50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 주소로 바로 들어와 돌아갈 화면이 없으면 홈으로 보낸다.
  void _close() => context.canPop() ? context.pop() : context.go(AppRoutes.home);

  Widget loginBox(AuthViewModel authVM) {
    return Container(
      width: 800,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        spacing: 24,
        children: [
          TextFormField(
            controller: _nicknameController,
            decoration: InputDecoration(
              hintText: 'nickname',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: authVM.isLoading ? null : () async {
              final nickname = _nicknameController.text.trim();
              final password = _passwordController.text;

              if (nickname.isEmpty || password.isEmpty) {
                showMessage(context, "nickname이나 password를 입력해주세요.");
                return;
              }

              final success = await authVM.login(
                nickname: nickname,
                password: password,
              );
              if (!mounted) return;
              if (success) {
                showMessage(context, "로그인되었습니다.");
                _close();
              } else {
                showMessage(context, authVM.error ?? "로그인에 실패 하셨습니다.");
                return;
              }
            },
            child: Text("로그인"),
          ),
        ],
      ),
    );
  }
}
