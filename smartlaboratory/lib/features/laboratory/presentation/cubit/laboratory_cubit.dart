import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartlaboratory/features/laboratory/data/models/analysis_type_model.dart';
import 'package:smartlaboratory/features/laboratory/data/models/lab_session_model.dart';
import 'package:smartlaboratory/features/laboratory/data/repository/laboratory_repository.dart';

part 'laboratory_state.dart';

class LaboratoryCubit extends Cubit<LaboratoryState> {
  final LaboratoryRepository repository;

  LaboratoryCubit(this.repository) : super(LaboratoryInitial());

  Future<List<AnalysisTypeModel>> getAnalysisTypes() {
    return repository.getAnalysisTypes();
  }

  Future<void> loadSessions() async {
    emit(LaboratoryLoading());
    try {
      emit(SessionsLoaded(sessions: await repository.getSessions()));
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }

  Future<void> loadSession(int sessionId) async {
    emit(LaboratoryLoading());
    try {
      emit(SessionLoaded(session: await repository.getSession(sessionId)));
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }

  Future<void> loadAnalysisTypes() async {
    emit(LaboratoryLoading());
    try {
      final analysisTypes = await repository.getAnalysisTypes();
      emit(AnalysisTypesLoaded(analysisTypes: analysisTypes));
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }

  Future<void> createAnalysisType({
    required String name,
    required int durationMinutes,
    required double price,
  }) async {
    emit(LaboratorySaving());
    try {
      await repository.createAnalysisType(
        name: name,
        durationMinutes: durationMinutes,
        price: price,
      );
      await loadAnalysisTypes();
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }

  Future<int> createAndStartSession({
    required int analysisTypeId,
    required int sampleCount,
    String comment = '',
  }) async {
    emit(LaboratorySaving());
    try {
      final sessionId = await repository.createSession(
        analysisTypeId: analysisTypeId,
        sampleCount: sampleCount,
        comment: comment,
      );
      await repository.startSession(sessionId);
      emit(SessionStarted(sessionId: sessionId));
      return sessionId;
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
      rethrow;
    }
  }

  Future<void> validateSession(
    int sessionId, {
    required List<Map<String, dynamic>> consumptions,
    required List<Map<String, dynamic>> losses,
  }) async {
    emit(LaboratorySaving());
    try {
      await repository.validateSession(
        sessionId,
        consumptions: consumptions,
        losses: losses,
      );
      emit(SessionValidated(sessionId: sessionId));
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
      rethrow;
    }
  }

  Future<void> getSessionDetail(int sessionId) async {
    emit(LaboratoryLoading());
    try {
      final session = await repository.getSession(sessionId);
      emit(LaboratorySessionDetailLoaded(session));
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }

  Future<void> recordConsumption(
    int sessionId,
    List<Map<String, dynamic>> consumptions,
  ) async {
    emit(LaboratorySaving());
    try {
      // TODO: Implement consumption recording endpoint
      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        LaboratorySessionDetailLoaded(await repository.getSession(sessionId)),
      );
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }

  Future<void> recordLosses(
    int sessionId,
    List<Map<String, dynamic>> losses,
  ) async {
    emit(LaboratorySaving());
    try {
      // TODO: Implement losses recording endpoint
      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        LaboratorySessionDetailLoaded(await repository.getSession(sessionId)),
      );
    } catch (error) {
      emit(LaboratoryError(message: error.toString()));
    }
  }
}
