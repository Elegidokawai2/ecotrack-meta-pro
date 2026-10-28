// Vistas tontas: reciben datos y callbacks. No saben qué gestor hay arriba.
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:flutter/material.dart';

/// Formulario de Registro. Laboratorio elegido y texto del campo son estado efímero.
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _litros = TextEditingController();
  String _laboratorio = laboratoriosUtez.first;

  @override
  void dispose() {
    _litros.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final guardado = await widget.alGuardar(_laboratorio, _litros.text);
    if (!mounted || !guardado) return;
    _litros.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Consumo guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _laboratorio,
            decoration: const InputDecoration(labelText: 'Laboratorio'),
            items: [
              for (final lab in laboratoriosUtez)
                DropdownMenuItem(value: lab, child: Text(lab)),
            ],
            onChanged: (lab) {
              if (lab != null) setState(() => _laboratorio = lab);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('litros'),
            controller: _litros,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litros',
              errorText: widget.error,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.guardando ? null : _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

/// Historial: total en la primera fila y una fila por consumo.
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({super.key, required this.consumos, required this.total});

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }
    return ListView.separated(
      itemCount: consumos.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        if (i == 0) {
          return ListTile(
            leading: const Icon(Icons.functions),
            title: Text(
              'Total: ${total.toStringAsFixed(1)} L',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }
        final c = consumos[i - 1];
        return ListTile(
          leading: const Icon(Icons.water_drop_outlined),
          title: Text(c.laboratorio),
          trailing: Text('${c.litros.toStringAsFixed(1)} L'),
        );
      },
    );
  }
}

/// Panel de la meta semanal.
class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: avance,
            minHeight: 12,
            color: superada ? colores.error : colores.primary,
          ),
          const SizedBox(height: 12),
          Text(
            superada ? 'Te pasaste de la meta' : 'Dentro de la meta',
            style: TextStyle(color: superada ? colores.error : colores.primary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                key: const Key('bajarMeta'),
                onPressed: alBajar,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 24),
              IconButton.filledTonal(
                key: const Key('subirMeta'),
                onPressed: alSubir,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Esqueleto con tres pestañas. La pestaña activa es estado efímero.
class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  int _pestana = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: IndexedStack(
        index: _pestana,
        children: [widget.registro, widget.historial, widget.meta],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Registro'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Meta'),
        ],
      ),
    );
  }
}
