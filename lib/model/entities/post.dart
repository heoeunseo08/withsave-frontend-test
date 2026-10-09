class PostSummary {
  final int id;
  final String title;
  final int watch;
  final String created_at;

  PostSummary({
    required this.id,
    required this.title,
    required this.watch,
    required this.created_at,
  });

  factory PostSummary.fromJson(Map<String, dynamic> json) {
    return PostSummary(
      id: json['id'],
      title: json['title'],
      watch: json['watch'],
      created_at: json['created_at'],
    );
  }
}

class Post {
  final int id;
  final int userId;
  final String nickname;
  final String title;
  final String post;
  final int watch;
  final String created_at;
  final String updated_at;

  Post({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.title,
    required this.post,
    required this.watch,
    required this.created_at,
    required this.updated_at,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      nickname: json['nickname'] ?? '알 수 없음',
      title: json['title'],
      post: json['post'],
      watch: json['watch'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}