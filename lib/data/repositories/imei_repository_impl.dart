import '../../domain/entities/imei_entity.dart';
import '../../domain/repositories/imei_repository.dart';
import '../datasources/imei_remote_datasource.dart';

class ImeiRepositoryImpl implements ImeiRepository {
  final ImeiRemoteDataSource remoteDataSource;

  ImeiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ImeiEntity> consultarImei(String imei) async {
    final model = await remoteDataSource.consultarImei(imei);

    return ImeiEntity(
      imei: model.imei,
      estado: model.estado,
      enBaseNegativa: model.enBaseNegativa,
      causales: model.causales,
      operadores: model.operadores,
      reportes: model.reportes
          .map(
            (r) => ReporteEntity(
              causal: r.causal,
              causalTexto: r.causalTexto,
              operador: r.operador,
            ),
          )
          .toList(),
      totalReportes: model.totalReportes,
      resumen: model.resumen,
    );
  }
}
