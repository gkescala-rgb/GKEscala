import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/tema_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/utils/download_helper.dart';

class TemaFormScreen extends StatefulWidget {
  final int? id;
  const TemaFormScreen({super.key, this.id});

  @override
  State<TemaFormScreen> createState() => _TemaFormScreenState();
}

class _TemaFormScreenState extends State<TemaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  String? _fileUrl; // legado por URL (não usado no blob inline)
  String? _pendingLocalFilePath;
  List<int>? _pendingFileBytes; // para Web (ou quando path não disponível)
  String? _pendingFileName;
  DateTime? _data;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      Future.microtask(() async {
        final tema = await context.read<TemaService>().getTema(widget.id!);
        if (!mounted) return;
        _tituloCtrl.text = tema.nome;
        _descricaoCtrl.text = tema.descricao ?? '';
  _fileUrl = tema.fileUrl;
  _data = tema.data;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;
    final f = result.files.single;
    final name = f.name;

    // Se já existe um tema (edição), subimos direto via PATCH multipart
    if (widget.id != null) {
      if (kIsWeb) {
        final bytes = f.bytes;
        if (bytes == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao ler arquivo')));
          return;
        }
        await context.read<TemaService>().updateTema(
              widget.id!,
              {},
              fileBytes: bytes,
              fileName: name,
            );
      } else {
        final path = f.path; // seguro fora do Web
        if (path == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao ler caminho do arquivo')));
          return;
        }
        await context.read<TemaService>().updateTema(
              widget.id!,
              {},
              filePath: path,
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arquivo salvo no banco')));
    } else {
      // No modo criação, guarda o arquivo para subir junto no POST
      if (kIsWeb) {
        final bytes = f.bytes;
        setState(() {
          _pendingLocalFilePath = null;
          _pendingFileBytes = bytes;
          _pendingFileName = name;
        });
      } else {
        setState(() {
          _pendingLocalFilePath = f.path;
          _pendingFileBytes = null;
          _pendingFileName = name;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      if (widget.id == null) {
        await context.read<TemaService>().createTema({
          'nome': _tituloCtrl.text.trim(),
          'descricao': _descricaoCtrl.text.trim(),
          if (_data != null) 'data': _data!.toIso8601String().substring(0,10),
        },
            filePath: _pendingLocalFilePath,
            fileBytes: _pendingFileBytes,
            fileName: _pendingFileName,
        );
        // limpar seleção após criar
        setState(() {
          _pendingLocalFilePath = null;
          _pendingFileBytes = null;
          _pendingFileName = null;
        });
      } else {
        await context.read<TemaService>().updateTema(widget.id!, {
          'nome': _tituloCtrl.text.trim(),
          'descricao': _descricaoCtrl.text.trim(),
          if (_data != null) 'data': _data!.toIso8601String().substring(0,10),
        },
            filePath: _pendingLocalFilePath,
            fileBytes: _pendingFileBytes,
            fileName: _pendingFileName,
        );
        setState(() {
          _pendingLocalFilePath = null;
          _pendingFileBytes = null;
          _pendingFileName = null;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.id == null ? 'Tema criado' : 'Tema atualizado')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(widget.id == null ? 'Novo Tema' : 'Editar Tema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(_data == null
                    ? 'Selecionar data (opcional)'
                    : 'Data: ${_data!.day.toString().padLeft(2,'0')}/${_data!.month.toString().padLeft(2,'0')}/${_data!.year}'),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _data ?? now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null) setState(() => _data = picked);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Anexar arquivo'),
                  ),
                  const SizedBox(width: 12),
                  if (_fileUrl != null || _pendingLocalFilePath != null || _pendingFileBytes != null)
                    const Icon(Icons.check_circle, color: Colors.green),
                  if (_fileUrl != null && widget.id == null) ...[
                    const SizedBox(width: 8),
                    const Flexible(child: Text('Arquivo via URL pronto. Para salvar no banco, edite após criar e anexe novamente.', style: TextStyle(fontSize: 12)))
                  ],
                  const SizedBox(width: 12),
                  if (widget.id != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final resp = await context.read<TemaService>().downloadFileBlob(widget.id!);
                          final bytes = resp.data;
                          if (bytes == null || bytes.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sem arquivo no banco')));
                            }
                            return;
                          }
                          // Try to use server-provided filename/mime via fetching current Tema again
                          String fileName = 'tema_${widget.id}';
                          try {
                            final t = await context.read<TemaService>().getTema(widget.id!);
                            fileName = t.fileName ?? fileName;
                            if (!fileName.contains('.')) {
                              final mime = t.mimeType ?? '';
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
                          } catch (_) {}
                          await DownloadHelper.saveBytes(bytes: bytes, fileName: fileName);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao baixar: $e')));
                          }
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Baixar arquivo'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
