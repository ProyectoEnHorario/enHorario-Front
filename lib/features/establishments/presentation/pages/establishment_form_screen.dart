import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:flutter/material.dart';

class EstablishmentFormScreen extends StatefulWidget {
  const EstablishmentFormScreen({
    super.key,
    this.initial,
    required this.onSave,
  });

  final EstablishmentModel? initial;
  final Future<String?> Function(EstablishmentModel model) onSave;

  @override
  State<EstablishmentFormScreen> createState() =>
      _EstablishmentFormScreenState();
}

class _EstablishmentFormScreenState extends State<EstablishmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _direccion;
  late final TextEditingController _categoryId;
  bool _activo = true;
  bool _abierto = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nombre = TextEditingController(text: initial?.nombre ?? '');
    _descripcion = TextEditingController(text: initial?.descripcion ?? '');
    _direccion = TextEditingController(text: initial?.direccion ?? '');
    _categoryId = TextEditingController(text: initial?.categoryId ?? '');
    _activo = initial?.activo ?? true;
    _abierto = initial?.abierto ?? false;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _direccion.dispose();
    _categoryId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null
              ? 'Nuevo establecimiento'
              : 'Editar establecimiento',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripcion'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Direccion'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryId,
                decoration: const InputDecoration(labelText: 'Category ID'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              SwitchListTile(
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
                title: const Text('Activo'),
              ),
              SwitchListTile(
                value: _abierto,
                onChanged: (v) => setState(() => _abierto = v),
                title: const Text('Abierto'),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _loading = true);
                      final model = EstablishmentModel(
                        id: widget.initial?.id ?? '',
                        nombre: _nombre.text.trim(),
                        nombreNormalizado: '',
                        descripcion: _descripcion.text.trim().isEmpty
                            ? null
                            : _descripcion.text.trim(),
                        direccion: _direccion.text.trim(),
                        categoryId: _categoryId.text.trim(),
                        adminId: widget.initial?.adminId ?? '',
                        activo: _activo,
                        abierto: _abierto,
                        createdAt: widget.initial?.createdAt ?? DateTime.now(),
                      );
                      final error = await widget.onSave(model);
                      if (!mounted) return;
                      setState(() => _loading = false);
                      if (error != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Guardado correctamente')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
