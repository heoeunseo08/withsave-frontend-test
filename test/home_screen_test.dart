import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/entities/post.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';
import 'package:withsave_frontend_test/view/home_screen.dart';
import 'package:withsave_frontend_test/view_model/post_list_view_model.dart';

// 첫 페이지는 10개를 주고, 그 뒤로는 계속 실패한다.
class _FakePostRepository extends PostRepository {
  _FakePostRepository() : super(ApiClient());

  int calls = 0;

  @override
  Future<List<PostSummary>> getList({
    required int skip,
    required int take,
    String order = 'DESC',
  }) async {
    calls++;
    if (skip > 0) throw ApiException('서버에 연결할 수 없습니다.');
    return [
      for (var i = 0; i < take; i++)
        PostSummary(id: i, title: '글$i', watch: 0, created_at: '2026-10-23'),
    ];
  }
}

Future<_FakePostRepository> _pumpHome(WidgetTester tester) async {
  final repo = _FakePostRepository();
  final vm = PostListViewModel(repo);
  await vm.refresh();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: vm,
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('게시글 카드는 키보드로 고를 수 있고 누를 수 있다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpHome(tester);

    expect(
      tester.getSemantics(find.text('글0')),
      isSemantics(isFocusable: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('다음 페이지가 실패하면 스크롤해도 다시 요청하지 않는다', (tester) async {
    final repo = await _pumpHome(tester);
    expect(repo.calls, 1);

    for (var i = 0; i < 5; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('다시 시도'), findsOneWidget);
    expect(repo.calls, 2);
  });
}
