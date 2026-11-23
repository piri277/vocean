import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/juego/logic/banco_juego.dart';
import 'package:miapp/features/juego/models/dificultad_model.dart';

void main() {
  final raw =
      jsonDecode(File('assets/juego/palabras.json').readAsStringSync())
          as Map<String, dynamic>;
  final banco = BancoJuego({
    for (final e in raw.entries)
      e.key: {
        for (final n in (e.value as Map<String, dynamic>).entries)
          n.key: List<String>.from(n.value as List),
      },
  });

  test('el reto del día es igual para todos y cambia al día siguiente', () {
    final hoy = banco.retoDiario(DateTime(2026, 11, 22));
    final otraVez = banco.retoDiario(DateTime(2026, 11, 22, 23, 59));
    final manana = banco.retoDiario(DateTime(2026, 11, 23));
    expect(hoy.map((p) => p.respuesta), otraVez.map((p) => p.respuesta));
    expect(hoy.map((p) => p.opciones), otraVez.map((p) => p.opciones));
    expect(hoy.map((p) => p.respuesta), isNot(manana.map((p) => p.respuesta)));
    expect(hoy, hasLength(preguntasReto));
    expect(hoy.map((p) => p.respuesta).toSet(), hasLength(preguntasReto));
    expect(hoy.map((p) => p.inversa), [false, true, false, true, false]);
  });

  test('cada pregunta tiene 4 opciones distintas con la correcta', () {
    final rnd = Random(1);
    for (final c in CategoriaJuego.values) {
      for (final d in Dificultad.values) {
        final partida = banco.partida(
          categoria: c,
          dificultad: d,
          rondas: 8,
          rnd: rnd,
        );
        expect(partida, hasLength(8));
        for (final p in partida) {
          expect(p.opciones.toSet(), hasLength(4));
          expect(p.opciones, contains(p.respuesta));
          expect(
            p.opciones.every((o) => esNumero(o) == esNumero(p.respuesta)),
            isTrue,
          );
        }
      }
    }
  });

  test('el repaso inteligente hace salir antes lo que pesa más', () {
    final rnd = Random(7);
    var primero = 0;
    for (var i = 0; i < 200; i++) {
      final orden = BancoJuego.ordenar(
        ['a', 'b', 'c', 'd', 'e'],
        rnd,
        (t) => t == 'e' ? 20 : 1,
      );
      if (orden.first == 'e') primero++;
    }
    expect(primero, greaterThan(140));
  });

  test('supervivencia sube de nivel cada 5 aciertos y no repite', () {
    expect(BancoJuego.dificultadSupervivencia(0), Dificultad.facil);
    expect(BancoJuego.dificultadSupervivencia(5), Dificultad.medio);
    expect(BancoJuego.dificultadSupervivencia(14), Dificultad.dificil);
    expect(BancoJuego.dificultadSupervivencia(99), Dificultad.extremo);

    final usadas = <String>{};
    final rnd = Random(3);
    for (var i = 0; i < 20; i++) {
      final p = banco.preguntaSupervivencia(
        categoria: CategoriaJuego.palabras,
        aciertos: 0,
        usadas: usadas,
        rnd: rnd,
      );
      expect(usadas.add(p.respuesta), isTrue, reason: p.respuesta);
    }
  });

  test('la clave del reto usa la fecha local', () {
    expect(claveReto(DateTime(2026, 1, 5, 23)), 'reto:2026-01-05');
  });
}
