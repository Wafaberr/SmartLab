import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

class StockEntryScreen extends StatefulWidget {
  final int productId;

  const StockEntryScreen({super.key, required this.productId});

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  static const List<String> _suppliers = [
    'Biolab SARL',
    'MediLab Plus',
    'HealthTech SARL',
    'BioGen SA',
  ];

  String _selectedSupplier = _suppliers.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // On charge le produit réel via son id, comme dans StockExitScreen,
    // au lieu des valeurs en dur qu'avait l'écran précédent.
    context.read<ProductCubit>().getProduct(widget.productId);
  }

  @override
  void dispose() {
    // Les controllers n'étaient jamais libérés dans la version précédente
    // (fuite mémoire). On les nettoie ici.
    _quantityController.dispose();
    _batchNumberController.dispose();
    _expiryDateController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrée de stock')),
      body: BlocListener<ProductCubit, ProductState>(
        listener: (context, state) {
          if (!_isSubmitting) return;

          if (state is ProductDetailLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entrée enregistrée avec succès.')),
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
          // Produit (réel, en lecture seule)
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

          // Stock actuel
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

          // Quantité (avec validation, comme dans StockExitScreen)
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
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Fournisseur
          DropdownButtonFormField<String>(
            initialValue: _selectedSupplier,
            decoration: InputDecoration(
              labelText: 'Fournisseur',
              prefixIcon: const Icon(Icons.local_shipping_outlined),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            items: _suppliers
                .map(
                  (supplier) =>
                      DropdownMenuItem(value: supplier, child: Text(supplier)),
                )
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _selectedSupplier = value);
                    }
                  },
          ),
          const SizedBox(height: 12),

          // Numéro de lot
          TextFormField(
            controller: _batchNumberController,
            decoration: InputDecoration(
              labelText: 'Numéro de lot',
              prefixIcon: const Icon(Icons.qr_code_outlined),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 12),

          // Date d'expiration
          TextFormField(
            controller: _expiryDateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Date d'expiration",
              hintText: 'JJ/MM/AAAA',
              prefixIcon: const Icon(Icons.event_outlined),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                final formatted =
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}';
                setState(() => _expiryDateController.text = formatted);
              }
            },
          ),
          const SizedBox(height: 12),

          // Commentaire
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

          // Bouton Enregistrer
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

    // ⚠️ À ADAPTER : createMovement() dans ProductCubit (vu dans
    // stock_exit_screen.dart) accepte productId / movementType / quantity /
    // reason / comment. Le fournisseur, le n° de lot et la date
    // d'expiration n'ont pas d'équivalent connu côté Cubit/API, donc en
    // attendant qu'ils soient ajoutés côté backend, on les regroupe dans
    // "reason" pour ne pas perdre l'info saisie par l'utilisateur.
    final reasonDetails = StringBuffer(
      'Réception fournisseur : $_selectedSupplier',
    );
    if (_batchNumberController.text.trim().isNotEmpty) {
      reasonDetails.write(' | Lot : ${_batchNumberController.text.trim()}');
    }
    if (_expiryDateController.text.trim().isNotEmpty) {
      reasonDetails.write(' | Exp. : ${_expiryDateController.text.trim()}');
    }

    await context.read<ProductCubit>().createMovement(
      productId: product.id,
      movementType: 'entry',
      quantity: quantity,
      reason: reasonDetails.toString(),
      comment: _commentController.text.trim(),
    );
  }
}
