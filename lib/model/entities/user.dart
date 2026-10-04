class User {
  final int id;
  final String nickname;
  final String email;
  final String createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.nickname,
    required this.email,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nickname: json['nickname'],
      email: json['email'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
