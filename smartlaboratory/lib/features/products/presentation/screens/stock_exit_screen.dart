import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

class StockExitScreen extends StatefulWidget {
  final int productId;

  const StockExitScreen({super.key, required this.productId});

  @override
  State<StockExitScreen> createState() => _StockExitScreenState();
}

class _StockExitScreenState extends State<StockExitScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  static const List<String> _reasons = [
    'Consommation manuelle',
    'Produit cassé',
    'Produit contaminé',
    'Contrôle qualité',
    'Produit expiré',
    'Autre',
  ];

  String _selectedReason = _reasons.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().getProduct(widget.productId);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sortie de stock')),
      body: BlocListener<ProductCubit, ProductState>(
        listener: (context, state) {
          if (!_isSubmitting) return;

          if (state is ProductDetailLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sortie enregistrée avec succès.')),
            );
            Navigator.of(context).pop(true);
          }

          if (state is ProductError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading || state is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductError && !_isSubmitting) {
              return Center(child: Text(state.message));
            }

            if (state is ProductDetailLoaded) {
              return _buildForm(state.product);
            }

            return const Center(child: Text('Produit introuvable.'));
          },
        ),
      ),
    );
  }

  Widget _buildForm(ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            initialValue: product.name,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Produit',
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.warehouse_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Stock actuel'),
              subtitle: Text(
                '${product.stockQuantity} ${product.unit}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantité',
              suffixText: product.unit,
              prefixIcon: const Icon(Icons.numbers),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            validator: (value) {
              final quantity = double.tryParse(
                (value ?? '').replaceAll(',', '.'),
              );
              if (quantity == null || quantity <= 0) {
                return 'Entrez une quantité positive.';
              }
              if (quantity > product.stockQuantity) {
                return 'Stock insuffisant.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            decoration: InputDecoration(
              labelText: 'Motif',
              prefixIcon: const Icon(Icons.receipt_long_outlined),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            items: _reasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: _isSubmitting
                ? null
                : (value) {
                    if (value != null) setState(() => _selectedReason = value);
                  },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Commentaire (optionnel)',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.comment_outlined),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isSubmitting ? null : () => _submit(product),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(ProductModel product) async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(
      _quantityController.text.replaceAll(',', '.'),
    );
    setState(() => _isSubmitting = true);

    await context.read<ProductCubit>().createMovement(
      productId: product.id,
      movementType: 'exit',
      quantity: quantity,
      reason: _selectedReason,
      comment: _commentController.text.trim(),
    );
  }
}
