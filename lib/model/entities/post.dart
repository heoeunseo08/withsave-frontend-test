class Post {
  final int userId;
  final String title;
  final String post;
  final String watch;
  final String created_at;
  final String updated_at;

  Post({
    required this.userId,
    required this.title,
    required this.post,
    required this.watch,
    required this.created_at,
    required this.updated_at,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      title: json['title'],
      post: json['post'],
      watch: json['watch'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}
