import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../core/security/rate_limiter.dart';
import '../../domain/entities/imei_entity.dart';
import '../../domain/usecases/consult_imei_usecase.dart';

enum ImeiStatus { idle, loading, success, error }

class ImeiProvider extends ChangeNotifier {
  final ConsultImeiUseCase consultImeiUseCase;
  final RateLimiter _rateLimiter = RateLimiter();

  ImeiProvider({required this.consultImeiUseCase});

  ImeiStatus _status = ImeiStatus.idle;
  ImeiEntity? _resultado;
  String? _errorMessage;
  bool _isBusy = false; // candado adicional anti doble-tap

  ImeiStatus get status => _status;
  ImeiEntity? get resultado => _resultado;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ImeiStatus.loading;

  Future<void> consultar(String imei) async {
    // Candado: ignora toques repetidos mientras hay una consulta en curso
    if (_isBusy) return;

    final rateLimitMsg = _rateLimiter.checkAndRegister();
    if (rateLimitMsg != null) {
      _errorMessage = rateLimitMsg;
      _status = ImeiStatus.error;
      notifyListeners();
      return;
    }

    _isBusy = true;
    _status = ImeiStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final entity = await consultImeiUseCase(imei);
      _resultado = entity;
      _status = ImeiStatus.success;
    } on FormatException catch (e) {
      _errorMessage = e.message;
      _status = ImeiStatus.error;
    } on InvalidImeiException catch (e) {
      _errorMessage = e.message;
      _status = ImeiStatus.error;
    } on NotFoundException catch (e) {
      _errorMessage = e.message;
      _status = ImeiStatus.error;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _status = ImeiStatus.error;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      _status = ImeiStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado.';
      _status = ImeiStatus.error;
    } finally {
      _isBusy = false;
    }

    notifyListeners();
  }

  void reset() {
    _status = ImeiStatus.idle;
    _resultado = null;
    _errorMessage = null;
    notifyListeners();
  }
}
