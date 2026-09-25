import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/imei_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<ImeiProvider>().resultado;

    if (resultado == null) {
      return const Scaffold(body: Center(child: Text('Sin datos')));
    }

    final esLimpio = resultado.isLimpio;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: esLimpio
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        esLimpio ? Icons.check_circle : Icons.warning,
                        color: esLimpio ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        resultado.estado.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('IMEI: ${resultado.imei}'),
                  const SizedBox(height: 8),
                  Text(resultado.resumen),
                ],
              ),
            ),
          ),
          if (resultado.reportes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Reportes (${resultado.totalReportes})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...resultado.reportes.map(
              (r) => Card(
                child: ListTile(
                  title: Text(r.causalTexto),
                  subtitle: Text('Operador: ${r.operador}'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
