import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/repositories/user_repository.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';
import 'package:withsave_frontend_test/view/login_screen.dart';
import 'package:withsave_frontend_test/view/signup_screen.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';

Future<void> _expectLinkIsButton(WidgetTester tester, Widget screen, String label) async {
  final semantics = tester.ensureSemantics();
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(UserRepository(ApiClient())),
      child: MaterialApp(home: screen),
    ),
  );

  expect(
    tester.getSemantics(find.text(label)),
    isSemantics(isButton: true, isFocusable: true, hasTapAction: true),
  );
  semantics.dispose();
}

void main() {
  testWidgets('로그인 화면의 회원가입 링크는 버튼이다', (tester) async {
    await _expectLinkIsButton(tester, const LoginScreen(), '회원가입 하러가기');
  });

  testWidgets('회원가입 화면의 로그인 링크는 버튼이다', (tester) async {
    await _expectLinkIsButton(tester, const SignupScreen(), '로그인 하러가기');
  });
}
