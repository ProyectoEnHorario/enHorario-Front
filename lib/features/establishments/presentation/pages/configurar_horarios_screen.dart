import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/models/schedule_model.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter/material.dart';

class ConfigurarHorariosScreen extends StatefulWidget {
  final String establishmentId;

  const ConfigurarHorariosScreen({
    super.key,
    required this.establishmentId,
  });

  @override
  State<ConfigurarHorariosScreen> createState() => _ConfigurarHorariosScreenState();
}

class _ConfigurarHorariosScreenState extends State<ConfigurarHorariosScreen> {
  final ScheduleModel _schedule = ScheduleModel.defaultSchedule();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Horarios'),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)))
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveSchedule,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _schedule.days.length,
        itemBuilder: (context, index) {
          final day = _schedule.days[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Switch(
                        value: !day.isClosed,
                        onChanged: (val) => setState(() => day.isClosed = !val),
                      ),
                    ],
                  ),
                  if (!day.isClosed) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimePicker('Apertura', day.openTime, (time) => setState(() => day.openTime = time)),
                        const Icon(Icons.arrow_forward, color: Colors.grey),
                        _buildTimePicker('Cierre', day.closeTime, (time) => setState(() => day.closeTime = time)),
                      ],
                    ),
                  ] else
                    const Text('Cerrado todo el día', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onSelected) {
    return InkWell(
      onTap: () async {
        final selected = await showTimePicker(context: context, initialTime: time);
        if (selected != null) onSelected(selected);
      },
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(time.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    setState(() => _isSaving = true);
    final service = RailwayEstablishmentQueryService(ApiClient());
    final result = await service.updateEstablishmentSchedule(widget.establishmentId, _schedule.toMap());

    if (mounted) {
      setState(() => _isSaving = false);
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red)),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horarios actualizados correctamente')));
          Navigator.pop(context);
        },
      );
    }
  }
}
