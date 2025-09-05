import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/sala_service.dart';
import '../../../shared/models/sala.dart';
import '../../auth/bloc/auth_bloc.dart';

class SalaListScreen extends StatefulWidget {
  const SalaListScreen({super.key});

  @override
  State<SalaListScreen> createState() => _SalaListScreenState();
}

class _SalaListScreenState extends State<SalaListScreen> {
  @override
  Widget build(BuildContext context) {
    final salaService = context.read<SalaService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salas'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
            if (!isAdmin) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Nova',
              onPressed: () async {
                await context.push('/salas/nova');
                if (!mounted) return;
                setState(() {});
              },
              icon: const Icon(Icons.add),
            );
          })
        ],
      ),
      body: RefreshIndicator(
  onRefresh: () async { if (mounted) setState(() {}); },
        child: FutureBuilder<List<Sala>>(
        future: salaService.getAllSalas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          var data = snapshot.data ?? [];
          // Professores só devem ver salas ativas
          final auth = context.read<AuthBloc>().state;
          final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;
          if (!isAdmin) {
            data = data.where((s) => s.ativo).toList();
          }
          if (data.isEmpty) {
            return const Center(child: Text('Nenhuma sala encontrada'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final sala = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
                  child: Icon(Icons.meeting_room, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(sala.nome),
                subtitle: Text('Capacidade: ${sala.capacidade} • ${sala.ativo ? 'Ativa' : 'Inativa'}'),
                trailing: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
                  if (!isAdmin) return const SizedBox.shrink();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () async {
                          await context.push('/salas/${sala.id}/editar');
                          if (!mounted) return;
                          setState(() {});
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: 'Excluir',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Excluir sala'),
                              content: Text('Deseja excluir a sala "${sala.nome}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          await context.read<SalaService>().deleteSala(sala.id);
                          if (!mounted) return;
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  );
                }),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: data.length,
          );
        },
      ),
      ),
  // FAB removido; botão está no AppBar
    );
  }
}
