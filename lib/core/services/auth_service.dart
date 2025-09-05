import '../network/api_client.dart';
import '../../shared/models/auth_user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthUser> login(String email, String password) async {
  final response = await _apiClient.post('auth/login', data: {
      'email': email,
      'password': password,
    });

    return AuthUser.fromJson(response.data);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
  await _apiClient.post('auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  // Após registrar, efetua login para obter token e dados do usuário
  return login(email, password);
  }

  Future<void> logout() async {
    // Limpar token local - o backend não tem endpoint de logout
    // O token JWT expira automaticamente
  }
}
