import 'package:flutter/material.dart';

import 'manual_input_screen.dart';
import 'scanner_screen.dart';
import 'dial_code_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar IMEI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.phonelink_lock, size: 96),
              const SizedBox(height: 12),
              Text(
                'Verifica el estado de un IMEI en las bases oficiales de Colombia',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              _OptionButton(
                icon: Icons.keyboard,
                label: 'Ingresar IMEI manualmente',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManualInputScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _OptionButton(
                icon: Icons.dialpad,
                label: 'Consultar el IMEI de este equipo',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DialCodeScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _OptionButton(
                icon: Icons.qr_code_scanner,
                label: 'Escanear código de barras',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label),
      ),
      style: FilledButton.styleFrom(alignment: Alignment.centerLeft),
    );
  }
}
