import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final user = json['professor'] ?? json['user'];
    return AuthUser(
      id: user['id'] as int,
      name: user['name'] as String,
      email: user['email'] as String,
      role: user['role'] as String? ?? 'professor',
      token: (json['token'] ?? json['access_token']) as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professor': {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      },
      'token': token,
    };
  }

  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? token,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, name, email, role, token];
}
