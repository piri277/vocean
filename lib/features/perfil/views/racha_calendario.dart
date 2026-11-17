import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';

/// Abre una hoja inferior con el calendario del mes y los días de la racha.
Future<void> mostrarCalendarioRacha(BuildContext context, Usuario? usuario) {
  return showModalBottomSheet<void>(
    context: context,
    // Sin esto la hoja se limita a 9/16 de la pantalla y el mes no cabe.
    isScrollControlled: true,
    backgroundColor: AppTheme.cardBg,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => RachaCalendario(usuario: usuario, hoy: DateTime.now()),
  );
}

/// Días (sin hora) que cubre la racha vigente, de la última práctica hacia atrás.
Set<DateTime> diasDeRacha(Usuario? usuario, DateTime hoy) {
  final racha = usuario?.rachaVigente(hoy) ?? 0;
  final ultima = usuario?.ultimaPractica;
  if (racha == 0 || ultima == null) return {};
  return {
    for (var i = 0; i < racha; i++)
      DateTime(ultima.year, ultima.month, ultima.day - i),
  };
}

class RachaCalendario extends ConsumerStatefulWidget {
  const RachaCalendario({super.key, required this.usuario, required this.hoy});

  final Usuario? usuario;
  final DateTime hoy;

  @override
  ConsumerState<RachaCalendario> createState() => _RachaCalendarioState();
}

class _RachaCalendarioState extends ConsumerState<RachaCalendario> {
  static const _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', //
    'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  static const _letras = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  late DateTime _mes = DateTime(widget.hoy.year, widget.hoy.month);

  @override
  Widget build(BuildContext context) {
    // Historial guardado + racha actual, por si el historial aún no carga.
    final practicados = {
      ...?ref.watch(diasPracticaProvider).valueOrNull,
      ...diasDeRacha(widget.usuario, widget.hoy),
    };
    final racha = widget.usuario?.rachaVigente(widget.hoy) ?? 0;
    final hoy = DateTime(widget.hoy.year, widget.hoy.month, widget.hoy.day);
    final diasMes = DateUtils.getDaysInMonth(_mes.year, _mes.month);
    final huecos = _mes.weekday - 1; // el mes empieza en lunes = 0 huecos
    final esMesActual = _mes.year == hoy.year && _mes.month == hoy.month;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 44)),
              Text(
                racha == 0
                    ? 'Sin racha activa'
                    : '$racha ${racha == 1 ? 'día' : 'días'} de racha',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                racha == 0
                    ? 'Acierta una seña hoy para empezarla.'
                    : 'Acierta una seña cada día para no perderla.',
                style: const TextStyle(color: AppTheme.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Mes anterior',
                    onPressed: () => setState(
                      () => _mes = DateTime(_mes.year, _mes.month - 1),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppTheme.darkTeal,
                  ),
                  Expanded(
                    child: Text(
                      '${_meses[_mes.month - 1]} ${_mes.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mes siguiente',
                    onPressed: esMesActual
                        ? null
                        : () => setState(
                            () => _mes = DateTime(_mes.year, _mes.month + 1),
                          ),
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppTheme.darkTeal,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.25,
                children: [
                  for (final l in _letras)
                    Center(
                      child: Text(
                        l,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.grey,
                        ),
                      ),
                    ),
                  for (var i = 0; i < huecos; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= diasMes; d++)
                    _Dia(
                      dia: d,
                      enRacha: practicados.contains(
                        DateTime(_mes.year, _mes.month, d),
                      ),
                      esHoy: esMesActual && d == hoy.day,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({required this.dia, required this.enRacha, required this.esHoy});

  final int dia;
  final bool enRacha;
  final bool esHoy;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enRacha ? AppTheme.tomato : null,
        shape: BoxShape.circle,
        border: esHoy ? Border.all(color: AppTheme.darkTeal, width: 2) : null,
      ),
      child: Text(
        '$dia',
        style: TextStyle(
          fontWeight: enRacha || esHoy ? FontWeight.w900 : FontWeight.w600,
          color: enRacha ? Colors.white : AppTheme.darkTeal,
        ),
      ),
    );
  }
}
