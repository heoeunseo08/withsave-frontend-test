import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withsave_frontend_test/view/common/app_router.dart';

class NeedLogin{

  static Column needLoginWidget(BuildContext context) => Column(
    crossAxisAlignment: .center,
    mainAxisAlignment: .center,
    spacing: 12,
    children: [
      Text("해당 페이지는 로그인이 필요합니다."),
      Container(width:  MediaQuery.widthOf(context)),
      ElevatedButton(
        onPressed: () => context.push(AppRoutes.login),
        child: Text(
          "로그인 페이지로 이동하기",
          style: TextStyle(fontSize: 18),
        ),
      ),
    ],
  );
}

