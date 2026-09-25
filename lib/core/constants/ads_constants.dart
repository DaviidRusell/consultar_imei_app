import 'dart:io';

class AdsConstants {
  AdsConstants._();

  // TODO: reemplazar por tus IDs reales antes de publicar,
  // idealmente inyectados via --dart-define en el build de CI/CD
  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static String get bannerAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return const String.fromEnvironment('BANNER_AD_UNIT_ID');
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return const String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID');
  }
}
