import 'package:equatable/equatable.dart';

class Sala extends Equatable {
  final int id;
  final String nome;
  final int capacidade;
  final bool ativo;

  const Sala({
    required this.id,
    required this.nome,
    this.capacidade = 30,
    this.ativo = true,
  });

  factory Sala.fromJson(Map<String, dynamic> json) {
    return Sala(
      id: json['id'] as int,
      nome: json['nome'] as String,
      capacidade: json['capacidade'] as int? ?? 30,
      ativo: json['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'capacidade': capacidade,
      'ativo': ativo,
    };
  }

  Sala copyWith({
    int? id,
    String? nome,
    int? capacidade,
    bool? ativo,
  }) {
    return Sala(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      capacidade: capacidade ?? this.capacidade,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  List<Object?> get props => [id, nome, capacidade, ativo];
}
