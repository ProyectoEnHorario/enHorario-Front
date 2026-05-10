import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/presentation/bloc/user_tickets_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TurnsScreen extends StatefulWidget {
  const TurnsScreen({super.key});

  @override
  State<TurnsScreen> createState() => _TurnsScreenState();
}

class _TurnsScreenState extends State<TurnsScreen> {
  String? _selectedEstablishmentId;
  bool _isPriority = false;
  String _priorityReason = 'adulto_mayor';
  late UserTicketsCubit _userTicketsCubit;

  @override
  void initState() {
    super.initState();
    _userTicketsCubit = UserTicketsCubit();
    _userTicketsCubit.loadUserTickets();
  }

  @override
  void dispose() {
    _userTicketsCubit.close();
    super.dispose();
  }

  void _showCreateTicketDialog() {
    _selectedEstablishmentId = null;
    _isPriority = false;
    _priorityReason = 'adulto_mayor';

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Solicitar nuevo ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seleccionar establecimiento:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                BlocProvider(
                  create: (_) => RealEstablishmentsCubit(
                    RailwayEstablishmentQueryService(ApiClient()),
                  ),
                  child:
                      BlocBuilder<
                        RealEstablishmentsCubit,
                        RealEstablishmentsState
                      >(
                        builder: (context, state) {
                          return DropdownButtonFormField<String>(
                            value: _selectedEstablishmentId,
                            hint: const Text('Elige un establecimiento'),
                            isExpanded: true,
                            items: state.items.map((establishment) {
                              return DropdownMenuItem<String>(
                                value: establishment.id,
                                child: Text(establishment.name),
                              );
                            }).toList(),
                            onChanged: (value) => setDialogState(
                              () => _selectedEstablishmentId = value,
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tipo de ticket:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Ticket con prioridad'),
                  value: _isPriority,
                  onChanged: (bool? value) =>
                      setDialogState(() => _isPriority = value ?? false),
                ),
                if (_isPriority) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Razón de prioridad:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _priorityReason,
                    items: const [
                      DropdownMenuItem(
                        value: 'adulto_mayor',
                        child: Text('Adulto mayor (65+)'),
                      ),
                      DropdownMenuItem(
                        value: 'mujer_gestante',
                        child: Text('Mujer en estado de gestación'),
                      ),
                    ],
                    onChanged: (value) => setDialogState(
                      () => _priorityReason = value ?? 'adulto_mayor',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: _selectedEstablishmentId == null
                  ? null
                  : () {
                      _userTicketsCubit.createTurn(
                        establishmentId: _selectedEstablishmentId!,
                        isPriority: _isPriority,
                        priorityReason: _isPriority ? _priorityReason : null,
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Crear ticket'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Turnos'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Activos',
                icon: Icon(Icons.confirmation_number_outlined),
              ),
              Tab(text: 'Historial', icon: Icon(Icons.history_outlined)),
            ],
          ),
        ),
        body: BlocProvider<UserTicketsCubit>.value(
          value: _userTicketsCubit,
          child: BlocListener<UserTicketsCubit, UserTicketsState>(
            listener: (context, state) {
              if (state.successMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              }
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: TabBarView(
              children: [_buildActiveTurnsTab(), _buildHistoryTurnsTab()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTurnsTab() {
    return BlocBuilder<UserTicketsCubit, UserTicketsState>(
      builder: (context, state) {
        final activeTickets = state.tickets
            .where((t) => t.estado == 'en_espera')
            .toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: _showCreateTicketDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Solicitar nuevo ticket'),
                ),
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (activeTickets.isEmpty)
              _buildEmptyState(
                'No tienes tickets activos',
                'Solicita uno para recibir atención',
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildTicketCard(context, activeTickets[index], state),
                  childCount: activeTickets.length,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTurnsTab() {
    return BlocBuilder<UserTicketsCubit, UserTicketsState>(
      builder: (context, state) {
        final historyTickets = state.tickets
            .where((t) => t.estado != 'en_espera')
            .toList();
        return CustomScrollView(
          slivers: [
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (historyTickets.isEmpty)
              _buildEmptyState(
                'Historial vacío',
                'Tus turnos finalizados aparecerán aquí',
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildTicketCard(context, historyTickets[index], state),
                    childCount: historyTickets.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    TurnModel ticket,
    UserTicketsState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ticket ${ticket.codigo}',
                      style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (ticket.estado == 'en_espera' ||
                      ticket.estado == 'cancelado')
                    IconButton(
                      onPressed: state.isDeletingTurn
                          ? null
                          : () => _showDeleteConfirmation(context, ticket),
                      icon: state.isDeletingTurn
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                    ),
                ],
              ),
              const Divider(),
              Text('Establecimiento: ${ticket.establishmentId}'),
              const SizedBox(height: 8),
              Text(
                'Estado: ${_formatEstado(ticket.estado)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getEstadoColor(ticket.estado, context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Solicitado: ${DateFormat('d/M/y HH:mm').format(ticket.solicitadoEn)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TurnModel ticket) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eliminar ticket'),
        content: const Text('¿Está seguro de que desea eliminar este ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () {
              _userTicketsCubit.deleteTurn(ticket.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatEstado(String estado) {
    switch (estado) {
      case 'en_espera':
        return 'En espera';
      case 'atendido':
        return 'Atendido';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (estado) {
      case 'en_espera':
        return scheme.secondary;
      case 'atendido':
        return scheme.tertiary;
      case 'cancelado':
        return scheme.error;
      default:
        return scheme.onSurface.withOpacity(0.6);
    }
  }
}
