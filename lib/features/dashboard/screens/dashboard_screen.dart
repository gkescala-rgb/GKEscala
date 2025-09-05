import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/escala_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com boas-vindas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange,
                        AppTheme.primaryTerracotta,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${state.user.name}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestão de Escalas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      if (state.user.isAdmin) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Administrador',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Grid de cards principais
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _DashboardCard(
                      title: 'Escala de Hoje',
                      subtitle: 'Ver escala atual',
                      icon: Icons.calendar_today,
                      color: AppTheme.primaryOrange,
                      onTap: () {
                        context.push('/escala');
                      },
                    ),
                    if (state.user.isAdmin)
                      _DashboardCard(
                        title: 'Professores',
                        subtitle: 'Gerenciar professores',
                        icon: Icons.people,
                        color: AppTheme.primaryTerracotta,
                        onTap: () {
                          context.push('/professores');
                        },
                      ),
                    _DashboardCard(
                      title: 'Salas',
                      subtitle: 'Gerenciar salas',
                      icon: Icons.room,
                      color: AppTheme.accentOrange,
                      onTap: () {
                        context.push('/salas');
                      },
                    ),
                    _DashboardCard(
                      title: 'Temas',
                      subtitle: 'Gerenciar temas',
                      icon: Icons.topic,
                      color: AppTheme.primaryOrange,
                      onTap: () {
                        context.push('/temas');
                      },
                    ),
                  ],
                ),

                if (state.user.isAdmin) ...[
                  const SizedBox(height: 24),
                  
                  Text(
                    'Área Administrativa',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _DashboardCard(
                        title: 'Justificações',
                        subtitle: 'Revisar justificações',
                        icon: Icons.description,
                        color: AppTheme.primaryTerracotta,
                        onTap: () {
                          context.push('/justificacoes');
                        },
                      ),
            _DashboardCard(
                        title: 'Relatórios',
                        subtitle: 'Ver estatísticas',
                        icon: Icons.analytics,
                        color: AppTheme.accentOrange,
                        onTap: () {
              context.push('/relatorios');
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Card de estatísticas rápidas (com dados reais)
                _QuickStats(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminService>();
    final escala = context.read<EscalaService>();
    final isAdmin = context.select<AuthBloc, bool>((b) => b.state is AuthAuthenticated && (b.state as AuthAuthenticated).user.isAdmin);

    Future<Map<String, dynamic>> future;
    if (isAdmin) {
      future = Future.wait([
        admin.getReport(),
        escala.getPresenceStats(),
      ]).then((values) => {
            'report': values[0],
            'presence': values[1],
          });
    } else {
      future = escala.getPresenceStats().then((presence) => {
            'report': const <String, dynamic>{},
            'presence': presence,
          });
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar resumo: ${snapshot.error}'),
          );
        }
  final report = Map<String, dynamic>.from(snapshot.data?['report'] ?? {});
        final presence = Map<String, dynamic>.from(snapshot.data?['presence'] ?? {});

        final escalasHoje = presence.values.fold<int>(0, (a, b) => a + (b is num ? b.toInt() : 0));
  final profs = report['totalProfessores']?.toString() ?? '-';
  final salas = report['totalSalas']?.toString() ?? '-';
  final totalEscalas = report['totalEscalas']?.toString() ?? '-';
  final faltas = report['faltas']?.toString() ?? '-';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo Rápido',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Escalas Hoje',
                        value: '$escalasHoje',
                        icon: Icons.today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Professores',
                        value: profs,
                        icon: Icons.people_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Salas',
                        value: salas,
                        icon: Icons.meeting_room,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Escalas',
                        value: totalEscalas,
                        icon: Icons.pending_actions,
                      ),
                    ),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Faltas',
                          value: faltas,
                          icon: Icons.report,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
