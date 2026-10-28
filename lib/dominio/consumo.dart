// Dominio: Dart puro. Si apagamos Flutter, esto sigue teniendo sentido.

/// Laboratorios donde se registra consumo. Es una constante, no estado.
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

/// Entidad: un consumo de agua en un laboratorio.
class Consumo {
  const Consumo({required this.laboratorio, required this.litros});

  final String laboratorio;
  final double litros;
}

/// Regla de negocio de los litros. Regresa el mensaje de error o `null`.
/// `null` en la entrada significa que el texto no era un número.
String? validarLitros(double? litros) {
  if (litros == null) return 'Escribe los litros con número';
  if (litros <= 0) return 'Los litros deben ser mayores que cero';
  if (litros > 10000) return 'Los litros superan el tope de 10000';
  return null;
}
