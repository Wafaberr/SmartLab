import 'package:equatable/equatable.dart';
import '../../data/models/ai_recommendation_model.dart';

abstract class AIRecommendationsState extends Equatable {
  const AIRecommendationsState();

  @override
  List<Object?> get props => [];
}

class AIRecommendationsInitial extends AIRecommendationsState {
  const AIRecommendationsInitial();
}

class AIRecommendationsLoading extends AIRecommendationsState {
  const AIRecommendationsLoading();
}

class AIRecommendationsLoaded extends AIRecommendationsState {
  final List<AIRecommendation> recommendations;
  final int criticalCount;
  final int highCount;

  const AIRecommendationsLoaded({
    required this.recommendations,
    required this.criticalCount,
    required this.highCount,
  });

  @override
  List<Object?> get props => [recommendations, criticalCount, highCount];
}

class AIRecommendationsAnalyzing extends AIRecommendationsState {
  const AIRecommendationsAnalyzing();
}

class AIRecommendationsAnalysisComplete extends AIRecommendationsState {
  final String message;
  final Map<String, dynamic> summary;

  const AIRecommendationsAnalysisComplete({
    required this.message,
    required this.summary,
  });

  @override
  List<Object?> get props => [message, summary];
}

class AIRecommendationsSaving extends AIRecommendationsState {
  const AIRecommendationsSaving();
}

class AIRecommendationsSuccess extends AIRecommendationsState {
  final String message;

  const AIRecommendationsSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AIRecommendationsError extends AIRecommendationsState {
  final String message;

  const AIRecommendationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
