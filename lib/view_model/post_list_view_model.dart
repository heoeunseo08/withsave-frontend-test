import 'package:flutter/cupertino.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';

import '../model/entities/post.dart';

class PostListViewModel extends ChangeNotifier {
  PostListViewModel(this._repo);

  static const int _task = 10;
  final PostRepository _repo;

  final List<PostSummary> _post = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  String _order = 'DESC';
  String _keyword = '';

  List<PostSummary> get post => List.unmodifiable(_post);

  bool get isLoading => _isLoading;

  bool get hasMore => _hasMore;

  String? get error => _error;

  bool get isNewestFirst => _order == 'DESC';

  String get keyword => _keyword;

  Future<void> refresh() async {
    _post.clear();
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
      final page = _keyword.isEmpty
          ? await _repo.getList(skip: _post.length, take: _task, order: _order)
          : await _repo.search(
              keyword: _keyword,
              skip: _post.length,
              take: _task,
              order: _order,
            );
      _post.addAll(page);
      _hasMore = page.length == _task;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String keyword) async {
    _keyword = keyword.trim();
    return refresh();
  }

  Future<void> toggleOrder() async {
    _order = isNewestFirst ? 'ASC' : 'DESC';
    return refresh();
  }
}
