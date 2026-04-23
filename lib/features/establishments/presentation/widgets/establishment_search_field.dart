import 'package:flutter/material.dart';

class EstablishmentSearchField extends StatefulWidget {
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
  State<EstablishmentSearchField> createState() =>
      _EstablishmentSearchFieldState();
}

class _EstablishmentSearchFieldState extends State<EstablishmentSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant EstablishmentSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller
        ..text = widget.value
        ..selection = TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Buscar por nombre',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.value.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
                icon: const Icon(Icons.clear),
              ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
