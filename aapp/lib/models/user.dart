class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;
  
  // This token is not part of the backend User object, but it's useful 
  // for the Flutter app to retain it alongside User information if needed.
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'token': token,
    };
  }
}
