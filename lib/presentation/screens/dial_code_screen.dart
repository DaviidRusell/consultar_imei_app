import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'manual_input_screen.dart';

class DialCodeScreen extends StatelessWidget {
  const DialCodeScreen({super.key});

  Future<void> _abrirMarcador(BuildContext context) async {
    final uri = Uri.parse('tel:*%2306%23');
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el marcador')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IMEI de este equipo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Por políticas de seguridad de Android e iOS, las apps no pueden '
              'leer el IMEI directamente. Sigue estos pasos:',
            ),
            const SizedBox(height: 16),
            const _Paso(
              numero: 1,
              texto: 'Toca el botón para abrir el marcador telefónico',
            ),
            const _Paso(numero: 2, texto: 'Se marcará automáticamente *#06#'),
            const _Paso(
              numero: 3,
              texto: 'Copia el IMEI que aparece en pantalla',
            ),
            const _Paso(
              numero: 4,
              texto: 'Pégalo en la siguiente pantalla para consultarlo',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _abrirMarcador(context),
              icon: const Icon(Icons.dialpad),
              label: const Text('Abrir marcador (*#06#)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualInputScreen()),
              ),
              child: const Text('Ya tengo mi IMEI, continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final int numero;
  final String texto;
  const _Paso({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 12, child: Text('$numero')),
          const SizedBox(width: 12),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
