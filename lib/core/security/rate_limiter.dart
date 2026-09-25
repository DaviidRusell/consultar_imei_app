/// Limita la frecuencia de consultas para evitar saturar la API
/// o exponerla a ataques de fuerza bruta / scraping.
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Duration cooldown;

  final List<DateTime> _timestamps = [];
  DateTime? _lastRequest;

  RateLimiter({
    this.maxRequests = 8,
    this.window = const Duration(minutes: 1),
    this.cooldown = const Duration(seconds: 2),
  });

  /// Retorna null si se puede continuar, o un mensaje de error si no.
  String? checkAndRegister() {
    final now = DateTime.now();

    if (_lastRequest != null && now.difference(_lastRequest!) < cooldown) {
      final restante = cooldown - now.difference(_lastRequest!);
      return 'Espera ${restante.inSeconds + 1}s antes de otra consulta';
    }

    _timestamps.removeWhere((t) => now.difference(t) > window);

    if (_timestamps.length >= maxRequests) {
      return 'Demasiadas consultas. Intenta de nuevo en un momento.';
    }

    _timestamps.add(now);
    _lastRequest = now;
    return null;
  }
}
