/// Resultado de comparar una captura con una posición de referencia.
class ResultadoValidacion {
  const ResultadoValidacion({required this.correcto, this.sugerencia});

  factory ResultadoValidacion.fromJson(Map<String, dynamic> json) =>
      ResultadoValidacion(
        correcto: json['correcto'] as bool? ?? false,
        sugerencia: json['sugerencia'] as String?,
      );

  final bool correcto;
  final String? sugerencia;

  Map<String, dynamic> toJson() => {
    'correcto': correcto,
    if (sugerencia != null) 'sugerencia': sugerencia,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultadoValidacion &&
          other.correcto == correcto &&
          other.sugerencia == sugerencia;

  @override
  int get hashCode => Object.hash(correcto, sugerencia);

  @override
  String toString() =>
      'ResultadoValidacion(correcto: $correcto, sugerencia: $sugerencia)';
}
