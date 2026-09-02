import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';

class SessionLossesScreen extends StatefulWidget {
  final int sessionId;

  const SessionLossesScreen({super.key, required this.sessionId});

  @override
  State<SessionLossesScreen> createState() => _SessionLossesScreenState();
}

class _SessionLossesScreenState extends State<SessionLossesScreen> {
  final Map<String, TextEditingController> _lossControllers = {};
  final List<String> _lossReasons = [
    'Erreur de manipulation',
    'Évaporation/Humidité',
    'Échantillon défectueux',
    'Autre',
  ];

  @override
  void dispose() {
    _lossControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _addLossEntry() {
    setState(() {
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      _lossControllers[key] = TextEditingController();
    });
  }

  void _removeLossEntry(String key) {
    setState(() {
      _lossControllers[key]?.dispose();
      _lossControllers.remove(key);
    });
  }

  void _submitLosses() {
    final losses = <Map<String, dynamic>>[];
    _lossControllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        losses.add({
          'reason': controller.text,
          'quantity': 0, // À adapter selon l'UI
        });
      }
    });

    if (losses.isNotEmpty) {
      context.read<LaboratoryCubit>().recordLosses(widget.sessionId, losses);
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez renseigner au moins une perte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motifs de pertes'), centerTitle: true),
      body: BlocListener<LaboratoryCubit, LaboratoryState>(
        listener: (context, state) {
          if (state is LaboratoryError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enregistrer les pertes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Décrivez les pertes ou gaspillages survenus',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ..._buildLossEntries(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addLossEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une perte'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitLosses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer les pertes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLossEntries() {
    final entries = _lossControllers.entries.toList();
    return entries.map((entry) {
      final key = entry.key;
      final controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Perte #${entries.indexOf(entry) + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => _removeLossEntry(key),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Motif',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _lossReasons.map((reason) {
                    return DropdownMenuItem(value: reason, child: Text(reason));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.text = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
