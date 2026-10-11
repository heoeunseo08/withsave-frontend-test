import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';
import 'package:withsave_frontend_test/view/common/message.dart';
import 'package:withsave_frontend_test/view/common/need_login.dart';
import 'package:withsave_frontend_test/view_model/auth_view_model.dart';
import 'package:withsave_frontend_test/view_model/post_editor_view_model.dart';
import 'package:withsave_frontend_test/view_model/post_list_view_model.dart';

/// postId가 없으면 새 글 작성, 있으면 기존 글 수정
class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key, this.postId});

  final int? postId;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final PostEditorViewModel editorVM;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editorVM = PostEditorViewModel(
      context.read<PostRepository>(),
      postId: widget.postId,
    );

    //수정모드
    editorVM.load().then((_) {
      if (!mounted) return;
      _titleController.text = editorVM.initTitle;
      _textController.text = editorVM.initText;
    });
  }

  @override
  void dispose() {
    editorVM.dispose();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final success = await editorVM.submit(
      _titleController.text,
      _textController.text,
    );
    if (!mounted) return;

    if (success) {
      context.read<PostListViewModel>().refresh();
      showMessage(context, editorVM.isEdit ? '게시글을 수정했습니다.' : '게시글을 작성했습니다.');
      context.pop();
    } else {
      showMessage(context, editorVM.error ?? '저장에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return ListenableBuilder(
      listenable: editorVM,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(editorVM.isEdit ? '게시글 수정' : '게시글 작성'),
            actions: [
              if (authVM.isLogin)
                TextButton(
                  onPressed: editorVM.isSubmitting || editorVM.isLoading ? null : save,
                  child: Text(editorVM.isEdit ? '수정하기' : '게시하기'),
                ),
            ],
          ),
          body: !authVM.isLogin
              ? NeedLogin.needLoginWidget(context)
              : editorVM.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '제목',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _textController,
                    minLines: 12,
                    maxLines: null, // 내용만큼 늘어난다
                    decoration: InputDecoration(
                      hintText: '내용을 입력하세요',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}