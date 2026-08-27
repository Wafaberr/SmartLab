import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartlaboratory/features/laboratory/data/models/lab_session_model.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';

class SessionDetailScreen extends StatefulWidget {
  final int sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LaboratoryCubit>().loadSession(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail d’une session')),
      body: BlocBuilder<LaboratoryCubit, LaboratoryState>(
        builder: (context, state) {
          if (state is LaboratoryLoading || state is LaboratoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LaboratoryError) {
            return Center(child: Text(state.message));
          }
          if (state is SessionLoaded) {
            return _buildDetails(state.session);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetails(LabSessionModel session) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Session #${session.id}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _info('Analyse', session.analysisTypeName),
        _info('Technicien', session.technicianName),
        _info('Échantillons', '${session.sampleCount}'),
        _info('Statut', session.status),
        _info('Début', _formatDate(session.startedAt)),
        _info('Fin', _formatDate(session.completedAt)),
        if (session.comment.isNotEmpty) _info('Commentaire', session.comment),
        const SizedBox(height: 24),
        const Text(
          'Consommation réelle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (session.consumptions.isEmpty)
          const Text('Aucune consommation enregistrée.')
        else
          ...session.consumptions.map(
            (consumption) => Card(
              child: ListTile(
                title: Text(consumption.productName),
                subtitle: Text(
                  'Prévu : ${consumption.plannedQuantity} ${consumption.unit}',
                ),
                trailing: Text(
                  'Réel : ${consumption.actualQuantity} ${consumption.unit}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
