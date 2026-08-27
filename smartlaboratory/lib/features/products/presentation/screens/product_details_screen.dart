import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smartlaboratory/core/widgets/app_button.dart';
import 'package:smartlaboratory/core/widgets/status_badge.dart';
import 'package:smartlaboratory/core/widgets/stock_card.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/widget/product_image.dart';
import 'package:smartlaboratory/features/products/presentation/screens/stock_history_screen.dart';
import 'package:smartlaboratory/features/products/presentation/screens/update_product_screen.dart';
import 'package:smartlaboratory/features/products/presentation/widget/stock_mouvement_widget.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';

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
            final colorScheme = Theme.of(context).colorScheme;
            final isAdmin =
                context.read<AuthCubit>().state is Authentificated &&
                (context.read<AuthCubit>().state as Authentificated)
                    .user
                    .isAdmin;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: productImage(product)),

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(
                        text: product.isLowStock
                            ? 'Stock faible'
                            : 'Disponible',
                        color: product.isLowStock
                            ? colorScheme.errorContainer
                            : colorScheme.primaryContainer,
                        textColor: product.isLowStock
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Référence : ${product.reference}',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: product.isLowStock
                          ? colorScheme.errorContainer
                          : colorScheme.primaryContainer,
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
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          product.isLowStock
                              ? 'Stock faible'
                              : 'Stock disponible',
                          style: TextStyle(
                            color: product.isLowStock
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
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
                          _infoRow(context, 'Catégorie', product.category.name),

                          _infoRow(
                            context,
                            'Stock actuel',
                            '${product.stockQuantity} ${product.unit}',
                          ),

                          _infoRow(
                            context,
                            'Stock minimum',
                            '${product.minimumStock}',
                          ),

                          _infoRow(
                            context,
                            'Stock maximum',
                            '${product.maximumStock}',
                          ),

                          _infoRow(
                            context,
                            'Prix d’achat',
                            '${product.purchasePrice}',
                          ),

                          _infoRow(
                            context,
                            'Température',
                            product.storageTemperature.isEmpty
                                ? 'Non définie'
                                : product.storageTemperature,
                          ),

                          _infoRow(
                            context,
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

                  // if (isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
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
                            label: const Text('Historique '),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: AppButton(
                          onPressed: () async {
                            showStockMovementSheet(
                              context: context,

                              onEntry: () {
                                context.push('/stock/input/${product.id}');
                              },

                              onExit: () {
                                context.push('/stock/exit/${product.id}');
                              },
                            );
                          },
                          child: Text('mouvement'),
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
  // INFO ROW
  // ==========================

  Widget _infoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
