import 'package:flutter/foundation.dart';
import 'package:withsave_frontend_test/model/entities/comment.dart';
import 'package:withsave_frontend_test/model/repositories/comment_repository.dart';

class CommentViewModel extends ChangeNotifier   {
  CommentViewModel(this._repo, this.postId);

  static const _take = 10;
  final CommentRepository _repo;
  final int postId;

  final List<Comment> _loaded = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _hasMore = true;
  String? _error;

  List<Comment> get comments => _loaded.where((c) => !c.delete_comment).toList();
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> load() async {
    _loaded.clear();
    _hasMore = true;
    _isLoading = false;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repo.getList(
        skip: _loaded.length,
        take: _take,
        postId: postId,
      );
      _loaded.addAll(page);
      _hasMore = page.length == _take;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String text) =>
      _submit(() => _repo.create(postId: postId, comment: text.trim()), text);

  Future<bool> patch(int commentId, String nickname, String text) => _submit(
        () => _repo.patch(commentId: commentId, nickname: nickname, comment: text.trim()),
    text,
  );

  Future<bool> delete(int commentId) => _submit(() => _repo.delete( commentId: commentId), 'x');

  Future<bool> _submit(Future<void> Function() task, String text) async {
    if (text.trim().isEmpty) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await task();
      _isSubmitting = false;
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}