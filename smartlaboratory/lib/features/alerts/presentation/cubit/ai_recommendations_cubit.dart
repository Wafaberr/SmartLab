import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/ai_recommendations_repository.dart';
import 'ai_recommendations_state.dart';

class AIRecommendationsCubit extends Cubit<AIRecommendationsState> {
  final AIRecommendationsRepository _repository;

  AIRecommendationsCubit(this._repository) : super(AIRecommendationsInitial());

  /// Charge toutes les recommandations
  Future<void> loadRecommendations({
    String? priority,
    String? analysisType,
    bool? isResolved,
  }) async {
    emit(AIRecommendationsLoading());
    try {
      final recommendations = await _repository.getRecommendations(
        priority: priority,
        analysisType: analysisType,
        isResolved: isResolved,
      );

      final criticalCount = recommendations
          .where((r) => r.priority == 'critical' && !r.isResolved)
          .length;
      final highCount = recommendations
          .where((r) => r.priority == 'high' && !r.isResolved)
          .length;

      emit(
        AIRecommendationsLoaded(
          recommendations: recommendations,
          criticalCount: criticalCount,
          highCount: highCount,
        ),
      );
    } catch (e) {
      emit(AIRecommendationsError(message: e.toString()));
    }
  }

  /// Charge uniquement les alertes critiques
  Future<void> loadCriticalAlerts() async {
    emit(AIRecommendationsLoading());
    try {
      final recommendations = await _repository.getCriticalAlerts();
      emit(
        AIRecommendationsLoaded(
          recommendations: recommendations,
          criticalCount: recommendations.length,
          highCount: 0,
        ),
      );
    } catch (e) {
      emit(AIRecommendationsError(message: e.toString()));
    }
  }

  /// Lance l'analyse IA
  Future<void> runAnalysis({int daysLookback = 30}) async {
    emit(AIRecommendationsAnalyzing());
    try {
      final result = await _repository.runAnalysis(daysLookback: daysLookback);
      emit(
        AIRecommendationsAnalysisComplete(
          message: result['message'] as String? ?? 'Analyse complétée',
          summary: result['summary'] as Map<String, dynamic>? ?? {},
        ),
      );
      // Recharger les recommandations après l'analyse
      await Future.delayed(const Duration(milliseconds: 500));
      await loadRecommendations();
    } catch (e) {
      emit(AIRecommendationsError(message: e.toString()));
    }
  }

  /// Marque une recommandation comme résolue
  Future<void> markAsResolved(int id) async {
    emit(AIRecommendationsSaving());
    try {
      await _repository.markAsResolved(id);
      emit(AIRecommendationsSuccess(message: 'Alerte marquée comme résolue'));
      await Future.delayed(const Duration(milliseconds: 500));
      await loadRecommendations();
    } catch (e) {
      emit(AIRecommendationsError(message: e.toString()));
    }
  }

  /// Marque toutes les analyses d'un type comme résolues
  Future<void> resolveAll(String analysisType) async {
    emit(AIRecommendationsSaving());
    try {
      await _repository.resolveAll(analysisType);
      emit(
        AIRecommendationsSuccess(
          message: 'Toutes les alertes marquées comme résolues',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      await loadRecommendations();
    } catch (e) {
      emit(AIRecommendationsError(message: e.toString()));
    }
  }
}
