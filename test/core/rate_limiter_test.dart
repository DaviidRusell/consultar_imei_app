import 'package:flutter_test/flutter_test.dart';
import 'package:consultar_imei/core/security/rate_limiter.dart';

void main() {
  test('bloquea consultas en cooldown', () {
    final limiter = RateLimiter(cooldown: const Duration(milliseconds: 100));
    expect(limiter.checkAndRegister(), isNull);
    expect(limiter.checkAndRegister(), isNotNull); // muy pronto
  });

  test('bloquea tras exceder maxRequests', () async {
    final limiter = RateLimiter(
      maxRequests: 2,
      cooldown: Duration.zero,
      window: const Duration(seconds: 10),
    );
    expect(limiter.checkAndRegister(), isNull);
    expect(limiter.checkAndRegister(), isNull);
    expect(limiter.checkAndRegister(), isNotNull);
  });
}
