import 'package:equatable/equatable.dart';

class Professor extends Equatable {
  final int id;
  final String name;
  final String email;
  final List<String> preferencias;
  final String? ultimaSala;
  final String role;
  final bool ativo;

  const Professor({
    required this.id,
    required this.name,
    required this.email,
    this.preferencias = const [],
    this.ultimaSala,
    this.role = 'professor',
    this.ativo = true,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      preferencias: json['preferencias'] != null
          ? List<String>.from(json['preferencias'])
          : [],
      ultimaSala: json['ultimaSala'] as String?,
      role: json['role'] as String? ?? 'professor',
      ativo: json['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferencias': preferencias,
      'ultimaSala': ultimaSala,
      'role': role,
      'ativo': ativo,
    };
  }

  Professor copyWith({
    int? id,
    String? name,
    String? email,
    List<String>? preferencias,
    String? ultimaSala,
    String? role,
    bool? ativo,
  }) {
    return Professor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      preferencias: preferencias ?? this.preferencias,
      ultimaSala: ultimaSala ?? this.ultimaSala,
      role: role ?? this.role,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  List<Object?> get props => [id, name, email, preferencias, ultimaSala, role, ativo];
}
