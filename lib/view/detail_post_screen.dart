import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/repositories/comment_repository.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';
import 'package:withsave_frontend_test/view/common/app_router.dart';
import 'package:withsave_frontend_test/view/common/format_date.dart';
import 'package:withsave_frontend_test/view/common/message.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';
import 'package:withsave_frontend_test/view_model/comment_view_model.dart';
import 'package:withsave_frontend_test/view_model/post_detail_view_model.dart';
import 'package:withsave_frontend_test/view_model/post_list_view_model.dart';

import '../model/entities/comment.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({super.key, required this.postId});

  final int postId;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  late final PostDetailViewModel postDetailVM;
  late final CommentViewModel commentVM;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    postDetailVM = PostDetailViewModel(
      repo: context.read<PostRepository>(),
      postId: widget.postId,
    )..load();
    commentVM = CommentViewModel(
      context.read<CommentRepository>(),
      widget.postId,
    )..load();
  }

  @override
  void dispose() {
    postDetailVM.dispose();
    commentVM.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    return ListenableBuilder(
      listenable: Listenable.merge([postDetailVM, commentVM]),
      builder: (context, child) {
        final post = postDetailVM.post;

        // 아직 불러오는 중이거나 실패했을 때
        if (post == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: postDetailVM.isLoading
                  ? const CircularProgressIndicator()
                  : Text(postDetailVM.error ?? '게시글을 찾을 수 없습니다.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(post.title),
            actions: [
              if (authVM.isMine(post.userId))
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: PopupMenuButton<String>(
                    child: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') editPost();
                      if (value == 'delete') deletePost();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          spacing: 8,
                          children: [Icon(Icons.edit), Text("수정하기")],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          spacing: 8,
                          children: [Icon(Icons.delete), Text("삭제하기")],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    '${authVM.isMine(post.userId) ? '나' : post.nickname ?? '사용자 ${post.userId}'}'
                    ' · ${formatDate(post.created_at)} · 조회 ${post.watch}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  HtmlWidget(
                    post.post,
                    customWidgetBuilder: (element) {
                      if (element.localName != 'img') return null;
                      final src = element.attributes['src'];
                      if (src == null) return null;
                      return Image.network(
                        src,
                        width: double.tryParse(
                          element.attributes['width'] ?? '',
                        ),
                        height: double.tryParse(
                          element.attributes['height'] ?? '',
                        ),
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      );
                    },
                  ),
                  commentSection(authVM),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> editPost() async {
    await context.push(AppRoutes.edit_post(widget.postId));
    postDetailVM.load(); // 수정하고 돌아오면 다시 불러온다
  }

  Future<void> deletePost() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('게시글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final success = await postDetailVM.delete();
    if (!mounted) return;
    if (success) {
      context.read<PostListViewModel>().refresh(); // 홈 목록에서 빠지도록
      showMessage(context, '게시글을 삭제했습니다.');
      context.go(AppRoutes.home);
    } else {
      showMessage(context, postDetailVM.error ?? '게시글 삭제에 실패했습니다.');
    }
  }

  Widget commentSection(AuthViewModel authVM) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        const Text('댓글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        // 로그인 상태면 입력창, 아니면 로그인 안내
        authVM.isLogin
            ? Row(
          spacing: 8,
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: commentVM.isSubmitting ? null : createComment,
              child: const Text('등록'),
            ),
          ],
        )
            : OutlinedButton(
          onPressed: () => context.push(AppRoutes.login),
          child: const Text('로그인하고 댓글 남기기'),
        ),
        if (!commentVM.isLoading && commentVM.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('아직 댓글이 없습니다.'),
          ),
        for (final comment in commentVM.comments)
          commentItem(comment, authVM.isMine(comment.userId)),
        if (commentVM.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (commentVM.hasMore)
          Center(
            child: TextButton(onPressed: commentVM.loadMore, child: const Text('댓글 더보기')),
          ),
      ],
    );
  }

  Widget commentItem(Comment comment, bool mine) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(comment.comment),
      subtitle: Text('${mine ? '나' : '사용자 ${comment.userId}'} · ${formatDate(comment.created_at)}'),
      trailing: mine
          ? PopupMenuButton<String>(
        onSelected: (v) => v == 'edit' ? editComment(comment) : deleteComment(comment),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('수정')),
          PopupMenuItem(value: 'delete', child: Text('삭제')),
        ],
      )
          : null,
    );
  }

  Future<void> createComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final ok = await commentVM.create(text);
    if (!mounted) return;
    ok ? _commentController.clear() : showMessage(context, commentVM.error ?? '댓글 작성에 실패했습니다.');
  }

  Future<void> editComment(Comment comment) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => _EditCommentDialog(initialText: comment.comment),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    if (!await commentVM.patch(comment.commitId, text) && mounted) {
      showMessage(context, commentVM.error ?? '댓글 수정에 실패했습니다.');
    }
  }

  Future<void> deleteComment(Comment comment) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('댓글을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (!await commentVM.delete(comment.commitId) && mounted) {
      showMessage(context, commentVM.error ?? '댓글 삭제에 실패했습니다.');
    }
  }
}


// 닫히는 애니메이션 동안에도 TextField가 컨트롤러를 쓰므로, 다이얼로그가 직접 들고 있다가 사라질 때 정리한다.
class _EditCommentDialog extends StatefulWidget {
  const _EditCommentDialog({required this.initialText});

  final String initialText;

  @override
  State<_EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<_EditCommentDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('댓글 수정'),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('저장')),
      ],
    );
  }
}
