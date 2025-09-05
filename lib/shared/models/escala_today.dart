import 'package:equatable/equatable.dart';

class EscalaToday extends Equatable {
  final int id;
  final String professorName;
  final String salaName;
  final String date; // ISO date (yyyy-MM-dd)
  final String period; // e.g., 'morning'/'afternoon'

  const EscalaToday({
    required this.id,
    required this.professorName,
    required this.salaName,
    required this.date,
    required this.period,
  });

  factory EscalaToday.fromJson(Map<String, dynamic> json) => EscalaToday(
        id: json['id'] as int,
        professorName: json['professorName'] as String,
        salaName: json['salaName'] as String,
        date: json['date'] as String,
        period: json['period'] as String,
      );

  @override
  List<Object?> get props => [id, professorName, salaName, date, period];
}
