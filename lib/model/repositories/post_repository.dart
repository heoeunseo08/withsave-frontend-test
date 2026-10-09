import 'package:withsave_frontend_test/model/entities/post.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';

class PostRepository {
  PostRepository(this._api);

  final ApiClient _api;

  Future<void> create({
    required String title,
    required String post,
  }) async {
    await _api.post(
      '/post-article',
      data: {
        "title": title,
        "post": post,
      },
    );
  }

  Future<List<PostSummary>> getList({
    required int skip,
    required int take,
    String order = 'DESC',
  }) async {
    final data = await _api.get(
      '/post-article/find/many/$skip/$take/$order',
    );
    return (data as List)
        .whereType<Map>()
        .map((e) => PostSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> patch({
    required int postId,
    required String title,
    required String post,
  }) async {
    await _api.patch(
      '/post-article/update/one/$postId',
      data: {
        "title": title,
        "post": post,
      },
    );
  }

  Future<Post> getDetail({required int postId}) async {
    final data = await _api.get(
      '/post-article/find/one/$postId',
    );
    return Post.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> delete({required int postId}) async {
    await _api.delete('/post-article/delete/one/$postId');
  }

  Future<List<PostSummary>> search({
    required String keyword,
    required int skip,
    required int take,
    String order = 'DESC',
}) async {
    final data = await _api.get(
      '/post-article/search/${Uri.encodeComponent(keyword)}/$skip/$take/$order',
    );
    return (data as List)
        .whereType<Map>()
        .map((e) => PostSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
