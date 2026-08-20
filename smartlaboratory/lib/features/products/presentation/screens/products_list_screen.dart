import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/screens/product_details_screen.dart';
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

class ProductsListView extends StatelessWidget {
  const ProductsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ProductCubit>().getProducts(),
            child: ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];

                final authState = context.watch<AuthCubit>().state;

                final isAdmin =
                    authState is Authentificated && authState.user.isAdmin;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: productImage(product),
                    title: Text(product.name),
                    subtitle: Text(
                      'Référence: ${product.reference}\nStock: ${product.stockQuantity}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isAdmin
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _showDeleteDialog(context, product);
                            },
                          )
                        : null,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(productId: product.id),
                        ),
                      );

                      if (!context.mounted) return;

                      context.read<ProductCubit>().getProducts();
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 5);
              },
            ),
          );
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductCubit>().getProducts();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Aucun produit'));
      },
    );
  }

  void _showDeleteDialog(BuildContext context, product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final productCubit = context.read<ProductCubit>();
                await productCubit.deleteProduct(product);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
