import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../../shared/models/escala_today.dart';
import '../../shared/models/justification.dart';

class EscalaService {
  final ApiClient _apiClient;

  EscalaService(this._apiClient);

  Future<List<EscalaToday>> getTodayScale() async {
  final response = await _apiClient.get('scale');
  final dynamic body = response.data;
  final List<dynamic> data = body is Map<String, dynamic> ? (body['scale'] as List<dynamic>? ?? []) : (body as List<dynamic>? ?? []);
    return data.map((json) => EscalaToday.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> generateTodayScale() async {
    await _apiClient.post('scale/generate');
  }

  Future<void> resetTodayScale() async {
    await _apiClient.post('scale/reset');
  }

  Future<void> deleteEscala(int id) async {
    await _apiClient.delete('scale/$id');
  }

  Future<void> updateAvailability(int professorId, List<Map<String, dynamic>> dates) async {
  await _apiClient.post('scale/availability', data: {
      'professorId': professorId.toString(),
      'dates': dates,
    });
  }

  Future<void> createJustification(Map<String, dynamic> justificationData) async {
    await _apiClient.post('scale/justification', data: justificationData);
    // Nest retorna apenas { message: string }
    return;
  }

  Future<void> createJustificationMultipart(
    Map<String, dynamic> data, {
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    dynamic payload = data;
    var options = Options();
    if (filePath != null || fileBytes != null) {
      final file = filePath != null
          ? await MultipartFile.fromFile(filePath)
          : MultipartFile.fromBytes(fileBytes!, filename: fileName ?? 'upload.bin');
      payload = FormData.fromMap({
        ...data,
        'file': file,
      });
      options = Options(contentType: 'multipart/form-data');
    }
    await _apiClient.post('scale/justification', data: payload, options: options);
  }

  Future<Response<List<int>>> downloadJustificationBlob(int id) async {
    final resp = await _apiClient.get<List<int>>('scale/justification/$id/download', options: Options(responseType: ResponseType.bytes));
    return resp;
  }

  Future<Map<String, dynamic>> getPresenceStats() async {
  final response = await _apiClient.get('scale/presence');
  return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Justification>> getAllJustifications() async {
  final response = await _apiClient.get('scale/justifications');
  final List<dynamic> data = response.data as List<dynamic>;
  return data.map((json) => Justification.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> updateJustificationStatus(int id, String status) async {
  await _apiClient.post('scale/justification/$id/status', data: {
      'status': status,
    });
    // Retorna { message: string }
    return;
  }
}
