import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/escala_service.dart';
import '../../../core/services/sala_service.dart';
import '../../../core/services/professor_service.dart';
import '../../../shared/models/sala.dart';
import '../../auth/bloc/auth_bloc.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final List<DateTime> _dates = [];
  String _period = 'morning';
  final Set<String> _naoInteresseSalas = <String>{};

  @override
  void initState() {
    super.initState();
    // Precarrega preferências atuais do professor
    Future.microtask(() async {
      final auth = context.read<AuthBloc>().state;
      if (auth is AuthAuthenticated) {
        try {
          final prof = await context.read<ProfessorService>().getProfessor(auth.user.id);
          if (!mounted) return;
          _naoInteresseSalas
            ..clear()
            ..addAll(prof.preferencias);
          setState(() {});
        } catch (_) {}
      }
    });
  }

  void _toggleDate(DateTime day) {
    final exists = _dates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
    setState(() {
      if (exists) {
        _dates.removeWhere((d) => d.year == day.year && d.month == day.month && d.day == day.day);
      } else {
        _dates.add(day);
      }
    });
  }

  Future<void> _save() async {
    if (_dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione pelo menos um dia')));
      return;
    }
    final auth = context.read<AuthBloc>().state as AuthAuthenticated;
    final payload = _dates
        .map((d) => {
              'date': d.toIso8601String().substring(0, 10),
              'period': _period,
            })
        .toList();
    try {
      await context.read<EscalaService>().updateAvailability(auth.user.id, payload);
      // Salvar preferências de não interesse
      if (_naoInteresseSalas.isNotEmpty) {
        await context.read<ProfessorService>().updatePreferences(auth.user.id, _naoInteresseSalas.toList());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disponibilidade registrada')));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar disponibilidade'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Período'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'morning', label: Text('Manhã')),
                ButtonSegment(value: 'afternoon', label: Text('Tarde')),
                ButtonSegment(value: 'night', label: Text('Noite')),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Sala>>(
              future: context.read<SalaService>().getAllSalas(),
              builder: (context, snapshot) {
                final salas = (snapshot.data ?? []).where((s) => s.ativo).toList();
                if (salas.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salas que NÃO tenho interesse'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: salas.map((s) {
                        final selected = _naoInteresseSalas.contains(s.nome);
                        return FilterChip(
                          label: Text(s.nome),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _naoInteresseSalas.add(s.nome);
                              } else {
                                _naoInteresseSalas.remove(s.nome);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 0)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: _toggleDate,
                currentDate: DateTime.now(),
              ),
            ),
            Wrap(
              spacing: 8,
              children: _dates
                  .map((d) => Chip(
                        label: Text('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}'),
                        onDeleted: () => setState(() => _dates.remove(d)),
                      ))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
