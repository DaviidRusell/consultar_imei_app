import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../core/ads/ad_service.dart';
import '../providers/imei_provider.dart';

class ImeiResultSheet extends StatefulWidget {
  const ImeiResultSheet({super.key});

  @override
  State<ImeiResultSheet> createState() => _ImeiResultSheetState();
}

class _ImeiResultSheetState extends State<ImeiResultSheet> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = context.read<AdService>().createBannerAd(
      onLoaded: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<ImeiProvider>().resultado;
    if (resultado == null) return const SizedBox.shrink();

    final esLimpio = resultado.isLimpio;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Expanded(
            child: ListView(
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
          ),
          if (_bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
