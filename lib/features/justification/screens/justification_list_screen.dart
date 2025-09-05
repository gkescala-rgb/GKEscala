import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/escala_service.dart';
import '../../../shared/models/justification.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/utils/download_helper.dart';

class JustificationListScreen extends StatefulWidget {
  const JustificationListScreen({super.key});

  @override
  State<JustificationListScreen> createState() => _JustificationListScreenState();
}

class _JustificationListScreenState extends State<JustificationListScreen> {

  @override
  Widget build(BuildContext context) {
    final escalaService = context.read<EscalaService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Justificações')),
      body: RefreshIndicator(
        onRefresh: () async { if (mounted) setState(() {}); },
        child: FutureBuilder<List<Justification>>(
        future: escalaService.getAllJustifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Nenhuma justificativa encontrada'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final j = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
                  child: Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(j.motivo),
                subtitle: Text('${j.professor.name} • ${j.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${j.data.day.toString().padLeft(2, '0')}/${j.data.month.toString().padLeft(2, '0')}/${j.data.year}',
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
                      if (!isAdmin) return const SizedBox.shrink();
                      return IconButton(
                        tooltip: 'Baixar anexo',
                        onPressed: () async {
                          try {
                            final resp = await context.read<EscalaService>().downloadJustificationBlob(j.id);
                            final bytes = resp.data;
                            if (bytes == null || bytes.isEmpty) return;
                            String fileName = j.fileName ?? 'justificativa_${j.id}';
                            if (!fileName.contains('.')) {
                              final mime = j.mimeType ?? '';
                              if (mime.contains('pdf')) fileName = '$fileName.pdf';
                              else if (mime.contains('png')) fileName = '$fileName.png';
                              else if (mime.contains('jpeg') || mime.contains('jpg')) fileName = '$fileName.jpg';
                              else if (mime.contains('msword') || mime.contains('word')) fileName = '$fileName.doc';
                              else if (mime.contains('sheet') || mime.contains('excel')) fileName = '$fileName.xlsx';
                              else if (mime.contains('plain')) fileName = '$fileName.txt';
                              else if (mime.contains('json')) fileName = '$fileName.json';
                              else if (mime.contains('zip')) fileName = '$fileName.zip';
                              else fileName = '$fileName.bin';
                            }
                            await DownloadHelper.saveBytes(bytes: bytes, fileName: fileName);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao baixar: $e')));
                            }
                          }
                        },
                        icon: const Icon(Icons.file_download),
                      );
                    }),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
                        if (!isAdmin) return const SizedBox.shrink();
                        final isPending = j.status == 'pending';
                        if (!isPending) return const SizedBox.shrink();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
              IconButton(
                              tooltip: 'Aprovar',
                              color: Colors.green,
                              onPressed: () async {
                await context.read<EscalaService>().updateJustificationStatus(j.id, 'approved');
                if (!mounted) return;
                setState(() {});
                              },
                              icon: const Icon(Icons.check_circle),
                            ),
              IconButton(
                              tooltip: 'Rejeitar',
                              color: Colors.red,
                              onPressed: () async {
                await context.read<EscalaService>().updateJustificationStatus(j.id, 'rejected');
                if (!mounted) return;
                setState(() {});
                              },
                              icon: const Icon(Icons.cancel),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: data.length,
      );
        },
    ),
    ),
    );
  }
}
