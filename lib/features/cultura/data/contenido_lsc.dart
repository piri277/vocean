import 'package:flutter/material.dart';

/// Un dato breve de la sección Cultura.
class DatoLsc {
  const DatoLsc(this.titulo, this.texto, {this.fuente});

  final String titulo;
  final String texto;

  /// De dónde sale el dato, para que se pueda verificar.
  final String? fuente;
}

/// Pregunta de opción múltiple del quiz de un tema.
class PreguntaCultura {
  const PreguntaCultura(
    this.enunciado,
    this.opciones,
    this.correcta,
    this.explicacion,
  );

  /// Afirmación de «Mitos y realidades»: se responde Verdadero o Falso.
  const PreguntaCultura.mito(this.enunciado, bool esVerdad, this.explicacion)
    : opciones = const ['Verdadero', 'Falso'],
      correcta = esVerdad ? 0 : 1;

  final String enunciado;
  final List<String> opciones;

  /// Índice de la opción correcta en [opciones].
  final int correcta;
  final String explicacion;
}

/// Grupo temático de datos, con su quiz.
class TemaLsc {
  const TemaLsc({
    required this.id,
    required this.titulo,
    required this.icono,
    required this.datos,
    required this.quiz,
  });

  /// Igual a `TEMAS_CULTURA` del backend: con él se da la XP una sola vez.
  final String id;
  final String titulo;
  final IconData icono;
  final List<DatoLsc> datos;
  final List<PreguntaCultura> quiz;
}

const _funcionPublica = 'Gestor Normativo, Función Pública';

// shortcut: contenido fijo en la app; moverlo al backend si se quiere editar sin publicar.
const temasLsc = <TemaLsc>[
  TemaLsc(
    id: 'linea-tiempo',
    titulo: 'Línea de tiempo',
    icono: Icons.timeline_rounded,
    datos: [
      DatoLsc(
        'Siglo XVIII · París',
        'Charles-Michel de l’Épée abrió una de las primeras escuelas gratuitas '
            'para niños sordos y usó señas para enseñar.',
      ),
      DatoLsc(
        '1864 · Washington',
        'Se crea la institución que hoy es la Universidad Gallaudet, para '
            'estudiantes sordos. Enseña en lengua de señas americana.',
      ),
      DatoLsc(
        '1880 · Milán',
        'Un congreso de educadores decidió enseñar a los sordos solo con voz y '
            'lectura labial. Las señas se prohibieron en muchas escuelas '
            'durante casi un siglo.',
      ),
      DatoLsc(
        '1951',
        'Se funda la Federación Mundial de Sordos (WFD). Por eso el 23 de '
            'septiembre se celebra hoy el día de las lenguas de señas.',
        fuente: 'ONU, Día Internacional de las Lenguas de Señas',
      ),
      DatoLsc(
        '1955 · Colombia',
        'El Decreto 1955 de 1955 crea el INSOR (Instituto Nacional para '
            'Sordos), que orienta la educación e inclusión de las personas '
            'sordas.',
        fuente: 'Decreto 1955 de 1955, $_funcionPublica',
      ),
      DatoLsc(
        '1960',
        'El lingüista William Stokoe mostró que la lengua de señas americana '
            'tiene estructura propia, como cualquier idioma.',
      ),
      DatoLsc(
        '1984 · Colombia',
        'El 5 de enero se funda FENASCOL, la Federación Nacional de Sordos de '
            'Colombia, que defiende los derechos de la comunidad sorda.',
        fuente: 'FENASCOL, información de fundadores',
      ),
      DatoLsc(
        '1996 y 2005 · Colombia',
        'La Ley 324 de 1996 es la primera ley a favor de la población sorda. '
            'La Ley 982 de 2005 define la Lengua de Señas Colombiana.',
        fuente: _funcionPublica,
      ),
      DatoLsc(
        '2010 · Vancouver',
        'El Congreso Internacional de Educación de Sordos rechazó oficialmente '
            'los acuerdos de Milán y lamentó el daño que causaron.',
        fuente: 'Federación Mundial de Sordos (WFD)',
      ),
      DatoLsc(
        '2017 · ONU',
        'La Asamblea General proclamó el 23 de septiembre como Día '
            'Internacional de las Lenguas de Señas. Se celebró por primera vez '
            'en 2018.',
        fuente: 'Resolución A/RES/72/161 de la ONU',
      ),
    ],
    quiz: [
      PreguntaCultura(
        '¿Qué decidió el Congreso de Milán de 1880?',
        [
          'Enseñar solo con voz y lectura labial',
          'Crear una lengua de señas universal',
          'Abrir escuelas en lengua de señas',
        ],
        0,
        'Prohibió las señas en muchas escuelas. En 2010 se rechazó '
            'oficialmente.',
      ),
      PreguntaCultura(
        '¿En qué año se creó el INSOR?',
        ['1955', '1984', '2005'],
        0,
        'Lo creó el Decreto 1955 de 1955. En 1984 se fundó FENASCOL.',
      ),
      PreguntaCultura(
        '¿Por qué el día de las lenguas de señas es el 23 de septiembre?',
        [
          'Ese día se fundó la Federación Mundial de Sordos',
          'Es el cumpleaños de l’Épée',
          'Ese día se firmó la Ley 982',
        ],
        0,
        'La Federación Mundial de Sordos se fundó un 23 de septiembre de 1951.',
      ),
      PreguntaCultura(
        '¿Quién mostró en 1960 que la lengua de señas es un idioma completo?',
        ['William Stokoe', 'Charles-Michel de l’Épée', 'Thomas Gallaudet'],
        0,
        'Stokoe estudió la lengua de señas americana y describió su '
            'estructura.',
      ),
    ],
  ),
  TemaLsc(
    id: 'derechos',
    titulo: 'Derechos en Colombia',
    icono: Icons.gavel_rounded,
    datos: [
      DatoLsc(
        'Ley 324 de 1996',
        'Fue la primera ley colombiana a favor de la población sorda. Habla '
            'de difundir la lengua manual y de contar con intérpretes.',
        fuente: 'Ley 324 de 1996, $_funcionPublica',
      ),
      DatoLsc(
        'Lo que dijo la Corte en 2002',
        'La Sentencia C-128 de 2002 retiró el artículo que llamaba a la lengua '
            'manual «idioma propio». La Corte explicó que no es idioma oficial, '
            'pero que el Estado debe apoyarla sin excluir a quien prefiere la '
            'voz.',
        fuente: 'Corte Constitucional, Sentencia C-128 de 2002',
      ),
      DatoLsc(
        'Ley 982 de 2005',
        'Define la Lengua de Señas Colombiana como la lengua natural de la '
            'comunidad sorda. Busca la igualdad de oportunidades para personas '
            'sordas y sordociegas.',
        fuente: 'Ley 982 de 2005, $_funcionPublica',
      ),
      DatoLsc(
        'Derecho a intérprete',
        'Estas leyes buscan que las personas sordas puedan contar con '
            'intérpretes de LSC en servicios como la educación y la atención '
            'pública.',
        fuente: 'Leyes 324 de 1996 y 982 de 2005',
      ),
      DatoLsc(
        'Educación bilingüe',
        'La Ley 982 de 2005 habla de educación bilingüe: LSC como primera '
            'lengua y español escrito como segunda.',
        fuente: 'Ley 982 de 2005, $_funcionPublica',
      ),
    ],
    quiz: [
      PreguntaCultura(
        '¿Qué ley define la Lengua de Señas Colombiana?',
        ['Ley 982 de 2005', 'Ley 324 de 1996', 'Decreto 1955 de 1955'],
        0,
        'La Ley 982 de 2005 la define como la lengua natural de la comunidad '
            'sorda.',
      ),
      PreguntaCultura(
        '¿Qué es la Sentencia C-128 de 2002?',
        [
          'Una decisión de la Corte sobre la Ley 324',
          'La ley que creó el INSOR',
          'Una norma sobre el juego en la escuela',
        ],
        0,
        'La Corte Constitucional revisó la Ley 324 y retiró el artículo de '
            '«idioma propio».',
      ),
      PreguntaCultura(
        'En la educación bilingüe para sordos, ¿cuál es la primera lengua?',
        ['La LSC', 'El español hablado', 'El inglés'],
        0,
        'La LSC es la primera lengua y el español escrito la segunda.',
      ),
      PreguntaCultura(
        '¿A quiénes busca proteger también la Ley 982 de 2005?',
        [
          'A las personas sordociegas',
          'Solo a los intérpretes',
          'Solo a los niños',
        ],
        0,
        'La ley habla de personas sordas y sordociegas.',
      ),
    ],
  ),
  TemaLsc(
    id: 'lengua',
    titulo: 'La lengua',
    icono: Icons.sign_language_rounded,
    datos: [
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
    ],
    quiz: [
      PreguntaCultura(
        '¿Para qué sirve la dactilología?',
        [
          'Para deletrear nombres o palabras sin seña',
          'Para hacer mímica',
          'Para leer los labios',
        ],
        0,
        'Es el alfabeto manual: letra por letra.',
      ),
      PreguntaCultura(
        '¿Cuál de estos NO es un parámetro de una seña?',
        ['El color de la ropa', 'El movimiento', 'La expresión facial'],
        0,
        'Los parámetros son configuración, orientación, lugar, movimiento y '
            'expresión facial.',
      ),
      PreguntaCultura(
        'En LSC, ¿qué puede convertir una afirmación en pregunta?',
        ['La expresión de la cara', 'Hablar más fuerte', 'Escribirla'],
        0,
        'Las cejas y la cara son parte de la gramática.',
      ),
      PreguntaCultura(
        '¿La LSC es igual en todas las regiones de Colombia?',
        [
          'No, hay variantes regionales',
          'Sí, es idéntica',
          'Solo existe en Bogotá',
        ],
        0,
        'Igual que el español, cambia un poco según la región.',
      ),
    ],
  ),
  TemaLsc(
    id: 'comunidad',
    titulo: 'Comunidad sorda',
    icono: Icons.groups_rounded,
    datos: [
      DatoLsc(
        'Nombre en señas',
        'Las personas sordas suelen tener una seña personal en lugar de '
            'deletrear su nombre. Normalmente la da la misma comunidad sorda.',
      ),
      DatoLsc(
        'Cultura propia',
        'Muchas personas sordas se ven como una comunidad lingüística con su '
            'propia cultura, arte y humor, no solo desde la discapacidad.',
      ),
      DatoLsc(
        'Sordo, no «sordomudo»',
        'Muchas personas sordas pueden usar la voz. La comunidad prefiere '
            '«persona sorda» o «sordo».',
      ),
      DatoLsc(
        'No todos usan señas',
        'Algunas personas sordas se comunican con la voz, la lectura labial o '
            'con audífonos e implantes. Cada persona elige.',
      ),
      DatoLsc(
        'FENASCOL e INSOR',
        'FENASCOL es una organización de la sociedad civil que representa a la '
            'comunidad. El INSOR es una entidad pública del Ministerio de '
            'Educación.',
        fuente: 'FENASCOL; Ministerio de Educación Nacional',
      ),
    ],
    quiz: [
      PreguntaCultura(
        '¿Quién suele dar el nombre en señas a una persona?',
        [
          'La comunidad sorda',
          'La persona misma, al nacer',
          'El Ministerio de Educación',
        ],
        0,
        'Normalmente lo da la comunidad sorda.',
      ),
      PreguntaCultura(
        '¿Qué término prefiere la comunidad?',
        ['Persona sorda', 'Sordomudo', 'Mudito'],
        0,
        'Muchas personas sordas pueden usar la voz: «sordomudo» no es '
            'correcto.',
      ),
      PreguntaCultura(
        '¿Qué es FENASCOL?',
        [
          'La Federación Nacional de Sordos de Colombia',
          'Una ley de 2005',
          'Un tipo de audífono',
        ],
        0,
        'Representa y defiende los derechos de las personas sordas.',
      ),
      PreguntaCultura(
        '¿Todas las personas sordas usan lengua de señas?',
        ['No, cada persona elige', 'Sí, todas', 'Solo los adultos'],
        0,
        'Algunas prefieren la voz, la lectura labial o ayudas auditivas.',
      ),
    ],
  ),
  TemaLsc(
    id: 'comunicacion',
    titulo: 'Cómo comunicarte',
    icono: Icons.forum_rounded,
    datos: [
      DatoLsc(
        'Llama su atención',
        'Toca suavemente el hombro, agita la mano en su campo visual o prende y '
            'apaga la luz. Gritar no ayuda.',
      ),
      DatoLsc(
        'Habla de frente',
        'Ponte de frente y con luz en tu cara. No te tapes la boca ni hables '
            'mientras miras a otro lado.',
      ),
      DatoLsc(
        'Sin exagerar',
        'Habla a ritmo normal. Exagerar la boca o gritar hace más difícil la '
            'lectura labial, que solo capta una parte de lo que dices.',
      ),
      DatoLsc(
        'Pregunta cómo prefiere',
        'Puede ser LSC, escribir, el celular o la voz. Lo mejor es preguntar.',
      ),
      DatoLsc(
        'Mira a la persona, no al intérprete',
        'Cuando hay intérprete, habla y mira directamente a la persona sorda.',
      ),
      DatoLsc(
        '¿No sabes la seña?',
        'Deletréala con el alfabeto manual, despacio. Intentarlo siempre se '
            'agradece.',
      ),
    ],
    quiz: [
      PreguntaCultura(
        '¿Cuál es una buena forma de llamar la atención de una persona sorda?',
        [
          'Tocar suavemente su hombro',
          'Gritar su nombre',
          'Aplaudir detrás de ella',
        ],
        0,
        'También sirve agitar la mano en su campo visual.',
      ),
      PreguntaCultura(
        'Si hay intérprete, ¿a quién debes mirar?',
        ['A la persona sorda', 'Al intérprete', 'A nadie en especial'],
        0,
        'La conversación es con la persona sorda.',
      ),
      PreguntaCultura(
        '¿Ayuda exagerar la boca al hablar?',
        [
          'No, dificulta la lectura labial',
          'Sí, siempre',
          'Solo si gritas también',
        ],
        0,
        'Lo mejor es un ritmo normal, de frente y con luz.',
      ),
      PreguntaCultura(
        'No sabes una seña, ¿qué puedes hacer?',
        [
          'Deletrearla con el alfabeto manual',
          'Dejar de hablar',
          'Inventar una seña cualquiera',
        ],
        0,
        'La dactilología sirve justo para eso.',
      ),
    ],
  ),
  TemaLsc(
    id: 'curiosos',
    titulo: 'Datos curiosos',
    icono: Icons.lightbulb_rounded,
    datos: [
      DatoLsc(
        'No hay una lengua universal',
        'Cada país tiene la suya: la LSC es distinta de la lengua de señas '
            'americana (ASL) o la española (LSE).',
      ),
      DatoLsc(
        '23 de septiembre',
        'Es el Día Internacional de las Lenguas de Señas, proclamado por la '
            'ONU en 2017.',
        fuente: 'Resolución A/RES/72/161 de la ONU',
      ),
      DatoLsc(
        'Una universidad en señas',
        'La Universidad Gallaudet, en Washington, nació en 1864 para '
            'estudiantes sordos y enseña en lengua de señas americana.',
      ),
      DatoLsc(
        'Se balbucea con las manos',
        'Los bebés que crecen con lengua de señas "balbucean" con las manos, '
            'igual que otros bebés lo hacen con sonidos.',
      ),
    ],
    quiz: [
      PreguntaCultura(
        '¿La LSC es igual a la lengua de señas americana (ASL)?',
        [
          'No, cada país tiene la suya',
          'Sí, es la misma',
          'Solo cambia el alfabeto',
        ],
        0,
        'No existe una lengua de señas universal.',
      ),
      PreguntaCultura(
        '¿Qué universidad enseña en lengua de señas americana?',
        ['Gallaudet', 'Harvard', 'Oxford'],
        0,
        'Nació en 1864 en Washington.',
      ),
      PreguntaCultura(
        '¿Qué hacen los bebés que crecen con lengua de señas?',
        [
          'Balbucean con las manos',
          'No se comunican hasta los 5 años',
          'Solo imitan sonidos',
        ],
        0,
        'Su balbuceo es con las manos.',
      ),
      PreguntaCultura(
        '¿Quién proclamó el Día Internacional de las Lenguas de Señas?',
        ['La ONU', 'El INSOR', 'La FIFA'],
        0,
        'Fue la Asamblea General de la ONU en 2017.',
      ),
    ],
  ),
];

/// Afirmaciones de «Mitos y realidades». Su id en el backend es `mitos`.
const mitosLsc = <PreguntaCultura>[
  PreguntaCultura.mito(
    'La lengua de señas es igual en todo el mundo.',
    false,
    'Cada país tiene la suya. La LSC es distinta de la ASL o la LSE.',
  ),
  PreguntaCultura.mito(
    'La LSC es español hecho con las manos.',
    false,
    'Tiene su propia gramática y vocabulario.',
  ),
  PreguntaCultura.mito(
    'Las lenguas de señas son mímica.',
    false,
    'Son lenguas completas, con reglas como cualquier idioma.',
  ),
  PreguntaCultura.mito(
    'Las personas sordas leen los labios perfectamente.',
    false,
    'Muchos sonidos se ven iguales en los labios: solo se capta una parte.',
  ),
  PreguntaCultura.mito(
    'Lo correcto es decir «sordomudo».',
    false,
    'Muchas personas sordas pueden usar la voz. Se dice «persona sorda».',
  ),
  PreguntaCultura.mito(
    'La expresión facial es parte de la gramática de la LSC.',
    true,
    'La cara marca preguntas, negaciones e intensidad.',
  ),
  PreguntaCultura.mito(
    'Todas las personas sordas usan lengua de señas.',
    false,
    'Algunas usan la voz, la lectura labial o ayudas auditivas.',
  ),
  PreguntaCultura.mito(
    'La LSC tiene variantes regionales.',
    true,
    'Como el español, algunas señas cambian según la región.',
  ),
  PreguntaCultura.mito(
    'Existe un Día Internacional de las Lenguas de Señas.',
    true,
    'Es el 23 de septiembre, proclamado por la ONU en 2017.',
  ),
  PreguntaCultura.mito(
    'Un bebé no puede aprender lengua de señas.',
    false,
    'Los bebés aprenden señas igual que palabras, y hasta balbucean con las '
        'manos.',
  ),
  PreguntaCultura.mito(
    'Gritar ayuda a que una persona sorda te entienda.',
    false,
    'No ayuda. Mejor ponte de frente, con luz y a ritmo normal.',
  ),
  PreguntaCultura.mito(
    'Las personas sordas tienen nombres en señas.',
    true,
    'Suele darlos la comunidad sorda.',
  ),
];

/// Datos que solo salen como «Dato del día», además de los de los temas.
const datosDelDiaExtra = <DatoLsc>[
  DatoLsc(
    'Más de 300 lenguas de señas',
    'Según la Federación Mundial de Sordos, citada por la ONU, hay más de 70 '
        'millones de personas sordas, que usan más de 300 lenguas de señas '
        'distintas.',
    fuente: 'ONU, Día Internacional de las Lenguas de Señas',
  ),
  DatoLsc(
    'Inglés no es igual a inglés',
    'Estados Unidos y el Reino Unido hablan inglés, pero sus lenguas de señas '
        '(ASL y BSL) son muy distintas.',
  ),
  DatoLsc(
    'La ASL tiene raíces francesas',
    'La lengua de señas americana está emparentada con la francesa: un '
        'maestro sordo francés, Laurent Clerc, ayudó a fundar en 1817 la '
        'primera escuela permanente para sordos de Estados Unidos.',
  ),
  DatoLsc(
    'Una o dos manos',
    'En la ASL se deletrea con una mano; en la lengua de señas británica, con '
        'las dos.',
  ),
  DatoLsc(
    'Una lengua que nació en el aula',
    'En los años 70 y 80, niños sordos de escuelas de Nicaragua crearon entre '
        'ellos una lengua de señas nueva. Los lingüistas la estudian para '
        'entender cómo nacen las lenguas.',
  ),
  DatoLsc(
    'Una isla donde todos señaban',
    'En Martha’s Vineyard (Estados Unidos), durante los siglos XVIII y XIX '
        'había tantas personas sordas que mucha gente oyente también usaba '
        'señas.',
  ),
  DatoLsc(
    'Las señas no son dibujos',
    'Algunas señas se parecen a lo que significan, pero la mayoría son '
        'convencionales: la seña de «árbol» cambia de una lengua a otra.',
  ),
  DatoLsc(
    'El espacio también habla',
    'Quien seña puede ubicar a una persona en un punto del espacio y luego '
        'señalar ese punto para referirse a ella, como un pronombre.',
  ),
  DatoLsc(
    'Mano dominante',
    'Cada quien seña con su mano dominante. Las personas zurdas hacen las '
        'señas en espejo y se entienden igual.',
  ),
  DatoLsc(
    'Poesía en señas',
    'Existen poesía, teatro y humor en lenguas de señas, con rimas hechas de '
        'formas de mano y movimientos.',
  ),
  DatoLsc(
    'Lengua de señas táctil',
    'Muchas personas sordociegas se comunican tocando las manos de quien '
        'seña para sentir cada seña.',
  ),
  DatoLsc(
    'Helen Keller',
    'Sordociega desde bebé, se graduó de la universidad en 1904 y dedicó su '
        'vida a defender los derechos de las personas con discapacidad.',
  ),
  DatoLsc(
    'Beethoven',
    'El compositor fue perdiendo la audición y escribió algunas de sus obras '
        'más famosas, como la Novena Sinfonía, ya casi sordo.',
  ),
  DatoLsc(
    'Tocar descalza',
    'La percusionista escocesa Evelyn Glennie es sorda y suele tocar '
        'descalza para sentir la música a través del piso.',
  ),
  DatoLsc(
    'Un Óscar para una actriz sorda',
    'Marlee Matlin ganó el Óscar a mejor actriz en 1987 por «Te amaré en '
        'silencio» (Children of a Lesser God).',
  ),
  DatoLsc(
    'CODA',
    'Así se le dice a una persona oyente hija de padres sordos (Child of '
        'Deaf Adults). También es el nombre de la película que ganó el Óscar '
        'a mejor película en 2022.',
  ),
  DatoLsc(
    'Troy Kotsur',
    'Por «CODA» se convirtió en el primer hombre sordo en ganar un Óscar de '
        'actuación.',
  ),
  DatoLsc(
    'Sordolimpiadas',
    'Los juegos deportivos para atletas sordos se celebran desde 1924, cuando '
        'se hicieron por primera vez en París.',
  ),
  DatoLsc(
    'Salida con luces',
    'En competencias para atletas sordos la salida se marca con luces o '
        'señales visuales en lugar de un disparo.',
  ),
  DatoLsc(
    'El huddle',
    'Se cuenta que el «huddle» del fútbol americano nació en Gallaudet, para '
        'que el otro equipo no viera las señas de la jugada.',
  ),
  DatoLsc(
    'Timbres que brillan',
    'En casa, muchas personas sordas usan timbres con luz, alarmas que vibran '
        'y bebés monitoreados con luces.',
  ),
  DatoLsc(
    'Las videollamadas cambiaron todo',
    'Con la cámara del celular, las personas sordas pueden conversar a '
        'distancia en su propia lengua.',
  ),
  DatoLsc(
    'Subtítulos para todos',
    'Los subtítulos nacieron pensando en las personas sordas, pero hoy los usa '
        'mucha gente oyente en lugares con ruido.',
  ),
  DatoLsc(
    'Hablar con las manos llenas',
    'Si tienes algo en una mano, puedes señar con la otra: muchas señas se '
        'adaptan a una sola mano en la conversación cotidiana.',
  ),
  DatoLsc(
    'El aplauso sordo',
    'En eventos con personas sordas se aplaude levantando las manos y '
        'agitándolas en el aire, para que el aplauso se vea.',
  ),
  DatoLsc(
    'Dactilología rápida',
    'Con práctica, el deletreo se hace muy rápido y se lee por la forma '
        'completa de la palabra, no letra por letra.',
  ),
];
