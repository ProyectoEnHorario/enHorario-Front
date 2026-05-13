import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/core/navigation/role_guard.dart';
import 'package:enhorario/core/enums/app_role.dart';

class EstablishmentManagementScreen extends StatefulWidget {
  const EstablishmentManagementScreen({super.key});

  @override
  State<EstablishmentManagementScreen> createState() => _EstablishmentManagementScreenState();
}

class _EstablishmentManagementScreenState extends State<EstablishmentManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos todos los establecimientos sin filtro de adminId (para superadmin)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RealEstablishmentsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<RealEstablishmentsCubit>().load(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final items = state.items;

        if (items.isEmpty) {
          return const Center(
            child: Text('No hay establecimientos registrados.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _EstablishmentCard(establishment: item);
          },
        );
      },
    );
  }
}

class _EstablishmentCard extends StatelessWidget {
  final RailwayEstablishmentView establishment;

  const _EstablishmentCard({required this.establishment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = establishment.status.toUpperCase() == 'OPEN';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.store, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        establishment.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        establishment.categoryName ?? 'Sin categoría',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    // TODO: Implementar activación/desactivación (ENH-319)
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${establishment.addressLine}, ${establishment.city}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implementar asignación (ENH-318)
                  },
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Asignar'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // TODO: Implementar eliminación (ENH-321)
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
