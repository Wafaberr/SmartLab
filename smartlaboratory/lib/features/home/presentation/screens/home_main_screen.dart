import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';

class HomeMainScreen extends StatelessWidget {
  const HomeMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final name =
        authState is Authentificated && authState.user.firstName.isNotEmpty
        ? authState.user.firstName
        : 'utilisateur';
    final colorScheme = Theme.of(context).colorScheme;
    final isAdmin = authState is Authentificated && authState.user.isAdmin;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isAdmin ? 'Pilotage administrateur' : 'Espace technicien',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.biotech_outlined,
                    color: colorScheme.onPrimary,
                    size: 34,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour,',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Valeur du stock',
                    '125 450 DA',
                    Icons.inventory_2_outlined,
                    const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    'Produits en stock',
                    '352',
                    Icons.science_outlined,
                    const Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Stock critique',
                    '18',
                    Icons.warning_amber_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    'En rupture',
                    '5',
                    Icons.error_outline,
                    const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Activité du jour',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _ActivityCard(
              'Consommation du jour',
              '24 560 DA',
              '+12% par rapport à hier',
              Icons.trending_up,
              Color(0xFF059669),
            ),
            const SizedBox(height: 10),
            const _ActivityCard(
              'Analyses aujourd’hui',
              '42',
              '8 sessions en cours',
              Icons.analytics_outlined,
              Color(0xFF7C3AED),
            ),
            const SizedBox(height: 24),
            const Text(
              'Actions rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (isAdmin) ...[
                  Expanded(
                    child: _QuickAction(
                      'Ajouter un produit',
                      Icons.add_box_outlined,
                      const Color(0xFF2563EB),
                      () => context.push('/addProduct'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _QuickAction(
                'Types d’analyses',
                Icons.analytics_outlined,
                const Color(0xFF7C3AED),
                () => context.push('/analyses'),
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _QuickAction(
                  'Gérer les utilisateurs',
                  Icons.manage_accounts_outlined,
                  const Color(0xFFDC2626),
                  () => context.push('/UsersManagementScreen'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 14),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  const _ActivityCard(
    this.title,
    this.value,
    this.detail,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          foregroundColor: color,
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(detail, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAction(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
