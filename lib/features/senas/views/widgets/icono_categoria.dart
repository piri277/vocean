import 'package:flutter/material.dart';

/// Ícono lineal de cada categoría del diccionario.
IconData iconoCategoria(String categoria) => switch (categoria) {
  'Alfabeto' => Icons.abc_rounded,
  'Saludos' => Icons.waving_hand_outlined,
  'Números' => Icons.pin_outlined,
  'Emergencias' => Icons.health_and_safety_outlined,
  _ => Icons.sign_language_outlined,
};

/// Asset de la imagen de referencia de una seña según su id
/// (`num-3` -> números, `alfa-a` -> letras). Puede no existir.
String imagenDeSena(String senaId) => senaId.startsWith('num-')
    ? 'assets/numeros/${senaId.substring(4)}.png'
    : 'assets/letras/${senaId.replaceFirst('alfa-', '')}.png';

/// Texto en minúsculas y sin tildes, para buscar sin importar acentos.
String normalizarBusqueda(String texto) {
  const tildes = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  return texto.toLowerCase().split('').map((c) => tildes[c] ?? c).join().trim();
}
