import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/features/laboratory/data/models/analysis_type_model.dart';
import 'package:smartlaboratory/features/laboratory/data/models/lab_session_model.dart';

class LaboratoryRepository {
  final DioClient _client = DioClient.instance;

  Future<List<AnalysisTypeModel>> getAnalysisTypes() async {
    final response = await _client.get('laboratory/analysis-types/');
    return (response.data as List<dynamic>)
        .map((item) => AnalysisTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AnalysisTypeModel> createAnalysisType({
    required String name,
    required int durationMinutes,
    required double price,
  }) async {
    final response = await _client.post(
      'laboratory/analysis-types/',
      data: {'name': name, 'duration_minutes': durationMinutes, 'price': price},
    );
    return AnalysisTypeModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<int> createSession({
    required int analysisTypeId,
    required int sampleCount,
    String comment = '',
  }) async {
    final response = await _client.post(
      Endpoints.laboratorySessions,
      data: {
        'analysis_type': analysisTypeId,
        'sample_count': sampleCount,
        'comment': comment,
      },
    );
    return response.data['id'] as int;
  }

  Future<List<LabSessionModel>> getSessions() async {
    final response = await _client.get(Endpoints.laboratorySessions);
    return (response.data as List<dynamic>)
        .map((item) => LabSessionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<LabSessionModel> getSession(int sessionId) async {
    final response = await _client.get(
      '${Endpoints.laboratorySessions}$sessionId/',
    );
    return LabSessionModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> startSession(int sessionId) async {
    await _client.dio.patch('${Endpoints.laboratorySessions}$sessionId/start/');
  }

  Future<void> validateSession(
    int sessionId, {
    required List<Map<String, dynamic>> consumptions,
    required List<Map<String, dynamic>> losses,
  }) async {
    await _client.dio.post(
      '${Endpoints.laboratorySessions}$sessionId/validate/',
      data: {'consumptions': consumptions, 'losses': losses},
    );
  }
}
