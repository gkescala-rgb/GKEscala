import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../core/theme/theme_cubit.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              final auth = context.read<AuthBloc>().state;
              final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;
              context.go(isAdmin ? '/dashboard/admin' : '/dashboard/professor');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aparência', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                return Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: mode,
                      onChanged: (m) => context.read<ThemeCubit>().setMode(ThemeMode.light),
                      title: const Text('Claro'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: mode,
                      onChanged: (m) => context.read<ThemeCubit>().setMode(ThemeMode.dark),
                      title: const Text('Escuro'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: mode,
                      onChanged: (m) => context.read<ThemeCubit>().setMode(ThemeMode.system),
                      title: const Text('Sistema'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Trocar senha'),
              onTap: () => context.push('/configuracoes/trocar-senha'),
            ),
          ],
        ),
      ),
    );
  }
}
