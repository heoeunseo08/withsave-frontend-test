import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_model/auth_view_model.dart';
import 'common/app_router.dart';
import 'common/message.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _emailChecked = false;
  bool _nicknameChecked = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    return Scaffold(
      body: Column(
        spacing: 24,
        mainAxisAlignment: .center,
        children: [
          SizedBox(width: MediaQuery.widthOf(context)),
          Text("회원가입", style: TextStyle(fontSize: 24)),
          signupBox(authVM),
          Row(
            mainAxisAlignment: .center,
            children: [
              Text("이미 회원가입하셨다면?  "),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  "로그인 하러가기",
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

  Future<bool> _check(Future<bool> Function() isTaken, String label) async {
    try {
      final taken = await isTaken();
      if (!mounted) return false;
      showMessage(context, taken ? "이미 가입된 $label입니다." : "사용가능한 $label입니다.");
      return !taken;
    } catch (e) {
      if (mounted) showMessage(context, e.toString());
      return false;
    }
  }

  Widget signupBox(AuthViewModel authVM) {
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
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  onChanged: (_) => setState(() => _emailChecked = false),
                  decoration: InputDecoration(
                    hintText: 'email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    showMessage(context, "이메일을 입력해주세요.");
                    return;
                  }
                  final ok = await _check(() => authVM.isCheckEmail(email), "이메일");
                  if (mounted) setState(() => _emailChecked = ok);
                },
                child: Text(_emailChecked ? "확인 완료" : "중복 확인"),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nicknameController,
                  onChanged: (_) => setState(() => _nicknameChecked = false),
                  decoration: InputDecoration(
                    hintText: 'nickname',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final nickname = _nicknameController.text.trim();
                  if (nickname.isEmpty) {
                    showMessage(context, "닉네임을 입력해주세요.");
                    return;
                  }
                  final ok = await _check(() => authVM.isCheckNickname(nickname), "닉네임");
                  if (mounted) setState(() => _nicknameChecked = ok);
                },
                child: Text(_nicknameChecked ? "확인 완료" : "중복 확인"),
              ),
            ],
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
            onPressed: authVM.isLoading
                ? null
                : () async {
              final nickname = _nicknameController.text.trim();
              final email = _emailController.text.trim();
              final password = _passwordController.text;

              if (email.isEmpty || nickname.isEmpty || password.isEmpty) {
                showMessage(context, "email, nickname, password를 모두 입력해주세요.");
                return;
              }
              if (!_emailChecked || !_nicknameChecked) {
                showMessage(context, "email과 nickname 중복 확인을 해주세요.");
                return;
              }

              final status = await authVM.signup(
                email: email,
                nickname: nickname,
                password: password,
              );
              if (!mounted) return;
              if (status) {
                showMessage(context, "회원가입이 완료되었습니다.");
                context.canPop() ? context.pop(true) : context.go(AppRoutes.home);
              } else {
                showMessage(context, authVM.error ?? "회원가입에 실패 하셨습니다.");
              }
            },
            child: Text("회원가입"),
          ),
        ],
      ),
    );
  }
}