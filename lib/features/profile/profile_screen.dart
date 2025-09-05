import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              // Fallback para dashboard correto por papel
              final auth = context.read<AuthBloc>().state;
              final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;
              context.go(isAdmin ? '/dashboard/admin' : '/dashboard/professor');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state is AuthAuthenticated
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(state.user.name),
                    subtitle: const Text('Nome'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(state.user.email),
                    subtitle: const Text('Email'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: Text(state.user.role),
                    subtitle: const Text('Permissão'),
                  ),
                ],
              )
            : const Center(child: Text('Não autenticado')),
      ),
    );
  }
}
