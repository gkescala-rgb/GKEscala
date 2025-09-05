import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final FlutterSecureStorage storage;
  static const _key = 'theme_mode';

  ThemeCubit({required this.storage}) : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final v = await storage.read(key: _key);
    if (v == 'dark') emit(ThemeMode.dark);
    if (v == 'light') emit(ThemeMode.light);
    if (v == 'system') emit(ThemeMode.system);
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await storage.write(key: _key, value: _toStr(mode));
  }

  String _toStr(ThemeMode m) => m == ThemeMode.dark
      ? 'dark'
      : m == ThemeMode.system
          ? 'system'
          : 'light';
}
