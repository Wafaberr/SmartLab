import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ai_recommendation_model.dart';
import '../../data/repository/ai_recommendations_repository.dart';

part 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  final AIRecommendationsRepository _repository;

  AlertsCubit({required this._repository}) : super(AlertsInitial());

  Future<void> getRecommendations({
    String? priority,
    String? analysisType,
    bool? isResolved,
  }) async {
    emit(AlertsLoading());
    try {
      final recommendations = await _repository.getRecommendations(
        priority: priority,
        analysisType: analysisType,
        isResolved: isResolved,
      );
      emit(AlertsLoaded(recommendations));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> getCriticalAlerts() async {
    emit(AlertsLoading());
    try {
      final alerts = await _repository.getCriticalAlerts();
      emit(AlertsLoaded(alerts));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> runAnalysis({int daysLookback = 30}) async {
    emit(AlertsLoading());
    try {
      final result = await _repository.runAnalysis(daysLookback: daysLookback);
      emit(AlertsAnalysisCompleted(result));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> markAsResolved(int id) async {
    try {
      await _repository.markAsResolved(id);
      // Refresh the list after marking as resolved
      await getRecommendations();
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> resolveAll(String analysisType) async {
    try {
      await _repository.resolveAll(analysisType);
      // Refresh the list after resolving all
      await getRecommendations();
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
}
