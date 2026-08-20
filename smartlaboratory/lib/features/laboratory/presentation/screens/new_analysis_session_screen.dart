import 'package:flutter/material.dart';
import 'package:smartlaboratory/features/laboratory/data/models/analysis_type_model.dart';
import 'package:smartlaboratory/features/laboratory/data/repository/laboratory_repository.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/data/repository/product_repository_impl.dart';

class NewAnalysisSessionScreen extends StatefulWidget {
  const NewAnalysisSessionScreen({super.key});

  @override
  State<NewAnalysisSessionScreen> createState() =>
      _NewAnalysisSessionScreenState();
}

class _NewAnalysisSessionScreenState extends State<NewAnalysisSessionScreen> {
  final _repository = LaboratoryRepository();
  final _productRepository = ProductRepositoryImpl();
  final _commentController = TextEditingController();
  final _sampleController = TextEditingController(text: '1');
  int _step = 0;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<AnalysisTypeModel> _types = [];
  List<ProductModel> _products = [];
  AnalysisTypeModel? _selectedType;
  int? _sessionId;
  final Map<int, TextEditingController> _consumptionControllers = {};
  final Map<int, TextEditingController> _lossControllers = {};
  final Map<int, String> _lossReasons = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _sampleController.dispose();
    for (final controller in _consumptionControllers.values) {
      controller.dispose();
    }
    for (final controller in _lossControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final types = await _repository.getAnalysisTypes();
      final products = await _productRepository.getProducts();
      if (!mounted) return;
      setState(() {
        _types = types;
        _products = products;
        _selectedType = types.isEmpty ? null : types.first;
        _loading = false;
      });
      for (final product in products) {
        _consumptionControllers[product.id] = TextEditingController(text: '0');
        _lossControllers[product.id] = TextEditingController(text: '0');
        _lossReasons[product.id] = 'other';
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle session')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Stepper(
              currentStep: _step,
              onStepContinue: _next,
              onStepCancel: _step == 0 ? null : () => setState(() => _step--),
              controlsBuilder: (context, details) => Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: _saving ? null : details.onStepContinue,
                      child: Text(
                        _step == 4 ? 'Valider la session' : 'Continuer',
                      ),
                    ),
                    if (_step > 0)
                      TextButton(
                        onPressed: _saving ? null : details.onStepCancel,
                        child: const Text('Retour'),
                      ),
                  ],
                ),
              ),
              steps: [
                Step(
                  title: const Text('Type d’analyse'),
                  isActive: _step >= 0,
                  content: _analysisTypeStep(),
                ),
                Step(
                  title: const Text('Nouvelle session'),
                  isActive: _step >= 1,
                  content: _sessionStep(),
                ),
                Step(
                  title: const Text('Consommation réelle'),
                  isActive: _step >= 2,
                  content: _consumptionStep(),
                ),
                Step(
                  title: const Text('Validation session'),
                  isActive: _step >= 3,
                  content: _summaryStep(),
                ),
                Step(
                  title: const Text('Pertes'),
                  isActive: _step >= 4,
                  content: _lossStep(),
                ),
              ],
            ),
    );
  }

  Widget _analysisTypeStep() => DropdownButtonFormField<AnalysisTypeModel>(
    initialValue: _selectedType,
    decoration: const InputDecoration(
      labelText: 'Analyse',
      border: OutlineInputBorder(),
    ),
    items: _types
        .map(
          (type) => DropdownMenuItem(
            value: type,
            child: Text('${type.name} - ${type.durationMinutes} min'),
          ),
        )
        .toList(),
    onChanged: (value) => setState(() => _selectedType = value),
  );

  Widget _sessionStep() => Column(
    children: [
      TextFormField(
        controller: _sampleController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Nombre d’échantillons',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _commentController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Commentaire (optionnel)',
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );

  Widget _consumptionStep() => Column(
    children: _products
        .map(
          (product) => _quantityField(
            product,
            _consumptionControllers[product.id]!,
            'Consommation ${product.unit}',
          ),
        )
        .toList(),
  );

  Widget _lossStep() => Column(
    children: _products
        .map(
          (product) => Column(
            children: [
              _quantityField(
                product,
                _lossControllers[product.id]!,
                'Perte ${product.unit}',
              ),
              if ((_lossControllers[product.id]?.text ?? '0') != '0')
                DropdownButtonFormField<String>(
                  initialValue: _lossReasons[product.id],
                  decoration: const InputDecoration(labelText: 'Motif'),
                  items: const [
                    DropdownMenuItem(
                      value: 'broken',
                      child: Text('Produit cassé'),
                    ),
                    DropdownMenuItem(
                      value: 'expired',
                      child: Text('Produit expiré'),
                    ),
                    DropdownMenuItem(
                      value: 'handling_error',
                      child: Text('Erreur de manipulation'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('Autre')),
                  ],
                  onChanged: (value) => setState(
                    () => _lossReasons[product.id] = value ?? 'other',
                  ),
                ),
            ],
          ),
        )
        .toList(),
  );

  Widget _quantityField(
    ProductModel product,
    TextEditingController controller,
    String label,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: '${product.name} - $label',
        hintText: '0',
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Widget _summaryStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Analyse : ${_selectedType?.name ?? '-'}'),
      Text('Échantillons : ${_sampleController.text}'),
      const SizedBox(height: 12),
      const Text(
        'Les consommations seront déduites du stock uniquement après validation finale.',
      ),
    ],
  );

  Future<void> _next() async {
    if (_step == 0 && _selectedType == null) return;
    if (_step == 1 && (int.tryParse(_sampleController.text) ?? 0) <= 0) return;
    if (_step == 1 && _sessionId == null) {
      setState(() => _saving = true);
      try {
        _sessionId = await _repository.createSession(
          analysisTypeId: _selectedType!.id,
          sampleCount: int.parse(_sampleController.text),
          comment: _commentController.text.trim(),
        );
        await _repository.startSession(_sessionId!);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
        setState(() => _saving = false);
        return;
      }
      setState(() => _saving = false);
    }
    if (_step < 4) {
      setState(() => _step++);
      return;
    }
    await _validate();
  }

  Future<void> _validate() async {
    if (_sessionId == null) return;
    setState(() => _saving = true);
    final consumptions = <Map<String, dynamic>>[];
    final losses = <Map<String, dynamic>>[];
    for (final product in _products) {
      final consumption =
          double.tryParse(
            _consumptionControllers[product.id]!.text.replaceAll(',', '.'),
          ) ??
          0;
      final loss =
          double.tryParse(
            _lossControllers[product.id]!.text.replaceAll(',', '.'),
          ) ??
          0;
      if (consumption > 0) {
        consumptions.add({
          'product_id': product.id,
          'actual_quantity': consumption,
        });
      }
      if (loss > 0) {
        losses.add({
          'product_id': product.id,
          'quantity': loss,
          'reason': _lossReasons[product.id],
        });
      }
    }
    try {
      await _repository.validateSession(
        _sessionId!,
        consumptions: consumptions,
        losses: losses,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session validée et stock mis à jour.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
