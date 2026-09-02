import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ai_recommendations_cubit.dart';
import '../cubit/ai_recommendations_state.dart';
import '../widgets/ai_recommendation_card.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  // ignore: prefer_final_fields
  String _selectedFilter = 'all';
  // ignore: prefer_final_fields
  String _selectedAnalysisType = 'all';

  @override
  void initState() {
    super.initState();
    context.read<AIRecommendationsCubit>().loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA - Stock'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AIRecommendationsCubit>().loadRecommendations(
                isResolved: _selectedFilter == 'unresolved' ? false : null,
                analysisType: _selectedAnalysisType == 'all'
                    ? null
                    : _selectedAnalysisType,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'analyze') {
                _showAnalysisDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'analyze',
                child: Text('Lancer une analyse'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Paramètres'),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<AIRecommendationsCubit, AIRecommendationsState>(
        listener: (context, state) {
          if (state is AIRecommendationsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AIRecommendationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AIRecommendationsAnalysisComplete) {
            final summary = state.summary;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.message}\n'
                  'Alertes critiques: ${summary['critical_alerts'] ?? 0}\n'
                  'Alertes hautes: ${summary['high_alerts'] ?? 0}',
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        child: BlocBuilder<AIRecommendationsCubit, AIRecommendationsState>(
          builder: (context, state) {
            if (state is AIRecommendationsLoading ||
                state is AIRecommendationsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AIRecommendationsAnalyzing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Analyse en cours...'),
                  ],
                ),
              );
            } else if (state is AIRecommendationsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<AIRecommendationsCubit>()
                            .loadRecommendations();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            } else if (state is AIRecommendationsLoaded) {
              final recommendations = state.recommendations;

              if (recommendations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      const Text('Aucune alerte pour le moment'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAnalysisDialog(context),
                        icon: const Icon(Icons.analytics),
                        label: const Text('Lancer une analyse'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context
                      .read<AIRecommendationsCubit>()
                      .loadRecommendations(
                        isResolved: _selectedFilter == 'unresolved'
                            ? false
                            : null,
                        analysisType: _selectedAnalysisType == 'all'
                            ? null
                            : _selectedAnalysisType,
                      );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Statistiques
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatCard(
                              label: 'Critiques',
                              value: state.criticalCount.toString(),
                              color: Colors.red,
                            ),
                            _StatCard(
                              label: 'Hautes',
                              value: state.highCount.toString(),
                              color: Colors.orange,
                            ),
                            _StatCard(
                              label: 'Total',
                              value: recommendations.length.toString(),
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),

                      // Filtres
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _FilterChip(
                                      label: 'Tous',
                                      isSelected: _selectedFilter == 'all',
                                      onTap: () {
                                        setState(() => _selectedFilter = 'all');
                                        context
                                            .read<AIRecommendationsCubit>()
                                            .loadRecommendations(
                                              analysisType:
                                                  _selectedAnalysisType == 'all'
                                                  ? null
                                                  : _selectedAnalysisType,
                                            );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _FilterChip(
                                      label: 'Non résolus',
                                      isSelected:
                                          _selectedFilter == 'unresolved',
                                      onTap: () {
                                        setState(
                                          () => _selectedFilter = 'unresolved',
                                        );
                                        context
                                            .read<AIRecommendationsCubit>()
                                            .loadRecommendations(
                                              isResolved: false,
                                              analysisType:
                                                  _selectedAnalysisType == 'all'
                                                  ? null
                                                  : _selectedAnalysisType,
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recommandations
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation = recommendations[index];
                          return AIRecommendationCard(
                            recommendation: recommendation,
                            onMarkResolved: () {
                              context
                                  .read<AIRecommendationsCubit>()
                                  .markAsResolved(recommendation.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showAnalysisDialog(BuildContext context) {
    int daysLookback = 30;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Lancer une analyse'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Analyser les derniers :'),
                  const SizedBox(height: 12),
                  Slider(
                    value: daysLookback.toDouble(),
                    min: 7,
                    max: 90,
                    divisions: 10,
                    label: '$daysLookback jours',
                    onChanged: (value) {
                      setState(() {
                        daysLookback = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AIRecommendationsCubit>().runAnalysis(
                      daysLookback: daysLookback,
                    );
                  },
                  child: const Text('Lancer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey),
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
