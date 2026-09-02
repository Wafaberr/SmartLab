part of 'alerts_cubit.dart';

abstract class AlertsState {
  const AlertsState();
}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<AIRecommendation> recommendations;

  const AlertsLoaded(this.recommendations);
}

class AlertsAnalysisCompleted extends AlertsState {
  final Map<String, dynamic> result;

  const AlertsAnalysisCompleted(this.result);
}

class AlertsError extends AlertsState {
  final String message;

  const AlertsError(this.message);
}
