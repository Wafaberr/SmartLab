import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/products/data/repository/product_repository_impl.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/screens/product_details_screen.dart';

class ProductsListScreen extends StatelessWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit(ProductRepositoryImpl())..getProducts(),
      child: const ProductsListView(),
    );
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

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: product.image != null
                      ? SizedBox(
                          // product.image!,
                          width: 50,
                          height: 50,
                          // fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                  title: Text(product.name),
                  subtitle: Text(
                    'Référence: ${product.reference}\nStock: ${product.stockQuantity}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog(context, product);
                    },
                  ),
                  onTap: () {
                    // Navigate to product details
                    context.read<ProductCubit>().getProduct(product.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsScreen(productId: product.id),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(color: Colors.grey, thickness: 1.0);
            },
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
              onPressed: () {
                context.read<ProductCubit>().deleteProduct(product);
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
