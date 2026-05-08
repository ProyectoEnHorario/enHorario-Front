import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/features/turns/presentation/bloc/daily_summary_cubit.dart';
import 'package:intl/intl.dart';

class DailySummaryWidget extends StatelessWidget {
  final String establishmentId;

  const DailySummaryWidget({
    super.key,
    required this.establishmentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailySummaryCubit, DailySummaryState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (state.error != null) {
          return Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'Atendidos',
                  value: '${state.totalAtendidos}',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _MetricCard(
                  title: 'Cancelados',
                  value: '${state.totalCancelados}',
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                ),
                _MetricCard(
                  title: 'Espera Prom.',
                  value: '${state.tiempoPromedioEsperaMinutos} min',
                  icon: Icons.access_time,
                  color: Colors.blue,
                ),
                _MetricCard(
                  title: 'Prioritarios',
                  value: '${state.porcentajePrioritarios.toStringAsFixed(1)}%',
                  icon: Icons.bolt,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DailySummaryState state) {
    final dateStr = DateFormat('dd/MM/yyyy').format(state.selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Resumen de Hoy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () => _selectDate(context, state),
          icon: const Icon(Icons.calendar_month, size: 18),
          label: Text(dateStr),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, DailySummaryState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<DailySummaryCubit>().loadSummary(establishmentId, date: picked);
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.9),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
