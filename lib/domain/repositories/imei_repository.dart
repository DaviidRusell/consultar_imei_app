import '../entities/imei_entity.dart';

abstract class ImeiRepository {
  Future<ImeiEntity> consultarImei(String imei);
}
