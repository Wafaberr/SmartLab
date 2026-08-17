import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/widget/product_image.dart';

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
                          onPressed: () {
                            // Modifier produit
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Ajouter stock
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Stock'),
                        ),
                      ),
                    ],
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
  // IMAGE PLACEHOLDER
  // ==========================

  Widget _imagePlaceholder() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.image, size: 60, color: Colors.grey),
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
}
