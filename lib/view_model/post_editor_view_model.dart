import 'package:flutter/cupertino.dart';
import 'package:withsave_frontend_test/model/repositories/post_repository.dart';

class PostEditorViewModel extends ChangeNotifier {
  PostEditorViewModel(this._repo, {this.postId}) : _isLoading = postId != null;

  final int? postId;
  final PostRepository _repo;

  String _initTitle = '';
  String _initText = '';
  bool _isLoading;
  bool _isSubmitting = false;
  String? _error;

  String get initTitle => _initTitle;

  String get initText => _initText;

  bool get isLoading => _isLoading;

  bool get isEdit => postId != null;

  bool get isSubmitting => _isSubmitting;

  String? get error => _error;

  Future<void> load() async {
    if(!isEdit) return;

    try{
      final post = await _repo.getDetail(postId: postId!);
      _initTitle = post.title;
      _initText = _htmlToText(post.post);
    }catch(e){
      _error = e.toString();
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submit(String title, String text) async {
    if (title.trim().isEmpty || text.trim().isEmpty) {
      _error = '제목과 내용 모두 입력해주세요.';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final html = _textToHtml(text);
      if (isEdit) {
        await _repo.patch(postId: postId!, title: title, post: html);
      } else {
        await _repo.create(title: title.toString(), post: html);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  static String _textToHtml(String text) {
    final escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return escaped
        .split('\n')
        .map(
          (e) => e.trim().isEmpty ? '<p><br /></p>' : '<p>$e</p>',
    )
        .join();
  }

  static String _htmlToText(String html) => html
      .replaceAll(RegExp(r'<br\s*/?>'), '')
      .replaceAll('</p>', '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .trim();
}
