import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/entities/post.dart';
import 'package:withsave_frontend_test/view_model/post_list_view_model.dart';

import 'common/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
          () {
        final postVM = context.read<PostListViewModel>();
        // 실패한 뒤에는 스크롤마다 다시 요청하지 않고 "다시 시도" 버튼에 맡긴다.
        if (postVM.error == null &&
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200) {
          postVM.loadMore();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postVM = context.watch<PostListViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent == 0 &&
          postVM.hasMore &&
          !postVM.isLoading &&
          postVM.error == null) {
        postVM.loadMore();
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Frontend Test"),
            IconButton(
              onPressed: () => context.push(AppRoutes.profile),
              icon: Icon(CupertinoIcons.profile_circled, size: 30),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              onFieldSubmitted: postVM.search,
              decoration: InputDecoration(
                hintText: '제목 검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: postVM.toggleOrder,
                child: Text(postVM.isNewestFirst ? '최신순' : '오래된순'),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => postVM.refresh(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverGrid.builder(
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisExtent: 180,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: postVM.post.length,
                      itemBuilder: (context, index) {
                        final post = postVM.post[index];
                        return postItem(post);
                      },
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: postVM.isLoading
                              ? CircularProgressIndicator()
                              : postVM.error != null
                              ? TextButton(
                            onPressed: () => postVM.loadMore(),
                            child: Text("${postVM.error}\n다시 시도"),
                          )
                              : postVM.post.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.only(top: 56),
                            child: Text('게시글이 없습니다.'),
                          )
                              : SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.add_post);
        },
        child: Icon(
          Icons.add,
          color: Colors.white54,
          size: 35,
        ),
      ),
    );
  }

  Widget postItem(PostSummary post) {
    // InkWell은 GestureDetector와 달리 키보드 포커스와 화면 낭독기의 버튼 정보를 준다.
    return InkWell(
      onTap: () => context.push(AppRoutes.detail_post(post.id)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white10,
        ),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              post.title,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                Icon(
                  CupertinoIcons.eye,
                  size: 20,
                ),
                Text('${post.watch}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}