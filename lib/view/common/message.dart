import 'package:flutter/material.dart';

// 이전 메시지가 떠 있으면 바로 바꿔서, 같은 메시지가 줄줄이 쌓이지 않게 한다.
void showMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
