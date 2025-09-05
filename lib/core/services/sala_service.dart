import '../network/api_client.dart';
import '../../shared/models/sala.dart';

class SalaService {
  final ApiClient _apiClient;

  SalaService(this._apiClient);

  Future<List<Sala>> getAllSalas() async {
  final response = await _apiClient.get('salas');
    final List<dynamic> data = response.data;
    return data.map((json) => Sala.fromJson(json)).toList();
  }

  Future<Sala> getSala(int id) async {
  final response = await _apiClient.get('salas/$id');
    return Sala.fromJson(response.data);
  }

  Future<Sala> createSala(Map<String, dynamic> data) async {
  final response = await _apiClient.post('salas', data: data);
    return Sala.fromJson(response.data);
  }

  Future<void> updateSala(int id, Map<String, dynamic> data) async {
    await _apiClient.patch('salas/$id', data: data);
  }

  Future<void> deleteSala(int id) async {
  await _apiClient.delete('salas/$id');
  }
}
