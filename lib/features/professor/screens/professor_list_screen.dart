import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/professor_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/models/professor.dart';

class ProfessorListScreen extends StatefulWidget {
  const ProfessorListScreen({super.key});

  @override
  State<ProfessorListScreen> createState() => _ProfessorListScreenState();
}

class _ProfessorListScreenState extends State<ProfessorListScreen> {

  @override
  Widget build(BuildContext context) {
    final service = context.read<ProfessorService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professores'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
            if (!isAdmin) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Novo',
              onPressed: () async {
                await context.push('/professores/novo');
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
        child: FutureBuilder<List<Professor>>(
        future: service.getAllProfessors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final profs = snapshot.data ?? [];
          if (profs.isEmpty) {
            return const Center(child: Text('Nenhum professor encontrado.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: profs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = profs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
                  child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(p.name),
                subtitle: Text(p.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      p.ativo ? Icons.check_circle : Icons.cancel,
                      color: p.ativo ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
          IconButton(
                      tooltip: 'Editar',
                      onPressed: () async {
            await context.push('/professores/${p.id}/editar');
            if (!mounted) return;
            setState(() {});
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Excluir',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Excluir professor'),
                            content: Text('Deseja excluir "${p.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        await context.read<ProfessorService>().deleteProfessor(p.id);
                        if (!mounted) return;
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
            
          );
        },
      ),
      ),
  // FAB removido; botão está no AppBar para consistência
    );
  }
}
