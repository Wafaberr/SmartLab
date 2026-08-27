import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smartlaboratory/features/laboratory/data/models/lab_session_model.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';

class LabSessionsScreen extends StatefulWidget {
  const LabSessionsScreen({super.key});

  @override
  State<LabSessionsScreen> createState() => _LabSessionsScreenState();
}

class _LabSessionsScreenState extends State<LabSessionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LaboratoryCubit>().loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions d’analyses')),
      body: BlocBuilder<LaboratoryCubit, LaboratoryState>(
        builder: (context, state) {
          if (state is LaboratoryLoading || state is LaboratoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LaboratoryError) {
            return Center(child: Text(state.message));
          }
          if (state is SessionsLoaded) {
            if (state.sessions.isEmpty) {
              return const Center(child: Text('Aucune session trouvée.'));
            }
            return RefreshIndicator(
              onRefresh: () => context.read<LaboratoryCubit>().loadSessions(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.sessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final session = state.sessions[index];
                  return _SessionTile(session: session);
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/analyses/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle session'),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final LabSessionModel session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: const CircleAvatar(child: Icon(Icons.science_outlined)),
        title: Text(session.analysisTypeName),
        subtitle: Text(
          '${session.sampleCount} échantillon(s) • ${session.technicianName}',
        ),
        trailing: Chip(label: Text(session.status)),
        onTap: () => context.push('/analyses/sessions/${session.id}'),
      ),
    );
  }
}
