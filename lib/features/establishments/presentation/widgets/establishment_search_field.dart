import 'package:flutter/material.dart';

class EstablishmentSearchField extends StatelessWidget {
  const EstablishmentSearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Buscar establecimiento',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: value.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar busqueda',
                onPressed: onClear,
                icon: const Icon(Icons.clear),
              ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
