import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/tema_service.dart';
import '../../../shared/models/tema.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/utils/download_helper.dart';

class TemaListScreen extends StatefulWidget {
  const TemaListScreen({super.key});

  @override
  State<TemaListScreen> createState() => _TemaListScreenState();
}

class _TemaListScreenState extends State<TemaListScreen> {

  @override
  Widget build(BuildContext context) {
    final temaService = context.read<TemaService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temas'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
            if (!isAdmin) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Novo',
              onPressed: () async {
                await context.push('/temas/novo');
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
        child: FutureBuilder<List<Tema>>(
          future: temaService.getAllTemas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Nenhum tema encontrado'));
          }
            return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final tema = data[index];
              return ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.15),
                  child: Icon(Icons.topic, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(tema.nome),
        subtitle: (tema.descricao != null && tema.descricao!.isNotEmpty)
            ? Text(
                tema.descricao!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Row(
                    children: [
                      Text(
                        'Criado: ${tema.createdAt.day.toString().padLeft(2, '0')}/${tema.createdAt.month.toString().padLeft(2, '0')}/${tema.createdAt.year}' +
                        (tema.data != null ? ' • Data: ${tema.data!.day.toString().padLeft(2,'0')}/${tema.data!.month.toString().padLeft(2,'0')}/${tema.data!.year}' : ''),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                        final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
                        if (!isAdmin) return const SizedBox.shrink();
                        return IconButton(
                          tooltip: 'Editar',
                          onPressed: () async {
                            await context.push('/temas/${tema.id}/editar');
                            if (!mounted) return;
                            setState(() {});
                          },
                          icon: const Icon(Icons.edit),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (tema.fileUrl != null && tema.fileUrl!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(tema.fileUrl!);
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Não foi possível abrir o arquivo')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Baixar arquivo'),
                      ),
                    ),
                  // Botão para baixar blob salvo no banco
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        try {
                          final resp = await context.read<TemaService>().downloadFileBlob(tema.id);
                          final bytes = resp.data;
                          if (bytes == null || bytes.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sem arquivo no banco')));
                            }
                            return;
                          }
                          String fileName = tema.fileName ?? 'tema_${tema.id}';
                          if (!fileName.contains('.')) {
                            // best-effort extension from mime
                            final mime = tema.mimeType ?? '';
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
                      label: const Text('Baixar do banco'),
                    ),
                  ),
                ],
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
