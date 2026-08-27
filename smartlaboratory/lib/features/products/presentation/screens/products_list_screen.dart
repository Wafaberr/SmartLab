import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/screens/product_details_screen.dart';
import 'package:smartlaboratory/features/products/presentation/screens/update_product_screen.dart';
import 'package:smartlaboratory/features/products/presentation/widget/product_image.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return const ProductsListView();
  }
}

class ProductsListView extends StatefulWidget {
  const ProductsListView({super.key});

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<dynamic> _filterProducts(List<dynamic> products) {
    if (_searchQuery.trim().isEmpty) {
      return products;
    }

    final query = _searchQuery.toLowerCase().trim();

    return products.where((product) {
      final name = product.name.toString().toLowerCase();

      final reference = product.reference.toString().toLowerCase();

      final barcode = product.barcode?.toString().toLowerCase() ?? '';

      final category = product.category.name.toString().toLowerCase();

      return name.contains(query) ||
          reference.contains(query) ||
          barcode.contains(query) ||
          category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = context.watch<AuthCubit>().state;

    final isAdmin = authState is Authentificated && authState.user.isAdmin;

    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        // ========================================================
        // LOADING
        // ========================================================

        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ========================================================
        // LOADED
        // ========================================================

        if (state is ProductLoaded) {
          final products = _filterProducts(state.products);

          return Column(
            children: [
              // ==================================================
              // SEARCH BAR
              // ==================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher un produit...',
                          prefixIcon: const Icon(Icons.search),

                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();

                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,

                          filled: true,
                          fillColor: colors.surface,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    if (isAdmin) ...[
                      IconButton(
                        onPressed: () {
                          context.push('/addProduct');
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ],
                ),
              ),

              // ==================================================
              // RESULT COUNT
              // ==================================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchQuery.isEmpty
                        ? '${products.length} produits'
                        : '${products.length} résultat(s)',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // LIST
              // ==================================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ProductCubit>().getProducts();
                  },
                  child: products.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 55,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Aucun produit trouvé',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: products.length,
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            final product = products[index];

                            // ====================================
                            // AUTH
                            // ====================================

                            final authState = context.watch<AuthCubit>().state;

                            final isAdmin =
                                authState is Authentificated &&
                                authState.user.isAdmin;

                            // ====================================
                            // STOCK
                            // ====================================

                            final stock = product.stockQuantity;

                            final minimumStock = product.minimumStock;

                            final isLowStock = stock <= minimumStock;

                            // ====================================
                            // CARD
                            // ====================================

                            return Card(
                              elevation: 1,
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),

                                // IMAGE
                                leading: productImage(product),

                                // TITLE
                                title: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                // INFORMATION
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Référence: ${product.reference}'),

                                      if (product.barcode != null &&
                                          product.barcode!.isNotEmpty)
                                        Text('Code-barres: ${product.barcode}'),

                                      const SizedBox(height: 6),

                                      Row(
                                        children: [
                                          Icon(
                                            isLowStock
                                                ? Icons.warning_amber_rounded
                                                : Icons.inventory_2_outlined,
                                            size: 17,
                                            color: isLowStock
                                                ? colors.error
                                                : colors.primary,
                                          ),

                                          const SizedBox(width: 5),

                                          Text(
                                            'Stock: ${product.stockQuantity}',
                                            style: TextStyle(
                                              color: isLowStock
                                                  ? colors.error
                                                  : colors.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          if (isLowStock) ...[
                                            const SizedBox(width: 8),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colors.errorContainer,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Stock faible',
                                                style: TextStyle(
                                                  color:
                                                      colors.onErrorContainer,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // ADMIN DELETE
                                trailing: isAdmin
                                    ? PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => UpdateProductScreen(
                                                  product: product,
                                                  // Si ton écran accepte un mode édition,
                                                  // on pourra ajouter ici :
                                                  // isEditing: true,
                                                ),
                                              ),
                                            );

                                            if (!context.mounted) return;

                                            await context
                                                .read<ProductCubit>()
                                                .getProducts();
                                          }

                                          if (value == 'delete') {
                                            _showDeleteDialog(context, product);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 12),
                                                Text('Modifier'),
                                              ],
                                            ),
                                          ),

                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_outline,
                                                  size: 20,
                                                  color: colors.error,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Supprimer',
                                                  style: TextStyle(
                                                    color: colors.error,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Icon(Icons.chevron_right),
                                // ==================================
                                // OPEN DETAILS
                                // ==================================
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        productId: product.id,
                                      ),
                                    ),
                                  );

                                  // =================================
                                  // IMPORTANT
                                  // =================================
                                  //
                                  // Quand on revient de
                                  // ProductDetailsScreen,
                                  // on recharge les produits.
                                  //
                                  // Donc si le produit a été modifié,
                                  // le changement apparaît
                                  // immédiatement dans la liste.
                                  //

                                  if (!context.mounted) return;

                                  await context
                                      .read<ProductCubit>()
                                      .getProducts();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }

        // ========================================================
        // ERROR
        // ========================================================

        if (state is ProductError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 48, color: colors.error),

                  const SizedBox(height: 12),

                  Text(
                    'Impossible de charger les produits',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 6),

                  Text(state.message, textAlign: TextAlign.center),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: () {
                      context.read<ProductCubit>().getProducts();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        // ========================================================
        // DEFAULT
        // ========================================================

        return const Center(child: Text('Aucun produit'));
      },
    );
  }

  // ============================================================
  // DELETE DIALOG
  // ============================================================

  void _showDeleteDialog(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ${product.name} ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),

            TextButton(
              onPressed: () async {
                final productCubit = context.read<ProductCubit>();

                // Fermer le dialogue
                Navigator.of(dialogContext).pop();

                // Supprimer
                await productCubit.deleteProduct(product);
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
