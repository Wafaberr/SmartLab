import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/orders/presentation/cubit/order_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  // Form fields
  String? _selectedSupplierId;
  final Map<int, double> _orderItems = {};
  final Map<int, TextEditingController> _quantityControllers = {};
  final TextEditingController _notesController = TextEditingController();
  DateTime? _expectedDeliveryDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<ProductCubit>().getProducts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    _quantityControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _addProductToOrder(int productId) {
    if (!_quantityControllers.containsKey(productId)) {
      _quantityControllers[productId] = TextEditingController();
    }
  }

  void _removeProductFromOrder(int productId) {
    _quantityControllers[productId]?.dispose();
    _quantityControllers.remove(productId);
    _orderItems.remove(productId);
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _submitOrder() {
    final items = <Map<String, dynamic>>[];
    _quantityControllers.forEach((productId, controller) {
      if (controller.text.isNotEmpty) {
        items.add({
          'product_id': productId,
          'quantity': double.parse(controller.text),
        });
      }
    });

    if (_selectedSupplierId == null || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un fournisseur et des produits'),
        ),
      );
      return;
    }

    context.read<OrderCubit>().createOrder(
      supplierId: _selectedSupplierId!,
      items: items,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      expectedDeliveryDate: _expectedDeliveryDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle commande'), centerTitle: true),
      body: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commande créée avec succès')),
            );
            Navigator.of(context).pop();
          } else if (state is OrderError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildSupplierStep(),
                  _buildProductsStep(),
                  _buildDetailsStep(),
                  _buildSummaryStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Fournisseur', 'Produits', 'Détails', 'Résumé'];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          steps.length,
          (index) => Expanded(
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentStep
                        ? Colors.deepPurple
                        : Colors.grey[300],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index <= _currentStep ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: index <= _currentStep
                        ? Colors.deepPurple
                        : Colors.grey,
                    fontWeight: index == _currentStep
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélectionnez un fournisseur',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // TODO: Fetch suppliers from API
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Fournisseur',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            initialValue: _selectedSupplierId,
            items: const [
              DropdownMenuItem(value: '1', child: Text('Fournisseur 1')),
              DropdownMenuItem(value: '2', child: Text('Fournisseur 2')),
              DropdownMenuItem(value: '3', child: Text('Fournisseur 3')),
            ],
            onChanged: (value) {
              setState(() => _selectedSupplierId = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsStep() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionnez les produits',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...state.products.map((product) {
                  final isSelected = _quantityControllers.containsKey(
                    product.id,
                  );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _addProductToOrder(product.id);
                                } else {
                                  _removeProductFromOrder(product.id);
                                }
                              });
                            },
                            title: Text(product.name),
                            subtitle: Text('${product.purchasePrice} DA/unité'),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 8),
                            TextField(
                              controller: _quantityControllers[product.id],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Quantité',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }
        return const Center(child: Text('Erreur lors du chargement'));
      },
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de la commande',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Remarques',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Ajouter des notes...',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _expectedDeliveryDate ??
                    DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _expectedDeliveryDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _expectedDeliveryDate != null
                        ? 'Livraison prévue: ${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}'
                        : 'Sélectionner une date de livraison',
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de la commande',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fournisseur: $_selectedSupplierId',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Produits commandés:',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ..._quantityControllers.entries.map((entry) {
                    final qty = double.tryParse(entry.value.text) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('Produit #${entry.key}: $qty unités'),
                    );
                  }),
                  if (_notesController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Notes: ${_notesController.text}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 3 ? _nextStep : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: Text(_currentStep < 3 ? 'Suivant' : 'Créer commande'),
            ),
          ),
        ],
      ),
    );
  }
}
