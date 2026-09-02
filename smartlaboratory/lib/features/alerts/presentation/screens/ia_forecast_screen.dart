import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartlaboratory/features/alerts/presentation/cubit/alerts_cubit.dart';

class IAForecastScreen extends StatefulWidget {
  const IAForecastScreen({super.key});

  @override
  State<IAForecastScreen> createState() => _IAForecastScreenState();
}

class _IAForecastScreenState extends State<IAForecastScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AlertsCubit>().getRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prévisions IA'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            if (state is AlertsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AlertsLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockOverview(),
                  const SizedBox(height: 24),
                  _buildForecastChart(),
                  const SizedBox(height: 24),
                  _buildCriticalAlerts(state.recommendations),
                  const SizedBox(height: 24),
                  _buildRecommendations(state.recommendations),
                ],
              );
            }
            return const Center(child: Text('Erreur lors du chargement'));
          },
        ),
      ),
    );
  }

  Widget _buildStockOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock actuel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '450',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'unités en stock',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '8',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'jours avant rupture',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rupture prévue dans 8 jours',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendance de consommation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const dates = ['J-5', 'J-4', 'J-3', 'J-2', 'J-1'];
                          if (value.toInt() < dates.length) {
                            return Text(dates[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}'),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 120),
                        FlSpot(1, 135),
                        FlSpot(2, 128),
                        FlSpot(3, 145),
                        FlSpot(4, 152),
                      ],
                      isCurved: true,
                      color: Colors.deepPurple,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '+16% de pente précédente',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlerts(List<dynamic> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertes critiques',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...recommendations
            .where((r) => r.priority == 'critical')
            .map(
              (alert) => Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(Icons.error, color: Colors.red.shade700),
                  title: Text(alert.title ?? 'Alerte'),
                  subtitle: Text(alert.description ?? ''),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildRecommendations(List<dynamic> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommandations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...recommendations.map(
          (rec) => Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(rec.title ?? 'Recommandation'),
              subtitle: Text(rec.description ?? ''),
            ),
          ),
        ),
      ],
    );
  }
}
