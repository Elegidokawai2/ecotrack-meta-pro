// Contrato de la fuente de datos. Habla como el dominio, no como la tecnología.
import 'package:ecotrack_meta/dominio/consumo.dart';

abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}
