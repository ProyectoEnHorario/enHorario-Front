import 'package:enhorario/features/establishments/presentation/bloc/wait_time_report_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormularioTiempoEsperaWidget extends StatefulWidget {
  const FormularioTiempoEsperaWidget({
    super.key,
    required this.establishmentId,
  });

  final String establishmentId;

  @override
  State<FormularioTiempoEsperaWidget> createState() => _FormularioTiempoEsperaWidgetState();
}

class _FormularioTiempoEsperaWidgetState extends State<FormularioTiempoEsperaWidget> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final text = _minutesController.text.trim();
      final minutes = int.tryParse(text) ?? 0;
      context.read<WaitTimeReportCubit>().reportTime(widget.establishmentId, minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaitTimeReportCubit, WaitTimeReportState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Gracias! Tu reporte se envió exitosamente.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final yaReporto = context.read<WaitTimeReportCubit>().hasAlreadyReported(widget.establishmentId);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reportar tiempo de espera',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ayuda a otros compartiendo los minutos reales que demoraste en ser atendido.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (yaReporto)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ya enviaste un reporte durante esta sesión. ¡Gracias por tu aporte!',
                    style: TextStyle(color: Colors.brown),
                  ),
                )
              else ...[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    enabled: !state.isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Minutos de espera',
                      hintText: 'Ej. 15',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Ingresa un valor';
                      final val = int.tryParse(value.trim());
                      if (val == null || val <= 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Enviar Reporte'),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
