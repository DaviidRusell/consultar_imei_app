import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ads_constants.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  /// Cada cuántas consultas exitosas se muestra el intersticial.
  final int frequency;
  int _consultasDesdeUltimoAd = 0;

  AdService({this.frequency = 3});

  Future<void> initialize() => MobileAds.instance.initialize();

  BannerAd createBannerAd({required void Function() onLoaded}) {
    final banner = BannerAd(
      adUnitId: AdsConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }

  void loadInterstitial() {
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AdsConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  /// Se llama tras CADA consulta exitosa. Internamente decide si toca
  /// mostrar el anuncio según `frequency`. Si no toca, ejecuta
  /// `onDismissed` de inmediato (como si no hubiera anuncio).
  void registrarConsultaYMostrarSiToca({void Function()? onDismissed}) {
    _consultasDesdeUltimoAd++;

    if (_consultasDesdeUltimoAd < frequency) {
      onDismissed?.call();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      // No cargó a tiempo: no bloqueamos al usuario, seguimos normal
      // y lo intentamos de nuevo la próxima vez que toque.
      loadInterstitial();
      onDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _consultasDesdeUltimoAd = 0;
        loadInterstitial();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _consultasDesdeUltimoAd = 0;
        loadInterstitial();
        onDismissed?.call();
      },
    );

    ad.show();
    _interstitialAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
