import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/entities/user.dart';
import 'package:withsave_frontend_test/model/repositories/user_repository.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';
import 'package:withsave_frontend_test/view/login_screen.dart';
import 'package:withsave_frontend_test/view/profile_screen.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';

// 요청을 세기만 하고 응답은 끝내지 않아, 첫 요청이 진행 중인 상태를 만든다.
class _FakeUserRepository extends UserRepository {
  _FakeUserRepository() : super(ApiClient());

  int loginCalls = 0;
  int nicknameChecks = 0;

  @override
  Future<void> login({required String password, required String nickname}) {
    loginCalls++;
    return Completer<void>().future;
  }

  @override
  Future<User> loadProfile() async => User(
    id: 1,
    nickname: 'me',
    email: 'me@test.com',
    createdAt: '2026-10-23T00:00:00Z',
  );

  @override
  Future<bool> checkNickname({required String nickname}) {
    nicknameChecks++;
    return Completer<bool>().future;
  }
}

Future<void> _pump(WidgetTester tester, AuthViewModel auth, Widget screen) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: auth, child: MaterialApp(home: screen)),
  );
}

void main() {
  testWidgets('로그인 버튼을 두 번 눌러도 요청은 한 번만 간다', (tester) async {
    final repo = _FakeUserRepository();
    await _pump(tester, AuthViewModel(repo), const LoginScreen());

    await tester.enterText(find.byType(TextFormField).at(0), 'me');
    await tester.enterText(find.byType(TextFormField).at(1), 'pw');
    await tester.tap(find.text('로그인'));
    await tester.pump();
    await tester.tap(find.text('로그인'), warnIfMissed: false);
    await tester.pump();

    expect(repo.loginCalls, 1);
  });

  testWidgets('프로필 수정 버튼을 두 번 눌러도 요청은 한 번만 간다', (tester) async {
    final repo = _FakeUserRepository();
    final auth = AuthViewModel(repo);
    await auth.init();
    await _pump(tester, auth, const ProfileScreen());

    await tester.tap(find.text('수정하기'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'new');
    await tester.tap(find.text('수정'));
    await tester.pump();
    await tester.tap(find.text('수정'), warnIfMissed: false);
    await tester.pump();

    expect(repo.nicknameChecks, 1);
  });
}
