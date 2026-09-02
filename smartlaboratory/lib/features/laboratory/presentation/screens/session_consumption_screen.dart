import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';

class SessionConsumptionScreen extends StatefulWidget {
  final int sessionId;

  const SessionConsumptionScreen({super.key, required this.sessionId});

  @override
  State<SessionConsumptionScreen> createState() =>
      _SessionConsumptionScreenState();
}

class _SessionConsumptionScreenState extends State<SessionConsumptionScreen> {
  final Map<int, TextEditingController> _consumptionControllers = {};
  final Map<int, TextEditingController> _remainingControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<LaboratoryCubit>().getSessionDetail(widget.sessionId);
  }

  @override
  void dispose() {
    _consumptionControllers.forEach((_, controller) => controller.dispose());
    _remainingControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submitConsumption() {
    final consumptions = <Map<String, dynamic>>[];
    _consumptionControllers.forEach((productId, controller) {
      if (controller.text.isNotEmpty) {
        consumptions.add({
          'product_id': productId,
          'quantity_used': double.parse(controller.text),
        });
      }
    });

    if (consumptions.isNotEmpty) {
      context.read<LaboratoryCubit>().recordConsumption(
        widget.sessionId,
        consumptions,
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner au moins une consommation'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consommation réelle'),
        centerTitle: true,
      ),
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
          child: BlocBuilder<LaboratoryCubit, LaboratoryState>(
            builder: (context, state) {
              if (state is LaboratorySessionDetailLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session: ${state.session.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Consommation réelle par produit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildProductConsumptionInputs(state),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitConsumption,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                );
              }
              if (state is LaboratoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('Erreur lors du chargement'));
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProductConsumptionInputs(
    LaboratorySessionDetailLoaded state,
  ) {
    return state.session.consumptions.map((consumption) {
      if (!_consumptionControllers.containsKey(consumption.id)) {
        _consumptionControllers[consumption.id] = TextEditingController();
        _remainingControllers[consumption.id] = TextEditingController();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consumption.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prévu: ${consumption.plannedQuantity} ${consumption.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _consumptionControllers[consumption.id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Consommé (${consumption.unit})',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _remainingControllers[consumption.id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Restant (${consumption.unit})',
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
