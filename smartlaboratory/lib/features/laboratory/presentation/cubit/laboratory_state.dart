part of 'laboratory_cubit.dart';

@immutable
sealed class LaboratoryState {}

final class LaboratoryInitial extends LaboratoryState {}

final class LaboratoryLoading extends LaboratoryState {}

final class LaboratorySaving extends LaboratoryState {}

final class SessionStarted extends LaboratoryState {
  final int sessionId;

  SessionStarted({required this.sessionId});
}

final class SessionValidated extends LaboratoryState {
  final int sessionId;

  SessionValidated({required this.sessionId});
}

final class SessionsLoaded extends LaboratoryState {
  final List<LabSessionModel> sessions;

  SessionsLoaded({required this.sessions});
}

final class SessionLoaded extends LaboratoryState {
  final LabSessionModel session;

  SessionLoaded({required this.session});
}

final class AnalysisTypesLoaded extends LaboratoryState {
  final List<AnalysisTypeModel> analysisTypes;

  AnalysisTypesLoaded({required this.analysisTypes});
}

final class LaboratoryError extends LaboratoryState {
  final String message;

  LaboratoryError({required this.message});
}
