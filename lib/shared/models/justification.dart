import 'package:equatable/equatable.dart';
import 'professor.dart';

class Justification extends Equatable {
  final int id;
  final Professor professor;
  final int professorId;
  final DateTime data;
  final String motivo;
  final String? arquivo;
  final String? fileName;
  final String? mimeType;
  final String status;
  final DateTime createdAt;

  const Justification({
    required this.id,
    required this.professor,
    required this.professorId,
    required this.data,
    required this.motivo,
    this.arquivo,
  this.fileName,
  this.mimeType,
    this.status = 'pendente',
    required this.createdAt,
  });

  factory Justification.fromJson(Map<String, dynamic> json) {
    final profJson = json['professor'] as Map<String, dynamic>;
    final motivo = (json['motivo'] ?? json['message']) as String;
    final arquivo = (json['arquivo'] ?? json['fileUrl']) as String?;
    final created = (json['createdAt'] ?? json['data']) as String;
    final status = (json['status'] as String?) ?? 'pendente';
    return Justification(
      id: json['id'] as int,
      professor: Professor.fromJson(profJson),
      professorId: json['professorId'] as int,
      data: DateTime.parse((json['data'] as String?) ?? created),
      motivo: motivo,
      arquivo: arquivo,
      fileName: json['fileName'] as String?,
      mimeType: json['mimeType'] as String?,
      status: status,
      createdAt: DateTime.parse(created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professor': professor.toJson(),
      'professorId': professorId,
      'data': data.toIso8601String(),
      'motivo': motivo,
      'arquivo': arquivo,
  'fileName': fileName,
  'mimeType': mimeType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Justification copyWith({
    int? id,
    Professor? professor,
    int? professorId,
    DateTime? data,
    String? motivo,
    String? arquivo,
    String? fileName,
    String? mimeType,
    String? status,
    DateTime? createdAt,
  }) {
    return Justification(
      id: id ?? this.id,
      professor: professor ?? this.professor,
      professorId: professorId ?? this.professorId,
      data: data ?? this.data,
      motivo: motivo ?? this.motivo,
      arquivo: arquivo ?? this.arquivo,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        professor,
        professorId,
        data,
        motivo,
        arquivo,
  fileName,
  mimeType,
        status,
        createdAt,
      ];
}
