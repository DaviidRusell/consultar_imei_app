import 'package:consultar_imei/core/ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
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
    if (v.isEmpty) return 'IMEI INVALIDO';
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
        child: SingleChildScrollView(
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
                  hintText: 'Digita aquí el IMEI',
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
              const SizedBox(height: 24),
              const _ImeiHelpCard(),
              const _FuenteOficialCard(),
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

class _ImeiHelpCard extends StatelessWidget {
  const _ImeiHelpCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¿Cómo consultar el IMEI de tu teléfono?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _HelpStep(
            numero: 1,
            texto: 'Abre la app de Teléfono de tu celular.',
          ),
          const _HelpStep(
            numero: 2,
            texto: 'Marca *#06# (no necesitas llamar).',
          ),
          const _HelpStep(
            numero: 3,
            texto: 'Aparecerá una ventana con tu IMEI (15 dígitos).',
          ),
          const _HelpStep(
            numero: 4,
            texto: 'Escríbelo arriba o toca "Escanear código de barra" para leerlo de esa pantalla.',
          ),
          const SizedBox(height: 4),
          Text(
            'Si tu teléfono tiene dos SIM verás dos IMEI; consulta cada uno por separado.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FuenteOficialCard extends StatelessWidget {
  const _FuenteOficialCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esta app no es oficial ni está afiliada al Gobierno de Colombia, '
            'la CRC ni ningún operador móvil. La información se basa en datos '
            'públicos regulados por la CRC.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () =>
                launchUrl(Uri.parse('https://www.imeicolombia.com.co/')),
            child: Text(
              'Ver plataforma oficial de consulta de IMEI',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: () => launchUrl(Uri.parse('https://www.crcom.gov.co/')),
            child: Text(
              'Entidad reguladora: CRC (crcom.gov.co)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  final int numero;
  final String texto;
  const _HelpStep({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            child: Text('$numero', style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
