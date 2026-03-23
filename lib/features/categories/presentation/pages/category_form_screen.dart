import 'package:enhorario/features/categories/data/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.initial, required this.onSave});

  final CategoryModel? initial;
  final Future<String?> Function(CategoryModel model) onSave;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _iconoController;
  bool _activa = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.initial?.nombre ?? '',
    );
    _iconoController = TextEditingController(
      text: widget.initial?.icono ?? 'category',
    );
    _activa = widget.initial?.activa ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _iconoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? 'Nueva categoria' : 'Editar categoria',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _iconoController,
                decoration: const InputDecoration(labelText: 'Icono'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _activa,
                onChanged: (value) => setState(() => _activa = value),
                title: const Text('Activa'),
              ),
              const SizedBox(height: 16),
              if (_saving)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _saving = true);
                      final model = CategoryModel(
                        id: widget.initial?.id ?? '',
                        nombre: _nombreController.text.trim(),
                        icono: _iconoController.text.trim(),
                        activa: _activa,
                      );
                      final error = await widget.onSave(model);
                      if (!mounted) return;
                      setState(() => _saving = false);
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
