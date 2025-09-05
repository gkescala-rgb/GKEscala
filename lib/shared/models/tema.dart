import 'package:equatable/equatable.dart';

class Tema extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final String? fileUrl;
  final String? fileName;
  final String? mimeType;
  final DateTime? data;
  final bool ativo;
  final DateTime createdAt;

  const Tema({
    required this.id,
    required this.nome,
    this.descricao,
  this.fileUrl,
  this.fileName,
  this.mimeType,
  this.data,
    this.ativo = true,
    required this.createdAt,
  });

  factory Tema.fromJson(Map<String, dynamic> json) {
    return Tema(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
  fileUrl: json['fileUrl'] as String?,
  fileName: json['fileName'] as String?,
  mimeType: json['mimeType'] as String?,
  data: json['data'] != null ? DateTime.parse(json['data'] as String) : null,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
  'fileUrl': fileUrl,
  'fileName': fileName,
  'mimeType': mimeType,
  'data': data?.toIso8601String().substring(0,10),
      'ativo': ativo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Tema copyWith({
    int? id,
    String? nome,
    String? descricao,
    String? fileUrl,
    String? fileName,
    String? mimeType,
    DateTime? data,
    bool? ativo,
    DateTime? createdAt,
  }) {
    return Tema(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      data: data ?? this.data,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, nome, descricao, fileUrl, fileName, mimeType, data, ativo, createdAt];
}
