import '../entities/imei_entity.dart';
import '../repositories/imei_repository.dart';

class ConsultImeiUseCase {
  final ImeiRepository repository;

  ConsultImeiUseCase(this.repository);

  /// Valida formato básico (14 o 15 dígitos) antes de golpear la API.
  Future<ImeiEntity> call(String imei) async {
    final cleaned = imei.replaceAll(RegExp(r'\s|-'), '');
    if (!RegExp(r'^\d{14,15}$').hasMatch(cleaned)) {
      throw FormatException('IMEI inválido: debe tener 14 o 15 dígitos');
    }
    return repository.consultarImei(cleaned);
  }
}
