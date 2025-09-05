import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/professor_service.dart';
import '../../../shared/models/professor.dart';

class ProfessorEditScreen extends StatefulWidget {
  final int id;
  const ProfessorEditScreen({super.key, required this.id});

  @override
  State<ProfessorEditScreen> createState() => _ProfessorEditScreenState();
}

class _ProfessorEditScreenState extends State<ProfessorEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final svc = context.read<ProfessorService>();
      final Professor p = await svc.getProfessor(widget.id);
      if (!mounted) return;
      _nomeCtrl.text = p.name;
      _emailCtrl.text = p.email;
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final svc = context.read<ProfessorService>();
    try {
      final data = {
        'name': _nomeCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        if (_senhaCtrl.text.isNotEmpty) 'password': _senhaCtrl.text,
      };
      await svc.updateProfessor(widget.id, data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professor atualizado')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Professor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v == null || !v.contains('@') ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senhaCtrl,
                      decoration: const InputDecoration(labelText: 'Nova senha (opcional)'),
                      obscureText: true,
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