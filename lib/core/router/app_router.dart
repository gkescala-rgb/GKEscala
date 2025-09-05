import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/escala/screens/escala_screen.dart';
import '../../features/escala/screens/availability_screen.dart';
import '../../features/professor/screens/professor_list_screen.dart';
import '../../features/sala/screens/sala_list_screen.dart';
import '../../features/tema/screens/tema_list_screen.dart';
import '../../features/justification/screens/justification_list_screen.dart';
import '../../features/justification/screens/justification_form_screen.dart';
import '../../features/sala/screens/sala_form_screen.dart';
import '../../features/tema/screens/tema_form_screen.dart';
import '../../features/professor/screens/professor_form_screen.dart';
import '../../features/professor/screens/professor_edit_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/change_password_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../core/theme/theme_cubit.dart';
import '../../features/reports/reports_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    // Reavalia redirects quando o AuthBloc muda
    final refresh = GoRouterRefreshStream(context.read<AuthBloc>().stream);

    return GoRouter(
      initialLocation: '/login',
      refreshListenable: refresh,
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;

        final isLoggedIn = authState is AuthAuthenticated;
        final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
        final loggingRoutes = {'/login', '/register'};
        final loc = state.matchedLocation;

        // Bloqueia acesso sem login
        if (!isLoggedIn && !loggingRoutes.contains(loc)) {
          return '/login';
        }

        // Envia para dashboard adequado após login
        if (isLoggedIn && loggingRoutes.contains(loc)) {
          return isAdmin ? '/dashboard/admin' : '/dashboard/professor';
        }

        // Admin only guards
        final adminOnly = {
          '/dashboard/admin',
          '/justificacoes',
          '/relatorios',
          '/professores',
          '/professores/novo',
          '/salas/nova',
          '/temas/novo',
        };
        if (adminOnly.contains(loc) && !isAdmin) {
          return '/dashboard/professor';
        }

        // Normaliza /dashboard raiz para subrota por papel
        if (loc == '/dashboard') {
          return isAdmin ? '/dashboard/admin' : '/dashboard/professor';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            // Dashboards por papel
            GoRoute(
              path: '/dashboard/admin',
              name: 'dashboard_admin',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/dashboard/professor',
              name: 'dashboard_professor',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/escala',
              name: 'escala',
              builder: (context, state) => const EscalaScreen(),
            ),
            GoRoute(
              path: '/escala/disponibilidade',
              name: 'escala_disponibilidade',
              builder: (context, state) => const AvailabilityScreen(),
            ),
            GoRoute(
              path: '/professores',
              name: 'professores',
              builder: (context, state) => const ProfessorListScreen(),
            ),
            GoRoute(
              path: '/professores/novo',
              name: 'professor_novo',
              builder: (context, state) => const ProfessorFormScreen(),
            ),
            GoRoute(
              path: '/professores/:id/editar',
              name: 'professor_editar',
              builder: (context, state) => ProfessorEditScreen(id: int.parse(state.pathParameters['id']!)),
            ),
            GoRoute(
              path: '/salas',
              name: 'salas',
              builder: (context, state) => const SalaListScreen(),
            ),
            GoRoute(
              path: '/salas/nova',
              name: 'sala_nova',
              builder: (context, state) => const SalaFormScreen(),
            ),
            GoRoute(
              path: '/salas/:id/editar',
              name: 'sala_editar',
              builder: (context, state) => SalaFormScreen(id: int.tryParse(state.pathParameters['id'] ?? '')),
            ),
            GoRoute(
              path: '/temas',
              name: 'temas',
              builder: (context, state) => const TemaListScreen(),
            ),
            GoRoute(
              path: '/temas/novo',
              name: 'tema_novo',
              builder: (context, state) => const TemaFormScreen(),
            ),
            GoRoute(
              path: '/temas/:id/editar',
              name: 'tema_editar',
              builder: (context, state) => TemaFormScreen(id: int.tryParse(state.pathParameters['id'] ?? '')),
            ),
            GoRoute(
              path: '/justificacoes',
              name: 'justificacoes',
              builder: (context, state) => const JustificationListScreen(),
            ),
            GoRoute(
              path: '/relatorios',
              name: 'relatorios',
              builder: (context, state) => const ReportsScreen(),
            ),
            GoRoute(
              path: '/justificativa/nova',
              name: 'justificativa_nova',
              builder: (context, state) => const JustificationFormScreen(),
            ),
          ],
            ),
            GoRoute(
              path: '/configuracoes',
              name: 'configuracoes',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/configuracoes/trocar-senha',
              name: 'configuracoes_trocar_senha',
              builder: (context, state) => const ChangePasswordScreen(),
            ),
            GoRoute(
              path: '/perfil',
              name: 'perfil',
              builder: (context, state) => const ProfileScreen(),
            ),
      ],
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Escalas'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text('Alternar tema'),
                ),
                onTap: () {
                  final cubit = context.read<ThemeCubit>();
                  final isDark = (cubit.state == ThemeMode.dark);
                  cubit.setMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Perfil'),
                ),
                onTap: () {
                  Future.microtask(() => context.push('/perfil'));
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                ),
                onTap: () {
                  Future.microtask(() => context.push('/configuracoes'));
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Escalas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              final state = context.read<AuthBloc>().state;
              final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
              context.go(isAdmin ? '/dashboard/admin' : '/dashboard/professor');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Escala'),
            onTap: () {
              context.go('/escala');
              Navigator.pop(context);
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isAdmin = state is AuthAuthenticated && state.user.isAdmin;
              if (!isAdmin) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Professores'),
                onTap: () {
                  context.go('/professores');
                  Navigator.pop(context);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.room),
            title: const Text('Salas'),
            onTap: () {
              context.go('/salas');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.topic),
            title: const Text('Temas'),
            onTap: () {
              context.go('/temas');
              Navigator.pop(context);
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.user.isAdmin) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Justificações'),
                      onTap: () {
                        context.push('/justificacoes');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Relatórios'),
                      onTap: () {
                        context.push('/relatorios');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              }
              // Opções do professor
              if (state is AuthAuthenticated) {
        return ListTile(
                  leading: const Icon(Icons.note_add),
                  title: const Text('Nova Justificativa'),
                  onTap: () {
          context.push('/justificativa/nova');
                    Navigator.pop(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// Utilitário para o GoRouter reavaliar redirects quando um Stream emite
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }

  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
