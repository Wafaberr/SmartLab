import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';
import 'package:smartlaboratory/features/alerts/presentation/cubit/alerts_cubit.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  @override
  void initState() {
    super.initState();
    // Load dynamic data
    context.read<ProductCubit>().getProducts();
    context.read<LaboratoryCubit>().loadSessions();
    context.read<AlertsCubit>().getRecommendations();
  }

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
            // Header
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
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
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

            // Show different content based on user role
            if (isAdmin)
              _buildAdminDashboard(context)
            else
              _buildTechnicianDashboard(context),
          ],
        ),
      ),
    );
  }

  // Build admin dashboard
  Widget _buildAdminDashboard(BuildContext context) {
    return Column(
      children: [
        // Admin Stats: Orders, Users, Inventory Value
        _buildAdminStatsSection(context),
        const SizedBox(height: 24),

        // Orders Overview
        const Text(
          'Commandes récentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildOrdersOverviewSection(context),
        const SizedBox(height: 24),

        // Stock Analysis
        const Text(
          'Analyse du stock',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildStatsSection(context),
        const SizedBox(height: 24),

        // AI Predictions
        const Text(
          'Prédictions IA',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildPredictionsSection(context),
        const SizedBox(height: 24),

        // Admin Quick Actions
        const Text(
          'Actions administrateur',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _QuickAction(
            'Ajouter produit',
            Icons.add_box_outlined,
            const Color(0xFF2563EB),
            () => context.push('/addProduct'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _QuickAction(
            'Gérer les commandes',
            Icons.shopping_cart_outlined,
            const Color(0xFF059669),
            () => context.push('/orders'),
          ),
        ),
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _QuickAction(
            'Rapports',
            Icons.assessment_outlined,
            const Color(0xFF7C3AED),
            () => context.push('/reports'),
          ),
        ),
      ],
    );
  }

  // Build technician dashboard
  Widget _buildTechnicianDashboard(BuildContext context) {
    return Column(
      children: [
        // Technician Stats: Sessions, Products, Alerts
        _buildTechnicianStatsSection(context),
        const SizedBox(height: 24),

        // Activity Section
        const Text(
          'Activité du jour',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildActivitySection(context),
        const SizedBox(height: 24),

        // Stock Overview
        const Text(
          'État du stock',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildStatsSection(context),
        const SizedBox(height: 24),

        // AI Recommendations
        const Text(
          'Recommandations IA',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildRecommendationsSection(context),
        const SizedBox(height: 24),

        // Technician Quick Actions
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _QuickAction(
            'Nouveau session',
            Icons.add_circle_outline,
            const Color(0xFF2563EB),
            () => context.push('/analyses'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _QuickAction(
            'Mes analyses',
            Icons.analytics_outlined,
            const Color(0xFF7C3AED),
            () => context.push('/analyses'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _QuickAction(
            'Rapports',
            Icons.assessment_outlined,
            const Color(0xFFDC2626),
            () => context.push('/reports'),
          ),
        ),
      ],
    );
  }

  // Build admin stats section
  Widget _buildAdminStatsSection(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, productState) {
        if (productState is ProductLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        int totalProducts = 0;
        double inventoryValue = 0;

        if (productState is ProductLoaded) {
          totalProducts = productState.products.length;
          inventoryValue = productState.products.fold<double>(
            0,
            (sum, p) => sum + (p.stockQuantity * p.purchasePrice),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Valeur inventaire',
                    '${(inventoryValue / 1000).toStringAsFixed(1)}K DA',
                    Icons.inventory_2_outlined,
                    const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    'Produits actifs',
                    '$totalProducts',
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
                    'Commandes en cours',
                    '12',
                    Icons.shopping_cart_outlined,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    'Utilisateurs',
                    '8',
                    Icons.people_outlined,
                    const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Build technician stats section
  Widget _buildTechnicianStatsSection(BuildContext context) {
    return BlocBuilder<LaboratoryCubit, LaboratoryState>(
      builder: (context, labState) {
        int activeSessions = 0;
        int completedSessions = 0;

        if (labState is SessionsLoaded) {
          activeSessions = labState.sessions
              .where((s) => s.status == 'in_progress' || s.status == 'draft')
              .length;
          completedSessions = labState.sessions
              .where((s) => s.status == 'completed')
              .length;
        }

        return BlocBuilder<ProductCubit, ProductState>(
          builder: (context, productState) {
            int lowStockCount = 0;
            int outOfStockCount = 0;

            if (productState is ProductLoaded) {
              lowStockCount = productState.products
                  .where((p) => p.isLowStock)
                  .length;
              outOfStockCount = productState.products
                  .where((p) => p.stockQuantity == 0)
                  .length;
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        'Sessions actives',
                        '$activeSessions',
                        Icons.trending_up,
                        const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        'Complétées',
                        '$completedSessions',
                        Icons.check_circle_outline,
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
                        '$lowStockCount',
                        Icons.warning_amber_rounded,
                        const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        'En rupture',
                        '$outOfStockCount',
                        Icons.error_outline,
                        const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build orders overview section for admin
  Widget _buildOrdersOverviewSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _buildOrderStatusChip('En attente', 5, const Color(0xFFF59E0B)),
          const SizedBox(height: 10),
          _buildOrderStatusChip('Confirmées', 4, const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          _buildOrderStatusChip('Expédiées', 2, const Color(0xFF059669)),
          const SizedBox(height: 10),
          _buildOrderStatusChip('Livrées', 8, const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildOrderStatusChip(String status, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // Build dynamic stats section
  Widget _buildStatsSection(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProductLoaded) {
          final products = state.products;
          final lowStockCount = products.where((p) => p.isLowStock).length;
          final outOfStockCount = products
              .where((p) => p.stockQuantity == 0)
              .length;
          final totalValue = products.fold<double>(
            0,
            (sum, p) => sum + (p.stockQuantity * p.purchasePrice),
          );

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      'Valeur du stock',
                      '${totalValue.toStringAsFixed(0)} DA',
                      Icons.inventory_2_outlined,
                      const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      'Produits actifs',
                      '${products.length}',
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
                      '$lowStockCount',
                      Icons.warning_amber_rounded,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      'En rupture',
                      '$outOfStockCount',
                      Icons.error_outline,
                      const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Build dynamic activity section
  Widget _buildActivitySection(BuildContext context) {
    return BlocBuilder<LaboratoryCubit, LaboratoryState>(
      builder: (context, state) {
        if (state is LaboratoryLoading) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SessionsLoaded) {
          final activeSessions = state.sessions
              .where((s) => s.status == 'in_progress' || s.status == 'draft')
              .length;
          final completedSessions = state.sessions
              .where((s) => s.status == 'completed')
              .length;

          return Column(
            children: [
              _ActivityCard(
                'Sessions en cours',
                '$activeSessions',
                'Analyses actives',
                Icons.trending_up,
                const Color(0xFF059669),
              ),
              const SizedBox(height: 10),
              _ActivityCard(
                'Sessions complétées',
                '$completedSessions',
                'Aujourd\'hui',
                Icons.check_circle_outline,
                const Color(0xFF7C3AED),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Build recommendations section
  Widget _buildRecommendationsSection(BuildContext context) {
    return BlocBuilder<AlertsCubit, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AlertsLoaded) {
          final recommendations = state.recommendations;

          if (recommendations.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'Aucune recommandation pour le moment',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return Column(
            children: recommendations.take(3).map((rec) {
              final priority = rec.priority;
              final color = priority == 'critical'
                  ? const Color(0xFFEF4444)
                  : priority == 'high'
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF059669);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        priority == 'critical'
                            ? Icons.error
                            : Icons.lightbulb_outline,
                        color: color,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.productName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            if (rec.recommendation.isNotEmpty)
                              Text(
                                rec.recommendation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Build predictions section
  Widget _buildPredictionsSection(BuildContext context) {
    return BlocBuilder<AlertsCubit, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AlertsLoaded) {
          final recommendations = state.recommendations;
          final predictions = recommendations
              .where(
                (r) =>
                    r.analysisType == 'prediction' ||
                    r.analysisType == 'forecast',
              )
              .toList();

          if (predictions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_down,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Analyse prédictive en cours...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: predictions.take(3).map((pred) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: const Color(0xFF7C3AED),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pred.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (pred.recommendation.isNotEmpty)
                              Text(
                                pred.recommendation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
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
          backgroundColor: color.withValues(alpha: 0.12),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
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
