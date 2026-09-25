import 'reporte_model.dart';

class ImeiResponseModel {
  final String imei;
  final String estado;
  final bool enBaseNegativa;
  final List<String> causales;
  final List<String> operadores;
  final List<ReporteModel> reportes;
  final int totalReportes;
  final String resumen;

  const ImeiResponseModel({
    required this.imei,
    required this.estado,
    required this.enBaseNegativa,
    required this.causales,
    required this.operadores,
    required this.reportes,
    required this.totalReportes,
    required this.resumen,
  });

  factory ImeiResponseModel.fromJson(Map<String, dynamic> json) {
    return ImeiResponseModel(
      imei: json['imei'] as String? ?? '',
      estado: json['estado'] as String? ?? 'desconocido',
      enBaseNegativa: json['en_base_negativa'] as bool? ?? false,
      causales: (json['causales'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      operadores: (json['operadores'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      reportes: (json['reportes'] as List<dynamic>? ?? [])
          .map((e) => ReporteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalReportes: json['total_reportes'] as int? ?? 0,
      resumen: json['resumen'] as String? ?? '',
    );
  }
}
