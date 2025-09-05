import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/services/escala_service.dart';
import '../../../shared/models/escala_today.dart';
import 'package:go_router/go_router.dart';

class EscalaScreen extends StatefulWidget {
  const EscalaScreen({super.key});

  @override
  State<EscalaScreen> createState() => _EscalaScreenState();
}

class _EscalaScreenState extends State<EscalaScreen> {
  late Future<List<EscalaToday>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<EscalaService>().getTodayScale();
  }

  void _refresh() {
    setState(() {
      _future = context.read<EscalaService>().getTodayScale();
    });
  }

  @override
  Widget build(BuildContext context) {
    final escalaService = context.read<EscalaService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalas de Hoje'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
            if (!isAdmin) return const SizedBox.shrink();
      return Row(children: [
            IconButton(
              tooltip: 'Resetar escala de hoje',
              onPressed: () async {
                await escalaService.resetTodayScale();
                _refresh();
              },
              icon: const Icon(Icons.restart_alt),
            ),
            IconButton(
              tooltip: 'Sortear escala',
              onPressed: () async {
                await escalaService.generateTodayScale();
                _refresh();
              },
              icon: const Icon(Icons.casino),
            ),
          ]);
          }),
          IconButton(
            tooltip: 'Adicionar disponibilidade',
            onPressed: () async {
              await context.push('/escala/disponibilidade');
              if (mounted) _refresh();
            },
            icon: const Icon(Icons.add_circle),
          )
        ],
      ),
  body: FutureBuilder<List<EscalaToday>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Nenhuma escala para hoje'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final escala = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
                  child: Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text('${escala.professorName} • Sala ${escala.salaName}'),
                subtitle: Text('Dia ${escala.date} • ${escala.period}'),
                trailing: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
                  if (!isAdmin) return const SizedBox.shrink();
                  return IconButton(
                    tooltip: 'Excluir escala',
                    onPressed: () async {
                      await escalaService.deleteEscala(escala.id);
                      _refresh();
                    },
                    icon: const Icon(Icons.delete),
                  );
                }),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: data.length,
          );
        },
      ),
    );
  }
}
