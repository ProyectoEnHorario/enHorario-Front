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
    // Reset dialog state for clean state
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
                  child: BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
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
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedEstablishmentId = value;
                          });
                        },
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
                  onChanged: (bool? value) {
                    setDialogState(() {
                      _isPriority = value ?? false;
                    });
                  },
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
                    onChanged: (value) {
                      setDialogState(() {
                        _priorityReason = value ?? 'adulto_mayor';
                      });
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Tipo: Ticket Regular',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
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

  String _formatPriorityBadge(String tipo) {
    if (tipo == 'preferencial') {
      return '★ Prioritario';
    }
    return 'Regular';
  }

  Color _getPriorityColor(String tipo) {
    if (tipo == 'preferencial') {
      return Colors.amber;
    }
    return Colors.blue;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('d/M/y HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<UserTicketsCubit>.value(
        value: _userTicketsCubit,
        child: BlocListener<UserTicketsCubit, UserTicketsState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.successMessage!)),
              );
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<UserTicketsCubit, UserTicketsState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // Botón de crear ticket
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
                  // Sección de tickets activos
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Mis tickets',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  // Lista de tickets
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.tickets.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No tienes tickets activos',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Solicita uno para recibir atención',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ticket = state.tickets[index];
                          return _buildTicketCard(context, ticket, state);
                        },
                        childCount: state.tickets.length,
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              );
            },
          ),
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
              // Encabezado con código y badge de prioridad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket ${ticket.codigo}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(ticket.tipo).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPriorityColor(ticket.tipo),
                          ),
                        ),
                        child: Text(
                          _formatPriorityBadge(ticket.tipo),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(ticket.tipo),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Botón de eliminar
                  if (ticket.estado == 'en_espera' || ticket.estado == 'cancelado')
                    IconButton(
                      onPressed: state.isDeletingTurn
                          ? null
                          : () => _showDeleteConfirmation(context, ticket),
                      icon: state.isDeletingTurn
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      tooltip: 'Eliminar ticket',
                    ),
                ],
              ),
              const Divider(height: 20),
              // Detalles del ticket
              Text(
                'Establecimiento: ${ticket.establishmentId}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Posición en fila: ${ticket.posicion}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Estado: ${_formatEstado(ticket.estado)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getEstadoColor(ticket.estado),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Solicitado: ${_formatDateTime(ticket.solicitadoEn)}',
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
        content: const Text(
          '¿Está seguro de que desea eliminar este ticket? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
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

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'en_espera':
        return Colors.blue;
      case 'atendido':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
