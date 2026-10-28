# Gestión de estado — EcoTrack Meta

**Equipo:** Erick (piloto)  y Seba (copiloto)
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero: solo le importa al esqueleto y se cambia con `setState`. | `_PantallasEcoTrackState._pestana` en `lib/presentacion/vistas.dart`. |
| Texto del campo de litros | Efímero: vive en el `State` del formulario y se limpia al guardar. | `_FormularioRegistroState._litros` (`TextEditingController`, liberado en `dispose()`) y `_laboratorio`, en `vistas.dart`. |
| consumos y meta | Compartido: las tres pestañas los leen y un solo dueño los cambia. | Campos `consumos` y `meta` de `ConsumosViewModel` (`lib/presentacion/consumos_view_model.dart`). |
| total y metaSuperada | Derivado: se calculan de `consumos` y `meta`, nunca se guardan. | Getters `total`, `avance` y `metaSuperada` de `ConsumosViewModel`; prueba "total, avance y metaSuperada se derivan de consumos y meta" (etapa 3). |
| Lo que regresa todos() | Persistido: es la fuente de verdad; el ViewModel solo tiene una copia. | `_consumos` de `MemoriaConsumoRepository`, devuelto con `List.unmodifiable`; prueba "todos() no deja modificar la lista interna" (etapa 2). |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Un solo `ConsumosViewModel` creado en `_AppChangeNotifierState` y pasado a `RegistroCN`, `HistorialCN` y `MetaCN`; prueba "Dato compartido" de `etapa4_change_notifier_test.dart`. | Un solo `ChangeNotifierProvider<ConsumosViewModel>` en `AppProvider`; las tres pestañas lo piden con `context.watch`; prueba "Dato compartido" de `etapa5_provider_test.dart`. |
| Capas | `vistas.dart` solo importa `material.dart` y `dominio/consumo.dart`; el adaptador con `ListenableBuilder` es el puente; prueba "Capas" (etapa 4) y puntos 2–5 de `verificar_estado.sh`. | Las mismas vistas sin tocar; el puente ahora es `context.watch`/`context.read` en `b_provider.dart`; prueba "Capas" (etapa 5) y punto 6 del script. |
| Encaje con el diagrama | Vista tonta → adaptador `*CN` (escucha con `ListenableBuilder`) → `ConsumosViewModel` → `ConsumoRepository`. | Vista tonta → adaptador `*Provider` (`watch`/`read`) → el mismo `ConsumosViewModel` → `ConsumoRepository`; solo cambió el pegamento. |
| Constructores que reciben vm | 3 (`RegistroCN`, `HistorialCN`, `MetaCN`); con una subpantalla de detalle en Meta serían 4 y habría que pasarlo de mano en mano. | 0: los adaptadores son `const` sin parámetros; prueba "Los adaptadores piden el ViewModel al árbol, no al constructor". |
| Quién libera el ViewModel | El dueño: `_AppChangeNotifierState.dispose()` llama `_vm.dispose()`; ningún adaptador lo hace. | `ChangeNotifierProvider`, porque lo creó con `create:`; lo libera solo cuando sale del árbol. No escribimos `dispose()`. |
| Costo de adoptarla ahora | Cero dependencias, pero el cableado manual crece con cada pantalla nueva (`a_change_notifier.dart` usa `ListenableBuilder` en cada adaptador). | Una dependencia (`provider` en `pubspec.yaml`) y aprender `watch` vs `read`; a cambio `b_provider.dart` es más corto y no pasa `vm`. |
| Sustitución de la fuente de datos | `AppChangeNotifier(repositorio:)` recibe cualquier `ConsumoRepository`; prueba "Sustitución" con `RepositorioEspia` y solo `main_change_notifier.dart` importa `MemoriaConsumoRepository`. | `AppProvider(repositorio:)` igual; prueba "Sustitución" (etapa 5) y solo `main.dart` importa `MemoriaConsumoRepository` (punto 8 del script). |

## Elección

Elegimos: **B · provider**, porque comparte el mismo `ConsumosViewModel` sin pasarlo por constructores (0 contra 3) y se encarga de liberarlo.
Se mantiene esta pieza del diagrama: `ConsumosViewModel` junto con `vistas.dart` y el dominio; `consumos_view_model.dart` no cambió entre la etapa 4 y la 5.
Esta pieza es la que podría sustituirse después: `MemoriaConsumoRepository`, por otra implementación de `ConsumoRepository` (disco o nube) cambiando solo `main.dart`, como ya lo demuestra `RepositorioEspia` en las pruebas.
