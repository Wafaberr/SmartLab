import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smartlaboratory/features/laboratory/data/models/analysis_type_model.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';

class AnalysisTypesScreen extends StatefulWidget {
  const AnalysisTypesScreen({super.key});

  @override
  State<AnalysisTypesScreen> createState() => _AnalysisTypesScreenState();
}

class _AnalysisTypesScreenState extends State<AnalysisTypesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LaboratoryCubit>().loadAnalysisTypes();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Types d’analyses')),
      body: BlocBuilder<LaboratoryCubit, LaboratoryState>(
        builder: (context, state) {
          if (state is LaboratoryLoading || state is LaboratoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LaboratoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<LaboratoryCubit>().loadAnalysisTypes(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (state is AnalysisTypesLoaded) {
            return _buildContent(state.analysisTypes);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle analyse'),
      ),
    );
  }

  Widget _buildContent(List<AnalysisTypeModel> analysisTypes) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredTypes = analysisTypes
        .where((type) => type.name.toLowerCase().contains(query))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher une analyse',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: filteredTypes.isEmpty
              ? const Center(child: Text('Aucune analyse trouvée.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filteredTypes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final analysis = filteredTypes[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.biotech_outlined),
                        ),
                        title: Text(analysis.name),
                        subtitle: Text(
                          'Durée : ${analysis.durationMinutes} min',
                        ),
                        trailing: Text(
                          '${analysis.price.toStringAsFixed(2)} DA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => context.push(
                          '/analyses/new?analysisTypeId=${analysis.id}',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    final priceController = TextEditingController(text: '0');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouvelle analyse'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Le nom est obligatoire.'
                    : null,
              ),
              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Durée (min)'),
                validator: (value) => int.tryParse(value ?? '') == null
                    ? 'Entrez une durée valide.'
                    : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Coût (DA)'),
                validator: (value) =>
                    double.tryParse((value ?? '').replaceAll(',', '.')) == null
                    ? 'Entrez un coût valide.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              await context.read<LaboratoryCubit>().createAnalysisType(
                name: nameController.text.trim(),
                durationMinutes: int.parse(durationController.text),
                price: double.parse(priceController.text.replaceAll(',', '.')),
              );
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    nameController.dispose();
    durationController.dispose();
    priceController.dispose();
  }
}
