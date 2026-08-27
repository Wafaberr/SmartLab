import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

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
