import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import '../models/ai_recommendation_model.dart';

class AIRecommendationsRepository {
  final DioClient _dioClient;

  AIRecommendationsRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  /// Récupère toutes les recommandations d'analyse IA
  Future<List<AIRecommendation>> getRecommendations({
    String? priority,
    String? analysisType,
    bool? isResolved,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (priority != null) queryParameters['priority'] = priority;
      if (analysisType != null) queryParameters['analysis_type'] = analysisType;
      if (isResolved != null) queryParameters['is_resolved'] = isResolved;

      final response = await _dioClient.dio.get(
        '${Endpoints.baseUrl}ai/analyses/',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      if (response.statusCode == 200) {
        List<dynamic> results = [];
        if (response.data is List<dynamic>) {
          results = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          results = data['results'] as List<dynamic>? ?? [];
        }
        return results
            .map(
              (json) => AIRecommendation.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Erreur lors du chargement des recommandations');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Récupère uniquement les alertes critiques
  Future<List<AIRecommendation>> getCriticalAlerts() async {
    try {
      final response = await _dioClient.dio.get(
        '${Endpoints.baseUrl}ai/analyses/critical_only/',
      );

      if (response.statusCode == 200) {
        List<dynamic> results = [];
        if (response.data is List<dynamic>) {
          results = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          results = data['results'] as List<dynamic>? ?? [];
        }
        return results
            .map(
              (json) => AIRecommendation.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Erreur lors du chargement des alertes critiques');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Lance l'analyse IA complète du stock
  Future<Map<String, dynamic>> runAnalysis({int daysLookback = 30}) async {
    try {
      final response = await _dioClient.dio.post(
        '${Endpoints.baseUrl}ai/analyses/run_analysis/',
        data: {'days_lookback': daysLookback},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors du lancement de l\'analyse');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Marque une analyse comme résolue
  Future<void> markAsResolved(int id) async {
    try {
      final response = await _dioClient.dio.post(
        '${Endpoints.baseUrl}ai/analyses/$id/mark_resolved/',
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Marque toutes les analyses d'un type comme résolues
  Future<void> resolveAll(String analysisType) async {
    try {
      final response = await _dioClient.dio.post(
        '${Endpoints.baseUrl}ai/analyses/resolve_all/',
        data: {'analysis_type': analysisType},
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
