import 'package:equatable/equatable.dart';
import 'professor.dart';
import 'sala.dart';
import 'tema.dart';

class Escala extends Equatable {
  final int id;
  final Professor professor;
  final int professorId;
  final Sala sala;
  final int salaId;
  final Tema? tema;
  final int? temaId;
  final DateTime data;
  final bool confirmada;
  final bool justificada;
  final String status;

  const Escala({
    required this.id,
    required this.professor,
    required this.professorId,
    required this.sala,
    required this.salaId,
    this.tema,
    this.temaId,
    required this.data,
    this.confirmada = false,
    this.justificada = false,
    this.status = 'pendente',
  });

  factory Escala.fromJson(Map<String, dynamic> json) {
    return Escala(
      id: json['id'] as int,
      professor: Professor.fromJson(json['professor'] as Map<String, dynamic>),
      professorId: json['professorId'] as int,
      sala: Sala.fromJson(json['sala'] as Map<String, dynamic>),
      salaId: json['salaId'] as int,
      tema: json['tema'] != null
          ? Tema.fromJson(json['tema'] as Map<String, dynamic>)
          : null,
      temaId: json['temaId'] as int?,
      data: DateTime.parse(json['data'] as String),
      confirmada: json['confirmada'] as bool? ?? false,
      justificada: json['justificada'] as bool? ?? false,
      status: json['status'] as String? ?? 'pendente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professor': professor.toJson(),
      'professorId': professorId,
      'sala': sala.toJson(),
      'salaId': salaId,
      'tema': tema?.toJson(),
      'temaId': temaId,
      'data': data.toIso8601String(),
      'confirmada': confirmada,
      'justificada': justificada,
      'status': status,
    };
  }

  Escala copyWith({
    int? id,
    Professor? professor,
    int? professorId,
    Sala? sala,
    int? salaId,
    Tema? tema,
    int? temaId,
    DateTime? data,
    bool? confirmada,
    bool? justificada,
    String? status,
  }) {
    return Escala(
      id: id ?? this.id,
      professor: professor ?? this.professor,
      professorId: professorId ?? this.professorId,
      sala: sala ?? this.sala,
      salaId: salaId ?? this.salaId,
      tema: tema ?? this.tema,
      temaId: temaId ?? this.temaId,
      data: data ?? this.data,
      confirmada: confirmada ?? this.confirmada,
      justificada: justificada ?? this.justificada,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        professor,
        professorId,
        sala,
        salaId,
        tema,
        temaId,
        data,
        confirmada,
        justificada,
        status,
      ];
}
