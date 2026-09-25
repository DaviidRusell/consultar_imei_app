class ReporteModel {
  final String causal;
  final String causalTexto;
  final String operador;

  const ReporteModel({
    required this.causal,
    required this.causalTexto,
    required this.operador,
  });

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      causal: json['causal'] as String? ?? '',
      causalTexto: json['causal_texto'] as String? ?? '',
      operador: json['operador'] as String? ?? '',
    );
  }
}
