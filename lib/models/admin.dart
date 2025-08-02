// lib/models/admin.dart
class Admin {
  final String id;
  final String email;
  final String password;
  final String name;
  final String role;
  final DateTime createdAt;

  Admin({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.role = 'admin',
    required this.createdAt,
  });

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      role: map['role'] ?? 'admin',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}