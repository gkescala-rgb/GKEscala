import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../../shared/models/tema.dart';

class TemaService {
  final ApiClient _apiClient;

  TemaService(this._apiClient);

  Future<List<Tema>> getAllTemas() async {
  final response = await _apiClient.get('temas');
    final List<dynamic> data = response.data;
    return data.map((json) => Tema.fromJson(json)).toList();
  }

  Future<Tema> getTema(int id) async {
  final response = await _apiClient.get('temas/$id');
    return Tema.fromJson(response.data);
  }

  Future<Tema> createTema(
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
    final response = await _apiClient.post('temas', data: payload, options: options);
    return Tema.fromJson(response.data);
  }

  Future<Tema> updateTema(
    int id,
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
    final response = await _apiClient.patch('temas/$id', data: payload, options: options);
    return Tema.fromJson(response.data);
  }

  Future<String> uploadFile(String filePath) async {
    final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
    final response = await _apiClient.post('temas/upload', data: formData, options: Options(contentType: 'multipart/form-data'));
    return (response.data as Map<String, dynamic>)['file'] as String;
  }

  Future<void> uploadFileBlob(int temaId, String filePath) async {
    final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
    await _apiClient.post('temas/$temaId/upload-blob', data: formData, options: Options(contentType: 'multipart/form-data'));
  }

  Future<Response<List<int>>> downloadFileBlob(int temaId) async {
    final resp = await _apiClient.get<List<int>>('temas/$temaId/download', options: Options(responseType: ResponseType.bytes));
    return resp;
  }
}
