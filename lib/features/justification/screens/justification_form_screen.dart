import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/escala_service.dart';
import '../../../core/services/sala_service.dart';
import '../../../shared/models/sala.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class JustificationFormScreen extends StatefulWidget {
  const JustificationFormScreen({super.key});

  @override
  State<JustificationFormScreen> createState() => _JustificationFormScreenState();
}

class _JustificationFormScreenState extends State<JustificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  Sala? _selectedSala;
  String? _uploadedFileUrl; // legado por URL (não usado no blob inline)
  String? _pendingLocalFilePath;
  List<int>? _pendingFileBytes;
  String? _pendingFileName;
  String _tipo = 'falta';
  DateTime? _data;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;
    final f = result.files.single;
    setState(() {
      _pendingLocalFilePath = kIsWeb ? null : f.path;
      _pendingFileBytes = kIsWeb ? f.bytes : null;
      _pendingFileName = f.name;
      _uploadedFileUrl = null; // prefer blob over legacy URL
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final escalaService = context.read<EscalaService>();
    try {
      // Envia como multipart se houver arquivo selecionado
      await escalaService.createJustificationMultipart({
        'message': _motivoCtrl.text.trim(),
        'tipo': _tipo,
        if (_data != null) 'date': _data!.toIso8601String().substring(0,10),
      }, filePath: _pendingLocalFilePath, fileBytes: _pendingFileBytes, fileName: _pendingFileName);
      setState(() {
        _pendingLocalFilePath = null;
        _pendingFileBytes = null;
        _pendingFileName = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Justificativa enviada')),
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
        title: const Text('Nova Justificativa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FutureBuilder<List<Sala>>(
                future: context.read<SalaService>().getAllSalas(),
                builder: (context, snapshot) {
                  final salas = (snapshot.data ?? []).where((s) => s.ativo).toList();
                  if (salas.isEmpty) return const SizedBox.shrink();
                  return DropdownButtonFormField<Sala>(
                    value: _selectedSala,
                    items: salas
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.nome)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSala = v),
                    decoration: const InputDecoration(labelText: 'Sala (opcional)'),
                  );
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'falta', child: Text('Falta')),
                  DropdownMenuItem(value: 'troca', child: Text('Troca')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'falta'),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy),
                title: Text(
                  _data == null
                      ? 'Selecionar dia da falta/troca (opcional)'
                      : 'Dia selecionado: ${_data!.day.toString().padLeft(2,'0')}/${_data!.month.toString().padLeft(2,'0')}/${_data!.year}',
                ),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoCtrl,
                decoration: const InputDecoration(labelText: 'Motivo'),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o motivo' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Anexar arquivo'),
                  ),
                  const SizedBox(width: 12),
                  if (_uploadedFileUrl != null || _pendingLocalFilePath != null || _pendingFileBytes != null)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar'),
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
