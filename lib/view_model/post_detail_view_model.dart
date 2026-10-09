import 'package:flutter/cupertino.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';

import '../model/entities/post.dart';

class PostDetailViewModel extends ChangeNotifier {
  PostDetailViewModel({required this._repo, required this.postId});

  final PostRepository _repo;

  final int postId;

  Post? _post;
  bool _isLoading = false;
  String? _error;

  Post? get post => _post;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
      notifyListeners();
      try{
        _post = await _repo.getDetail(postId: postId);
      }catch(e){
        _error = e.toString();
      }finally{
        _isLoading = false;
        notifyListeners();
      }
  }

  Future<bool> delete() async {
    _isLoading = true;
    try{
      await _repo.delete(postId: postId);
      return true;
    }catch(e){
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
