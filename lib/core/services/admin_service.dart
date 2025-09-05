import '../network/api_client.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  Future<Map<String, dynamic>> getReport() async {
    final res = await _apiClient.get('admin/report');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
