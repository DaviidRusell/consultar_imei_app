class ReporteEntity {
  final String causal;
  final String causalTexto;
  final String operador;

  const ReporteEntity({
    required this.causal,
    required this.causalTexto,
    required this.operador,
  });
}

class ImeiEntity {
  final String imei;
  final String estado;
  final bool enBaseNegativa;
  final List<String> causales;
  final List<String> operadores;
  final List<ReporteEntity> reportes;
  final int totalReportes;
  final String resumen;

  const ImeiEntity({
    required this.imei,
    required this.estado,
    required this.enBaseNegativa,
    required this.causales,
    required this.operadores,
    required this.reportes,
    required this.totalReportes,
    required this.resumen,
  });

  bool get isLimpio => !enBaseNegativa;
}
