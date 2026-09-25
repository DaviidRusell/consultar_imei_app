class ApiConstants {
  ApiConstants._();
  //TODO: Replace with your actual API base URL
  static const String baseUrl =
      'https://apiimeicolombia-production.up.railway.app';

  static String imeiEndpoint(String imei) => '$baseUrl/imei/$imei';

  static const Duration timeout = Duration(seconds: 15);
}
