import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/afluencia_stats/data/repositories/hybrid_afluencia_dashboard_repository.dart';
import 'package:enhorario/features/afluencia_stats/data/repositories/local_afluencia_dashboard_service.dart';
import 'package:enhorario/features/afluencia_stats/data/repositories/railway_afluencia_dashboard_service.dart';
import 'package:enhorario/features/afluencia_stats/domain/filters/stats_date_filter.dart';
import 'package:enhorario/features/afluencia_stats/presentation/bloc/afluencia_stats_cubit.dart';
import 'package:enhorario/features/afluencia_stats/presentation/widgets/charts/stats_bar_chart_card.dart';
import 'package:enhorario/features/afluencia_stats/presentation/widgets/charts/stats_donut_chart_card.dart';
import 'package:enhorario/features/afluencia_stats/presentation/widgets/charts/stats_line_chart_card.dart';
import 'package:enhorario/features/afluencia_stats/presentation/widgets/charts/stats_metric_card.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AfluenciaStatsScreen extends StatelessWidget {
  const AfluenciaStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AfluenciaStatsCubit(
        HybridAfluenciaDashboardRepository(
          RailwayAfluenciaDashboardService(ApiClient()),
          LocalAfluenciaDashboardService(),
        ),
        AuthSessionRepository(),
      ),
      child: const _AfluenciaStatsView(),
    );
  }
}

class _AfluenciaStatsView extends StatelessWidget {
  const _AfluenciaStatsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AfluenciaStatsCubit, AfluenciaStatsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.accessDenied) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Acceso denegado. Solo administradores pueden visualizar estadisticas.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state.error != null && state.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: context.read<AfluenciaStatsCubit>().refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final dashboard = state.data;
        if (dashboard == null || !dashboard.hasData) {
          return Column(
            children: [
              _DateFilterHeader(state: state),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay datos para el periodo seleccionado',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _DateFilterHeader(state: state),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.isRefreshing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 920;

                  final metrics = [
                    StatsMetricCard(
                      title: 'Visitas totales',
                      value: dashboard.totalVisits.toString(),
                      icon: Icons.groups_outlined,
                    ),
                    StatsMetricCard(
                      title: 'Hora pico',
                      value: dashboard.peakHourLabel,
                      icon: Icons.schedule,
                    ),
                    StatsMetricCard(
                      title: 'Visitas prioritarias',
                      value: dashboard.priorityVisits.toString(),
                      icon: Icons.priority_high,
                    ),
                  ];

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (dashboard.isFallbackData)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Mostrando datos de demostracion porque el endpoint de estadisticas no esta disponible.',
                          ),
                        ),
                      if (isWide)
                        Row(
                          children: [
                            for (var i = 0; i < metrics.length; i++) ...[
                              Expanded(child: metrics[i]),
                              if (i < metrics.length - 1)
                                const SizedBox(width: 12),
                            ],
                          ],
                        )
                      else
                        ...metrics.map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: card,
                          ),
                        ),
                      const SizedBox(height: 4),
                      StatsLineChartCard(
                        title: 'Evolucion de visitas por dia',
                        points: dashboard.visitsTimeline,
                        emptyLabel: 'No hay visitas registradas para este periodo.',
                      ),
                      const SizedBox(height: 12),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: StatsBarChartCard(
                                title: 'Establecimientos mas consultados',
                                items: dashboard.mostConsultedEstablishments,
                                emptyLabel: 'No hay establecimientos consultados.',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatsBarChartCard(
                                title: 'Categorias mas populares',
                                items: dashboard.mostPopularCategories,
                                emptyLabel: 'No hay categorias populares.',
                              ),
                            ),
                          ],
                        )
                      else ...[
                        StatsBarChartCard(
                          title: 'Establecimientos mas consultados',
                          items: dashboard.mostConsultedEstablishments,
                          emptyLabel: 'No hay establecimientos consultados.',
                        ),
                        const SizedBox(height: 12),
                        StatsBarChartCard(
                          title: 'Categorias mas populares',
                          items: dashboard.mostPopularCategories,
                          emptyLabel: 'No hay categorias populares.',
                        ),
                      ],
                      const SizedBox(height: 12),
                      StatsDonutChartCard(
                        title: 'Distribucion de visitas',
                        primaryLabel: 'Regulares',
                        primaryValue: dashboard.regularVisits,
                        secondaryLabel: 'Prioritarias',
                        secondaryValue: dashboard.priorityVisits,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DateFilterHeader extends StatelessWidget {
  const _DateFilterHeader({required this.state});

  final AfluenciaStatsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AfluenciaStatsCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Hoy'),
                selected: state.filter.preset == StatsDatePreset.today,
                onSelected: (_) => cubit.setPreset(StatsDatePreset.today),
              ),
              ChoiceChip(
                label: const Text('Ultima semana'),
                selected: state.filter.preset == StatsDatePreset.lastWeek,
                onSelected: (_) => cubit.setPreset(StatsDatePreset.lastWeek),
              ),
              ChoiceChip(
                label: const Text('Ultimo mes'),
                selected: state.filter.preset == StatsDatePreset.lastMonth,
                onSelected: (_) => cubit.setPreset(StatsDatePreset.lastMonth),
              ),
              OutlinedButton.icon(
                onPressed: () => _selectCustomRange(context),
                icon: const Icon(Icons.date_range),
                label: const Text('Rango personalizado'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rango activo: ${_formatDate(state.filter.from)} - ${_formatDate(state.filter.to)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(start: state.filter.from, end: state.filter.to),
    );

    if (picked == null || !context.mounted) return;

    context.read<AfluenciaStatsCubit>().setCustomRange(picked.start, picked.end);
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }
}
