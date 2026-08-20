import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/widget/product_image.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';
import 'package:smartlaboratory/features/products/presentation/screens/update_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();

    // On récupère le Cubit qui se trouve déjà dans le main.dart
    context.read<ProductCubit>().getProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return const ProductDetail();
  }
}

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du produit')),

      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          // ==========================
          // LOADING
          // ==========================

          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==========================
          // PRODUCT LOADED
          // ==========================

          if (state is ProductDetailLoaded) {
            final product = state.product;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================
                  // IMAGE
                  // ==========================
                  Center(child: productImage(product)),

                  const SizedBox(height: 24),

                  // ==========================
                  // PRODUCT NAME
                  // ==========================
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==========================
                  // REFERENCE
                  // ==========================
                  Text(
                    'Référence : ${product.reference}',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // ==========================
                  // STOCK STATUS
                  // ==========================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: product.isLowStock
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.isLowStock
                              ? Icons.warning_amber
                              : Icons.check_circle,
                          color: product.isLowStock
                              ? Colors.orange
                              : Colors.green,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          product.isLowStock
                              ? 'Stock faible'
                              : 'Stock disponible',
                          style: TextStyle(
                            color: product.isLowStock
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================
                  // INFORMATIONS
                  // ==========================
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow('Catégorie', product.category.name),

                          _infoRow(
                            'Stock actuel',
                            '${product.stockQuantity} ${product.unit}',
                          ),

                          _infoRow('Stock minimum', '${product.minimumStock}'),

                          _infoRow('Stock maximum', '${product.maximumStock}'),

                          _infoRow('Prix d’achat', '${product.purchasePrice}'),

                          // _infoRow(
                          //   'Prix',
                          //   '${product.price}',
                          // ),
                          _infoRow(
                            'Température',
                            product.storageTemperature.isEmpty
                                ? 'Non définie'
                                : product.storageTemperature,
                          ),

                          _infoRow(
                            'Expiration',
                            product.expirationDate ?? 'Non définie',
                          ),

                          // _infoRow(
                          //   'Emplacement',
                          //   product.location.isEmpty
                          //       ? 'Non défini'
                          //       : product.location,
                          // ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================
                  // DESCRIPTION
                  // ==========================
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.description.isEmpty
                        ? 'Aucune description'
                        : product.description,
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 30),

                  // ==========================
                  // ACTIONS
                  // ==========================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UpdateProductScreen(product: product),
                              ),
                            );
                            if (context.mounted) {
                              context.read<ProductCubit>().getProduct(
                                product.id,
                              );
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showMovementDialog(context, product.id),
                          icon: const Icon(Icons.add),
                          label: const Text('Stock'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StockHistoryScreen(productId: product.id),
                        ),
                      ),
                      icon: const Icon(Icons.history),
                      label: const Text('Historique des mouvements'),
                    ),
                  ),
                ],
              ),
            );
          }

          // ==========================
          // ERROR
          // ==========================

          if (state is ProductError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 16),

                    Text(state.message, textAlign: TextAlign.center),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        // Récupération de l'ID depuis
                        // le screen parent impossible ici.
                        //
                        // On utilise le Navigator pour
                        // relancer la page.
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==========================
          // DEFAULT
          // ==========================

          return const Center(child: Text('Aucun produit trouvé'));
        },
      ),
    );
  }

  // ==========================
  // INFO ROW
  // ==========================

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMovementDialog(BuildContext context, int productId) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _MovementDialog(productId: productId),
    );
  }
}

class _MovementDialog extends StatefulWidget {
  final int productId;

  const _MovementDialog({required this.productId});

  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  String _type = 'entry';
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mouvement de stock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: const [
              DropdownMenuItem(value: 'entry', child: Text('Entrée de stock')),
              DropdownMenuItem(value: 'exit', child: Text('Sortie de stock')),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _type = value ?? 'entry'),
          ),
          TextField(
            controller: _quantityController,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité'),
          ),
          TextField(
            controller: _reasonController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Motif'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final quantity = double.tryParse(
      _quantityController.text.replaceAll(',', '.'),
    );
    if (quantity == null || quantity <= 0) return;

    setState(() => _saving = true);
    await context.read<ProductCubit>().createMovement(
      productId: widget.productId,
      movementType: _type,
      quantity: quantity,
      reason: _reasonController.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class StockHistoryScreen extends StatelessWidget {
  final int productId;

  const StockHistoryScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des mouvements')),
      body: FutureBuilder<List<StockMovementModel>>(
        future: context.read<ProductCubit>().getMovements(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final movements = snapshot.data ?? [];
          if (movements.isEmpty) {
            return const Center(child: Text('Aucun mouvement'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: movements.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final movement = movements[index];
              final isEntry = movement.movementType == 'entry';
              return ListTile(
                leading: Icon(
                  isEntry ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isEntry ? Colors.green : Colors.red,
                ),
                title: Text(
                  '${isEntry ? 'Entrée' : 'Sortie'} : ${movement.quantity}',
                ),
                subtitle: Text(
                  '${movement.stockBefore} -> ${movement.stockAfter}${movement.reason.isEmpty ? '' : '\n${movement.reason}'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
