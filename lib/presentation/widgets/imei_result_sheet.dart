import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/imei_provider.dart';

class ImeiResultSheet extends StatelessWidget {
  const ImeiResultSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<ImeiProvider>().resultado;
    if (resultado == null) return const SizedBox.shrink();

    final esLimpio = resultado.isLimpio;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                esLimpio ? Icons.check_circle : Icons.warning,
                color: esLimpio ? Colors.green : Colors.red,
                size: 28,
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
