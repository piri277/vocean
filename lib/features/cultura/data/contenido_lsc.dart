import 'package:flutter/material.dart';

/// Un dato breve de la sección Cultura.
class DatoLsc {
  const DatoLsc(this.titulo, this.texto);

  final String titulo;
  final String texto;
}

/// Grupo temático de datos.
class TemaLsc {
  const TemaLsc(this.titulo, this.icono, this.datos);

  final String titulo;
  final IconData icono;
  final List<DatoLsc> datos;
}

// shortcut: contenido fijo en la app; moverlo al backend si se quiere editar sin publicar.
const temasLsc = <TemaLsc>[
  TemaLsc('Historia', Icons.history_edu_rounded, [
    DatoLsc(
      'Reconocida por ley desde 1996',
      'La Ley 324 de 1996 reconoció la lengua de señas como idioma propio de '
          'la comunidad sorda de Colombia.',
    ),
    DatoLsc(
      'Ley 982 de 2005',
      'Busca la igualdad de oportunidades para las personas sordas y '
          'sordociegas, y regula temas como la interpretación en LSC.',
    ),
    DatoLsc(
      'INSOR',
      'El Instituto Nacional para Sordos se creó en 1955 y orienta la '
          'educación e inclusión de las personas sordas en el país.',
    ),
    DatoLsc(
      'FENASCOL',
      'La Federación Nacional de Sordos de Colombia, fundada en 1984, '
          'defiende los derechos de la comunidad sorda y promueve la LSC.',
    ),
    DatoLsc(
      'El Congreso de Milán (1880)',
      'Un congreso de educadores decidió enseñar a los sordos solo con voz y '
          'lectura labial. Las lenguas de señas se prohibieron en muchas '
          'escuelas durante casi un siglo; en 2010 ese acuerdo se rechazó '
          'oficialmente.',
    ),
    DatoLsc(
      'La primera escuela pública',
      'En el siglo XVIII, Charles-Michel de l’Épée abrió en París una de las '
          'primeras escuelas gratuitas para niños sordos y usó señas para '
          'enseñar.',
    ),
  ]),
  TemaLsc('La lengua', Icons.sign_language_rounded, [
    DatoLsc(
      'Una lengua completa',
      'La LSC tiene su propia gramática y vocabulario. No es español hecho '
          'con las manos ni mímica.',
    ),
    DatoLsc(
      'La cara también habla',
      'Las cejas, la boca y la postura son parte de la gramática: cambian una '
          'afirmación a pregunta o muestran intensidad.',
    ),
    DatoLsc(
      'Cinco parámetros',
      'Cada seña se forma con la configuración de la mano, su orientación, el '
          'lugar donde se hace, el movimiento y la expresión facial.',
    ),
    DatoLsc(
      'Dactilología',
      'El alfabeto manual sirve para deletrear nombres propios o palabras que '
          'aún no tienen seña. ¡Es lo que practicas en esta app!',
    ),
    DatoLsc(
      'Variantes regionales',
      'Como pasa con el español, algunas señas cambian entre regiones de '
          'Colombia.',
    ),
  ]),
  TemaLsc('Comunidad sorda', Icons.groups_rounded, [
    DatoLsc(
      'Nombre en señas',
      'Las personas sordas suelen tener una seña personal en lugar de '
          'deletrear su nombre. Normalmente la da la misma comunidad sorda.',
    ),
    DatoLsc(
      'Cómo llamar la atención',
      'Toca suavemente el hombro, agita la mano en su campo visual o prende y '
          'apaga la luz. Gritar no ayuda.',
    ),
    DatoLsc(
      'Mira a la persona, no al intérprete',
      'Cuando hay intérprete, habla y mira directamente a la persona sorda.',
    ),
    DatoLsc(
      'Cultura propia',
      'Muchas personas sordas se ven como una comunidad lingüística con su '
          'propia cultura, arte y humor, no solo desde la discapacidad.',
    ),
  ]),
  TemaLsc('Datos curiosos', Icons.lightbulb_rounded, [
    DatoLsc(
      'No hay una lengua universal',
      'Cada país tiene la suya: la LSC es distinta de la lengua de señas '
          'americana (ASL) o la española (LSE).',
    ),
    DatoLsc(
      '23 de septiembre',
      'Es el Día Internacional de las Lenguas de Señas, proclamado por la ONU.',
    ),
    DatoLsc(
      'Una universidad en señas',
      'La Universidad Gallaudet, en Washington, fue creada en 1864 para '
          'estudiantes sordos y enseña en lengua de señas americana.',
    ),
    DatoLsc(
      'Se demostró que son lenguas',
      'En 1960 el lingüista William Stokoe mostró que la lengua de señas '
          'americana tiene estructura propia, como cualquier idioma.',
    ),
    DatoLsc(
      'Se balbucea con las manos',
      'Los bebés que crecen con lengua de señas "balbucean" con las manos, '
          'igual que otros bebés lo hacen con sonidos.',
    ),
  ]),
];
