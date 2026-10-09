import 'package:withsave_frontend_test/model/entities/comment.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';

class CommentRepository {
  CommentRepository(this._api);

  final ApiClient _api;

  Future<List<Comment>> getList({
    required int skip,
    required int take,
    String order = 'ASC',
    required int postId,
  }) async {
    final data = await _api.get(
      '/comment/find/many/$skip/$take/$order/$postId',
    );
    return (data as List)
        .whereType<Map>()
        .map((e) => Comment.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> create({required int postId,required String comment}) async {
    await _api.post(
        '/comment/update/one/',
        data:{
          "postId": postId,
          "comment": comment
        }
    );
  }

  Future<void> delete({required int commentId}) async {
    await _api.delete('/comment', query: {'commentId': commentId});
  }

  Future<void> patch(
      {
      required int commentId,
    required String nickname,
    required String comment,
  }) async {
    await _api.patch(
      '/comment/update/one/$commentId',
      data:{
        "nickname": nickname,
        "comment": comment,
        "delete_comment": false
      }
    );
  }
}
