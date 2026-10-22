import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/view/common/need_login.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';

import 'common/app_router.dart';
import 'common/message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Align(alignment: .centerStart, child: Text("프로필 페이지")),
      ),
      body: !authVM.isLogin
          ? NeedLogin.needLoginWidget(context)
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
        child: Column(
          spacing: 12,
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'nickname : ${authVM.user!.nickname}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => editPopup(authVM),
                  child: Text("수정하기"),
                ),
              ],
            ),
            Text(
              'email : ${authVM.user!.email}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('createdAt : ${formatDate(authVM.user!.createdAt)}'),
            if (authVM.user!.updatedAt != null)
              Text("updatedAt : ${formatDate(authVM.user!.updatedAt!)}"),
            const Spacer(), // 아래 버튼들을 화면 맨 아래로
            Align(
              alignment: .centerRight,
              child: Column(
                crossAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: () => logoutPopup(authVM),
                    child: Text(
                      "로그아웃",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () => deletePopup(authVM),
                    child: Text(
                      "계정 삭제",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void editPopup(AuthViewModel authVM) {
    _nicknameController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('프로필 정보 수정하기'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: .min,
            spacing: 20,
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: '새 nickname (바꾸지 않으려면 비워두세요)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '새 password (바꾸지 않으려면 비워두세요)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "취소",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              final nickname = _nicknameController.text.trim();
              final password = _passwordController.text;

              final user = authVM.user;
              if (user == null) {
                Navigator.pop(dialogContext);
                return;
              }

              if (nickname.isEmpty && password.isEmpty) {
                showMessage(context, "nickname이나 password를 입력해주세요.");
                return;
              }

              // 닉네임을 바꿀 때는 중복 확인부터 (true면 이미 사용 중)
              if (nickname.isNotEmpty && nickname != user.nickname) {
                final taken = await authVM.isCheckNickname(nickname);
                if (!mounted) return;
                if (taken) {
                  showMessage(context, "이미 사용 중인 nickname입니다.");
                  return;
                }
              }

              // 빈 칸은 null로 보내서 그 항목은 바꾸지 않는다.
              final success = await authVM.updateProfile(
                nickname: nickname.isEmpty ? null : nickname,
                password: password.isEmpty ? null : password,
              );
              if (!mounted) return;

              if (success) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                showMessage(context, "프로필을 수정했습니다.");
              } else if (!authVM.isLogin) {
                // 세션이 만료됐으면 안내는 App이 띄우므로 다이얼로그만 닫는다.
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } else {
                // 실패하면 다이얼로그를 닫지 않고 다시 시도할 수 있게 둔다.
                showMessage(context, authVM.error ?? "프로필 수정에 실패 하셨습니다.");
              }
            },
            child: Text("수정"),
          ),
        ],
      ),
    );
  }

  void logoutPopup(AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "취소",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              context.go(AppRoutes.home); // 먼저 홈으로 보낸 뒤 로그아웃
              await authVM.logout();
            },
            child: Text(
              "로그아웃",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void deletePopup(AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('정말 계정을 삭제 하시겠습니까?'),
        content: Text('삭제한 계정은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "취소",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await authVM.deleteProfile();
              if (!mounted) return;
              if (success) {
                context.go(AppRoutes.home);
                showMessage(context, "계정이 삭제되었습니다.");
              } else {
                showMessage(context, authVM.error ?? "계정 삭제에 실패 하셨습니다.");
              }
            },
            child: Text(
              "계정 삭제",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String time) {
    final date = DateTime.parse(time).toLocal();
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}