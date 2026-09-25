import 'package:consultar_imei/core/ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/imei_provider.dart';
import '../widgets/imei_result_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _validationError;

  static const int _maxLen = 15;
  static const int _minLen = 14;

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _bannerAd = context.read<AdService>().createBannerAd(
      onLoaded: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _controller.dispose();
    super.dispose();
  }

  String? _validar(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Ingresa un IMEI';
    if (v.length < _minLen) return 'Faltan ${_minLen - v.length} dígitos';
    if (!RegExp(r'^\d{14,15}$').hasMatch(v)) return 'Solo se permiten números';
    return null;
  }

  Future<void> _consultar([String? imeiOverride]) async {
    final imei = (imeiOverride ?? _controller.text).trim();
    final error = _validar(imei);

    setState(() => _validationError = error);
    if (error != null) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<ImeiProvider>();
    await provider.consultar(imei);

    if (!mounted) return;

    if (provider.status == ImeiStatus.success) {
      context.read<AdService>().registrarConsultaYMostrarSiToca(
        onDismissed: () {
          if (mounted) _mostrarResultado();
        },
      );
    } else if (provider.status == ImeiStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  Future<dynamic> _mostrarResultado() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ImeiResultSheet(),
    );
  }

  Future<void> _escanear() async {
    final imeiEscaneado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );

    if (imeiEscaneado == null || !mounted) return;

    _controller.text = imeiEscaneado;
    setState(() => _validationError = null);
    await _consultar(imeiEscaneado); // consulta inmediata tras escanear
  }

  void _limpiar() {
    _controller.clear();
    setState(() => _validationError = null);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ImeiProvider>().isLoading;
    final currentLength = _controller.text.length;

    return Scaffold(
      bottomNavigationBar: _bannerAd == null
          ? null
          : SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
      appBar: AppBar(title: const Text('Consultar IMEI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Ingresa el IMEI de 14 o 15 dígitos, o escanéalo con la cámara',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_maxLen),
                ],
                onSubmitted: (_) => _consultar(),
                style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                decoration: InputDecoration(
                  hintText: '444444444444444',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _validationError,
                  counterText: '$currentLength/$_maxLen',
                  suffixIcon: currentLength > 0
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Limpiar',
                          onPressed: isLoading ? null : _limpiar,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isLoading ? null : () => _consultar(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(isLoading ? 'Consultando...' : 'CONSULTAR IMEI'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isLoading ? null : _escanear,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('ESCANEAR CÓDIGO DE BARRA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla de cámara aislada: retorna el IMEI detectado vía Navigator.pop
class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.code128, BarcodeFormat.ean13],
  );
  bool _detectado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detectado) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue ?? '';
      final digits = RegExp(r'\d{14,15}').firstMatch(raw)?.group(0);
      if (digits != null) {
        _detectado = true;
        _controller.stop();
        Navigator.pop(context, digits);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear código'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Apunta al código de barras del IMEI (pantalla *#06# o caja del equipo)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
