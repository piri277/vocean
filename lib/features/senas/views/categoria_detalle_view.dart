import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/encabezado_pantalla.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/views/sena_detalle_view.dart';
import 'package:miapp/features/senas/views/widgets/icono_categoria.dart';
import 'package:miapp/features/senas/views/widgets/sena_chip.dart';

/// Filtros por estado de aprendizaje.
enum _Filtro {
  todas('Todas'),
  sinIniciar('Sin iniciar'),
  enPractica('En práctica'),
  dominadas('Dominadas');

  const _Filtro(this.etiqueta);
  final String etiqueta;

  bool acepta(EstadoAprendizaje e) => switch (this) {
    _Filtro.todas => true,
    _Filtro.sinIniciar => e is NoIniciada,
    _Filtro.enPractica => e is EnPractica || e is NecesitaRepaso,
    _Filtro.dominadas => e is Dominada,
  };
}

class CategoriaDetalleView extends ConsumerStatefulWidget {
  const CategoriaDetalleView({super.key, required this.categoria});

  final String categoria;

  @override
  ConsumerState<CategoriaDetalleView> createState() =>
      _CategoriaDetalleViewState();
}

class _CategoriaDetalleViewState extends ConsumerState<CategoriaDetalleView> {
  final _buscador = TextEditingController();
  String _texto = '';
  _Filtro _filtro = _Filtro.todas;

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  bool _coincide(Sena s) {
    if (!_filtro.acepta(s.estadoAprendizaje)) return false;
    if (_texto.isEmpty) return true;
    return normalizarBusqueda(s.nombre).contains(_texto) ||
        normalizarBusqueda(s.descripcion).contains(_texto);
  }

  @override
  Widget build(BuildContext context) {
    final senas = ref
        .watch(senasProvider)
        .where((s) => s.categoria == widget.categoria)
        .toList();
    final dominadas = senas
        .where((s) => s.estadoAprendizaje is Dominada)
        .length;
    final visibles = senas.where(_coincide).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: GestureDetector(
        // Tocar fuera del buscador cierra el teclado.
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverList.list(
                children: [
                  EncabezadoPantalla(
                    etiqueta: 'Diccionario',
                    pildora: PildoraInfo(
                      icono: Icons.verified_rounded,
                      texto: '$dominadas/${senas.length}',
                    ),
                    titulo: widget.categoria,
                    subtitulo:
                        '${senas.length} señas. Toca una para ver cómo se hace y practicarla.',
                  ),
                  const SizedBox(height: 18),
                  _Buscador(
                    controller: _buscador,
                    onChanged: (v) =>
                        setState(() => _texto = normalizarBusqueda(v)),
                    onLimpiar: () => setState(() {
                      _buscador.clear();
                      _texto = '';
                    }),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _Filtro.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final f = _Filtro.values[i];
                        final activo = f == _filtro;
                        return ChoiceChip(
                          label: Text(f.etiqueta),
                          selected: activo,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _filtro = f),
                          selectedColor: AppTheme.darkTeal,
                          backgroundColor: AppTheme.cardBg,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(
                            color: activo
                                ? AppTheme.bgCream
                                : AppTheme.darkTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (visibles.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 44,
                        color: AppTheme.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No hay señas que coincidan.',
                        style: TextStyle(
                          color: AppTheme.darkTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: [
                    for (final sena in visibles)
                      SenaChip(
                        sena: sena,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SenaDetalleView(
                              senaId: sena.id,
                              ids: [for (final s in visibles) s.id],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Buscador extends StatelessWidget {
  const _Buscador({
    required this.controller,
    required this.onChanged,
    required this.onLimpiar,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: AppTheme.darkTeal,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar seña…',
        hintStyle: const TextStyle(color: AppTheme.grey),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.darkTeal),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, valor, _) => valor.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Borrar búsqueda',
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.grey,
                  onPressed: onLimpiar,
                ),
        ),
        filled: true,
        fillColor: AppTheme.cardBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
        ),
      ),
    );
  }
}
