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
  // refresh마다 올라가서, 이전 조건으로 보낸 요청의 응답을 버리는 데 쓴다.
  int _generation = 0;

  List<PostSummary> get post => List.unmodifiable(_post);

  bool get isLoading => _isLoading;

  bool get hasMore => _hasMore;

  String? get error => _error;

  bool get isNewestFirst => _order == 'DESC';

  String get keyword => _keyword;

  Future<void> refresh() async {
    _generation++;
    _post.clear();
    _hasMore = true;
    _isLoading = false;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    final generation = _generation;
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
      if (generation != _generation) return;
      _post.addAll(page);
      _hasMore = page.length == _task;
    } catch (e) {
      if (generation != _generation) return;
      _error = e.toString();
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
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
