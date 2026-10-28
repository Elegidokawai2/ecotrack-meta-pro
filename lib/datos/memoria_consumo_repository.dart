// Implementación en memoria del contrato. Es la fuente de verdad (persistido).
import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';

class MemoriaConsumoRepository implements ConsumoRepository {
  final List<Consumo> _consumos = [];

  @override
  Future<void> guardar(Consumo consumo) async {
    _consumos.add(consumo);
  }

  /// Copia que nadie puede modificar desde fuera.
  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_consumos);
}
