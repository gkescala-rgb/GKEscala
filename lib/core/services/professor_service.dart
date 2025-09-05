import '../network/api_client.dart';
import '../../shared/models/professor.dart';

class ProfessorService {
  final ApiClient _apiClient;

  ProfessorService(this._apiClient);

  Future<List<Professor>> getAllProfessors() async {
  final response = await _apiClient.get('professors');
    final List<dynamic> data = response.data;
    return data.map((json) => Professor.fromJson(json)).toList();
  }

  Future<Professor> getProfessor(int id) async {
  final response = await _apiClient.get('professors/$id');
    return Professor.fromJson(response.data);
  }

  Future<void> updateProfessor(int id, Map<String, dynamic> data) async {
    await _apiClient.patch('professors/$id', data: data);
  }

  Future<void> deleteProfessor(int id) async {
    await _apiClient.delete('professors/$id');
  }

  Future<void> createProfessor({required String name, required String email, required String password, String role = 'professor'}) async {
    await _apiClient.post('auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<void> updatePreferences(int id, List<String> preferencias) async {
    await _apiClient.post('professors/$id/preferences', data: {
      'preferencias': preferencias,
    });
  }

  Future<void> promoteToAdmin(int id) async {
    await _apiClient.post('professors/$id/promote');
  }
}
