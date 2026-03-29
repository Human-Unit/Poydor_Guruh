class User {
  final String email;
  final String token;

  User({
    required this.email,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }
}
