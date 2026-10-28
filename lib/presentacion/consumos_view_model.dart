// ViewModel: único dueño del estado compartido. Avisa, no dibuja.
import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:ecotrack_meta/dominio/meta.dart';
import 'package:flutter/foundation.dart';

class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this._repositorio);

  /// Solo conoce el contrato: no sabe si es memoria, disco o nube.
  final ConsumoRepository _repositorio;

  // Estado compartido.
  List<Consumo> consumos = const [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // Estado derivado: se calcula, no se guarda.
  double get total => consumos.fold(0.0, (suma, c) => suma + c.litros);
  double get avance => avanceDeMeta(total: total, meta: meta);
  bool get metaSuperada => total > meta;

  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  /// Regresa `true` si se guardó.
  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    final limpio = litrosTexto.replaceAll(' ', '').replaceAll(',', '.');
    final litros = double.tryParse(limpio);

    final mensaje = validarLitros(litros);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      await _repositorio.guardar(
        Consumo(laboratorio: laboratorio, litros: litros!),
      );
      consumos = await _repositorio.todos();
    } finally {
      guardando = false;
      notifyListeners();
    }
    return true;
  }

  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}
