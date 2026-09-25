import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ads_constants.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

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

  /// Muestra el intersticial si está listo; siempre precarga el siguiente.
  void showInterstitialIfReady({void Function()? onDismissed}) {
    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial(); // precarga el próximo
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
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
