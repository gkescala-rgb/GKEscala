import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/sala_service.dart';

class SalaFormScreen extends StatefulWidget {
  final int? id;
  const SalaFormScreen({super.key, this.id});

  @override
  State<SalaFormScreen> createState() => _SalaFormScreenState();
}

class _SalaFormScreenState extends State<SalaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _capacidadeCtrl = TextEditingController();
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      // Load existing sala
      Future.microtask(() async {
        final sala = await context.read<SalaService>().getSala(widget.id!);
        if (!mounted) return;
        _nomeCtrl.text = sala.nome;
        _capacidadeCtrl.text = sala.capacidade.toString();
        _ativo = sala.ativo;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _capacidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      if (widget.id == null) {
        await context.read<SalaService>().createSala({
          'nome': _nomeCtrl.text.trim(),
          if (_capacidadeCtrl.text.trim().isNotEmpty)
            'capacidade': int.tryParse(_capacidadeCtrl.text.trim()),
          'ativo': _ativo,
        });
      } else {
        await context.read<SalaService>().updateSala(widget.id!, {
          'nome': _nomeCtrl.text.trim(),
          if (_capacidadeCtrl.text.trim().isNotEmpty)
            'capacidade': int.tryParse(_capacidadeCtrl.text.trim()),
          'ativo': _ativo,
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.id == null ? 'Sala criada' : 'Sala atualizada')),
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
  title: Text(widget.id == null ? 'Nova Sala' : 'Editar Sala'),
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
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacidadeCtrl,
                decoration: const InputDecoration(labelText: 'Capacidade'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Ativa'),
                value: _ativo,
                onChanged: (v) => setState(() => _ativo = v),
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
