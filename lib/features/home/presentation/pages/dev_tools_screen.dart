import 'dart:convert';

import 'package:enhorario/core/api/api_client.dart';
import 'package:flutter/material.dart';

class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  final ApiClient _api = ApiClient();

  final TextEditingController _tokenCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'test@enhorario.com',
  );
  final TextEditingController _passwordCtrl = TextEditingController(
    text: 'test1234',
  );
  final TextEditingController _establishmentCtrl = TextEditingController(
    text: 'est-banco-centro',
  );
  final TextEditingController _turnIdCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController(
    text: 'ATTENDED',
  );

  String _log = 'Panel listo. Ejecuta una prueba.';
  bool _loading = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _establishmentCtrl.dispose();
    _turnIdCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      _appendLog('Error no controlado: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _appendLog(String text) {
    final now = DateTime.now().toIso8601String();
    setState(() {
      _log = '[$now] $text\n\n$_log';
    });
  }

  String _pretty(dynamic data) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String? get _token {
    final token = _tokenCtrl.text.trim();
    return token.isEmpty ? null : token;
  }

  Future<void> _health() async {
    final response = await _api.get<dynamic>('/health');
    _appendLog('GET /health\n${_pretty(response)}');
  }

  Future<void> _login() async {
    final response = await _api.post<dynamic>(
      '/auth/login',
      data: {
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      },
    );

    if (response is Map<String, dynamic>) {
      final token = response['token'] as String?;
      if (token != null && token.isNotEmpty) {
        _tokenCtrl.text = token;
      }
    }

    _appendLog('POST /auth/login\n${_pretty(response)}');
  }

  Future<void> _register() async {
    final response = await _api.post<dynamic>(
      '/auth/register',
      data: {
        'name': 'Usuario',
        'lastName': 'Debug',
        'email': _emailCtrl.text.trim(),
        'phone': '3000000000',
        'password': _passwordCtrl.text,
      },
    );
    _appendLog('POST /auth/register\n${_pretty(response)}');
  }

  Future<void> _listEstablishments() async {
    final response = await _api.get<dynamic>(
      '/establishments',
      queryParameters: {'page': 0, 'size': 20},
      token: _token,
    );
    _appendLog('GET /establishments\n${_pretty(response)}');
  }

  Future<void> _myTurns() async {
    final response = await _api.get<dynamic>('/turns/my-turns', token: _token);
    _appendLog('GET /turns/my-turns\n${_pretty(response)}');
  }

  Future<void> _createTurn() async {
    final response = await _api.post<dynamic>(
      '/turns',
      token: _token,
      data: {
        'establishmentId': _establishmentCtrl.text.trim(),
        'turnType': 'REGULAR',
      },
    );
    _appendLog('POST /turns\n${_pretty(response)}');
  }

  Future<void> _updateTurn() async {
    final turnId = _turnIdCtrl.text.trim();
    if (turnId.isEmpty) {
      _appendLog('Debes ingresar turnId para actualizar estado.');
      return;
    }

    final response = await _api.put<dynamic>(
      '/turns/$turnId/status',
      data: const {},
      queryParameters: {'status': _statusCtrl.text.trim()},
      token: _token,
    );
    _appendLog('PUT /turns/$turnId/status\n${_pretty(response)}');
  }

  Future<void> _cancelTurn() async {
    final turnId = _turnIdCtrl.text.trim();
    if (turnId.isEmpty) {
      _appendLog('Debes ingresar turnId para cancelar.');
      return;
    }

    await _api.delete('/turns/$turnId/cancel', token: _token);
    _appendLog('DELETE /turns/$turnId/cancel\nOK');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo test avanzado')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Casos de uso recomendados',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Health check: valida conectividad a Railway.\n'
            '2. Login/Register: valida autenticacion y token.\n'
            '3. Listar establecimientos: valida lectura de catalogo.\n'
            '4. Crear turno -> listar mis turnos -> actualizar estado -> cancelar.\n'
            '5. Combina este panel con los CRUD locales para validar relaciones de datos.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email backend'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Password backend'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tokenCtrl,
            decoration: const InputDecoration(
              labelText: 'Token (editable para pruebas manuales)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _establishmentCtrl,
            decoration: const InputDecoration(labelText: 'establishmentId'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _turnIdCtrl,
            decoration: const InputDecoration(labelText: 'turnId'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _statusCtrl,
            decoration: const InputDecoration(
              labelText: 'status para update (WAITING/CALLED/ATTENDED/CANCELLED)',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_health),
                child: const Text('Health'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_register),
                child: const Text('Register'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_login),
                child: const Text('Login'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_listEstablishments),
                child: const Text('List establishments'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_createTurn),
                child: const Text('Create turn'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_myTurns),
                child: const Text('My turns'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_updateTurn),
                child: const Text('Update turn status'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : () => _run(_cancelTurn),
                child: const Text('Cancel turn'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          SelectableText(_log),
        ],
      ),
    );
  }
}
