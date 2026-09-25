import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/imei_entity.dart';
import '../../domain/usecases/consult_imei_usecase.dart';

enum ImeiStatus { idle, loading, success, error }

class ImeiProvider extends ChangeNotifier {
  final ConsultImeiUseCase consultImeiUseCase;

  ImeiProvider({required this.consultImeiUseCase});

  ImeiStatus _status = ImeiStatus.idle;
  ImeiEntity? _resultado;
  String? _errorMessage;

  ImeiStatus get status => _status;
  ImeiEntity? get resultado => _resultado;
  String? get errorMessage => _errorMessage;

  Future<void> consultar(String imei) async {
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
