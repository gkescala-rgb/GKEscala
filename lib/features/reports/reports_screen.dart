import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../core/services/escala_service.dart';
import '../../core/services/admin_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthBloc, bool>((bloc) =>
        bloc.state is AuthAuthenticated &&
        (bloc.state as AuthAuthenticated).user.isAdmin);
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Acesso negado')));
    }

  final escalaService = context.read<EscalaService>();
  final adminService = context.read<AdminService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Future.wait([
          adminService.getReport(),
          escalaService.getPresenceStats(),
        ]).then((v) => {'report': v[0], 'presence': v[1]}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Erro ao carregar: ${snapshot.error}'),
              ),
            );
          }

          final report = Map<String, dynamic>.from(snapshot.data?['report'] ?? {});
          final presence = Map<String, dynamic>.from(snapshot.data?['presence'] ?? {});
          final entries = presence.entries.toList()
            ..sort((a, b) => (b.value as num).compareTo(a.value as num));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ListTile(
                leading: Icon(Icons.today),
                title: Text('Presença por professor'),
                subtitle: Text('Quantidade de alocações registradas'),
              ),
              const Divider(),
              if (entries.isEmpty)
                const ListTile(
                  title: Text('Sem dados de presença'),
                )
              else
                ...entries.map((e) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(e.key),
                      trailing: Text('${e.value}'),
                    )),
              const SizedBox(height: 24),
              const ListTile(
                leading: Icon(Icons.report),
                title: Text('Relatório de faltas'),
                subtitle: Text('Total de justificativas do tipo falta'),
              ),
              ListTile(
                leading: const Icon(Icons.countertops),
                title: const Text('Faltas registradas'),
                trailing: Text('${report['faltas'] ?? 0}'),
              ),
            ],
          );
        },
      ),
    );
  }
}
