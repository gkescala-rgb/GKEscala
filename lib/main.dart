import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/network/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/professor_service.dart';
import 'core/services/sala_service.dart';
import 'core/services/tema_service.dart';
import 'core/services/escala_service.dart';
import 'core/services/admin_service.dart';
import 'core/router/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider<FlutterSecureStorage>.value(value: _storage),
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(_apiClient),
        ),
        RepositoryProvider<ProfessorService>(
          create: (context) => ProfessorService(_apiClient),
        ),
        RepositoryProvider<SalaService>(
          create: (context) => SalaService(_apiClient),
        ),
        RepositoryProvider<TemaService>(
          create: (context) => TemaService(_apiClient),
        ),
        RepositoryProvider<EscalaService>(
          create: (context) => EscalaService(_apiClient),
        ),
        RepositoryProvider<AdminService>(
          create: (context) => AdminService(_apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
              storage: context.read<FlutterSecureStorage>(),
            )..add(AuthStarted()),
          ),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(storage: context.read<FlutterSecureStorage>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final router = AppRouter.createRouter(context);
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                return MaterialApp.router(
                  title: 'Escalas',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: mode,
                  routerConfig: router,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
