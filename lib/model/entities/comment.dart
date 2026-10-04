class Comment {
  final int commitId;
  final int userId;
  final int postId;
  final int relateId;
  final String comment;
  final String created_at;
  final String update_at;
  final bool delete_comment;

  Comment({
    required this.commitId,
    required this.userId,
    required this.postId,
    required this.relateId,
    required this.comment,
    required this.created_at,
    required this.update_at,
    required this.delete_comment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commitId: json['commitId'],
      userId: json['userId'],
      postId: json['postId'],
      relateId: json['relateId'],
      comment: json['comment'],
      created_at: json['created_at'],
      update_at: json['update_at'],
      delete_comment: json['delete_comment'],
    );
  }
}
