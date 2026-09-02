import 'package:flutter/material.dart';

/// Affiche la fenêtre de sélection :
/// Entrée de stock / Sortie de stock
void showStockMovementSheet({
  required BuildContext context,
  required VoidCallback onEntry,
  required VoidCallback onExit,
}) {
  final colors = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HANDLE
            // =========================
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TITLE
            // =========================
            Text(
              'Mouvement de stock',
              style: Theme.of(
                sheetContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Choisissez le type de mouvement',
              style: Theme.of(
                sheetContext,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            // =========================
            // ENTRÉE
            // =========================
            _stockMovementCard(
              context: sheetContext,
              icon: Icons.south_west_rounded,
              title: 'Entrée de stock',
              description: 'Ajouter une quantité au stock',
              color: Colors.green,
              onTap: () {
                Navigator.pop(sheetContext);
                onEntry();
              },
            ),

            const SizedBox(height: 12),

            // =========================
            // SORTIE
            // =========================
            _stockMovementCard(
              context: sheetContext,
              icon: Icons.north_east_rounded,
              title: 'Sortie de stock',
              description: 'Retirer une quantité du stock',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(sheetContext);
                onExit();
              },
            ),
          ],
        ),
      );
    },
  );
}

/// Carte utilisée pour Entrée / Sortie
Widget _stockMovementCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String description,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 27),
          ),

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    ),
  );
}
