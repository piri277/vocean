## Aplicación móvil para aprender Lengua de Señas Colombiana (LSC) mediante la cámara

**Tipo de documento:** especificación de producto para implementación  
**Plataforma objetivo:** Android, desarrollada con Flutter  
**Idioma de la interfaz:** español  
**Alcance de esta versión:** aprendizaje y práctica de señas estáticas de vocabulario básico de LSC

---

## 1. Objetivo del producto

Construir una aplicación móvil educativa que ayude a las personas a aprender vocabulario básico de Lengua de Señas Colombiana (LSC) mediante lecciones visuales y práctica frente a la cámara del teléfono.

La aplicación debe mostrar cómo realizar una seña, permitir que el usuario intente reproducirla frente a la cámara y ofrecer retroalimentación visual basada en el reconocimiento de la configuración y posición de la mano.

La aplicación es una herramienta educativa de práctica. No debe presentarse como traductor completo de LSC ni afirmar que comprende cualquier seña, conversación o frase.

## 2. Usuarios y necesidad

La aplicación está dirigida a personas principiantes que desean aprender señas básicas de LSC de manera interactiva, practicar desde su teléfono y conocer su progreso.

La experiencia debe ser sencilla para alguien que no conozca la lengua de señas ni tenga experiencia con herramientas de inteligencia artificial.

## 3. Alcance del MVP

### Incluido

1. Pantalla de inicio y navegación principal.
2. Sección para aprender vocabulario de LSC organizado por categorías.
3. Fichas visuales de señas con nombre, imagen o video de referencia e instrucciones.
4. Modo de práctica usando la cámara del dispositivo.
5. Detección de la mano y extracción de puntos clave (landmarks) para señas estáticas.
6. Comparación de la pose detectada con una referencia o clasificador disponible.
7. Retroalimentación comprensible para el usuario.
8. Cuestionarios sencillos para repasar señas.
9. Seguimiento local del progreso: lecciones vistas, ejercicios completados y resultados.
10. Manejo de permisos, errores de cámara y estados de carga.
11. Interfaz adaptable a diferentes tamaños de pantalla.
12. Pruebas de las partes principales de la aplicación.

### Fuera del MVP

- Traducción automática de conversaciones completas.
- Reconocimiento fiable de frases completas.
- Interpretación general de todas las señas de LSC.
- Reconocimiento de señas dinámicas que dependan de secuencias temporales complejas.
- Traducción bidireccional entre español y LSC en tiempo real.
- Modo conversación avanzado.
- Afirmar que el sistema certifica la corrección lingüística de una seña.
- Funciones sociales, videollamadas o publicación de videos.

Estos elementos podrán considerarse para una versión avanzada, después de contar con datos de entrenamiento adecuados y validar el reconocimiento.

## 4. Funcionalidades y comportamiento

### 4.1 Inicio

La pantalla principal debe permitir acceder de forma clara a:

- **Aprender:** consultar las categorías y fichas de señas.
- **Practicar con cámara:** iniciar una práctica guiada.
- **Repasar:** responder preguntas sobre las señas aprendidas.
- **Mi progreso:** revisar el avance del usuario.
- **Perfil:** consultar o cambiar las preferencias disponibles.

Si el proyecto ya tiene autenticación implementada, conservarla e integrarla con la navegación existente. No reconstruir la autenticación ni sustituir decisiones previas sin revisar primero el código actual.

### 4.2 Biblioteca de señas

Mostrar el vocabulario agrupado por categorías. Como contenido inicial, preparar la estructura para:

- Alfabeto manual.
- Números.
- Saludos y expresiones cotidianas.
- Personas y familia.
- Objetos y vocabulario básico.

Las señas incluidas deben estar respaldadas por referencias correctas de LSC. No inventar gestos ni asumir que una seña de otra lengua de señas es equivalente. El contenido debe poder ampliarse sin modificar la lógica central de la aplicación.

Cada ficha debe poder incluir:

- Nombre o etiqueta de la seña.
- Imagen, secuencia de imágenes o video de referencia.
- Instrucciones breves para realizarla.
- Categoría.
- Indicación de si la seña es estática y compatible con la práctica por cámara.
- Identificador estable para guardar el progreso.

Cuando no exista material validado para una seña, usar contenido de demostración claramente marcado como tal, no presentarlo como referencia oficial.

### 4.3 Detalle de una seña

La pantalla de detalle debe mostrar la referencia visual con suficiente tamaño, el nombre de la seña, las instrucciones y las acciones **Practicar**, **Siguiente** y **Volver a la categoría**.

La referencia visual debe ser accesible durante la práctica, si el tamaño de la pantalla lo permite.

### 4.4 Práctica con cámara

Flujo esperado:

1. El usuario selecciona una seña compatible con práctica estática.
2. La aplicación explica brevemente cómo colocar la mano y encuadrarla.
3. La aplicación solicita permiso para usar la cámara solo cuando sea necesario.
4. La vista previa de la cámara se muestra dentro de la pantalla de práctica.
5. El sistema detecta la mano y obtiene sus puntos clave.
6. El sistema compara la pose observada con la referencia o la predicción del clasificador.
7. La aplicación muestra una respuesta útil.
8. El usuario puede intentarlo de nuevo o continuar.

Estados que deben manejarse explícitamente:

- Solicitando permiso.
- Permiso concedido.
- Permiso denegado.
- Permiso denegado permanentemente, con instrucciones para abrir la configuración.
- Cámara no disponible o utilizada por otra aplicación.
- Mano no detectada.
- Mano parcialmente fuera del encuadre.
- Procesamiento en curso.
- Resultado disponible.
- Error de procesamiento.
- Salida de la pantalla y liberación de la cámara.

La cámara debe detenerse y liberar sus recursos al abandonar la pantalla, al pasar la aplicación a segundo plano cuando corresponda o cuando se cierre la sesión de práctica.

### 4.5 Reconocimiento de señas estáticas

El reconocimiento inicial se limita a poses estáticas que puedan distinguirse con el método implementado y con datos suficientes.

Arquitectura sugerida:

1. Capturar los fotogramas de cámara.
2. Procesar los fotogramas a una frecuencia razonable para el dispositivo.
3. Detectar la mano y obtener sus landmarks.
4. Normalizar las coordenadas para reducir la dependencia del tamaño y la posición de la mano en la imagen.
5. Comparar la pose con referencias etiquetadas o pasar los datos a un clasificador.
6. Aplicar un umbral de confianza calibrado con ejemplos reales.
7. Devolver un resultado interpretable a la interfaz.

Evaluar una solución de detección de landmarks compatible con Flutter/Android, por ejemplo MediaPipe mediante una integración mantenida o una integración nativa. Antes de elegir una dependencia, comprobar su mantenimiento, compatibilidad con la versión de Flutter y Android del proyecto, licencia y rendimiento en el dispositivo.

No fingir que una comparación geométrica simple reconoce correctamente todas las señas. Si solo se han implementado reglas geométricas, comunicarlo y limitar el conjunto de señas soportadas. Un clasificador necesita ejemplos etiquetados y pruebas con personas, ángulos, iluminación y tamaños de mano diferentes.

La salida del reconocedor debe distinguir, como mínimo:

- Seña reconocida dentro del conjunto soportado.
- Pose detectada, pero resultado incierto.
- Mano no detectada.
- Pose no incluida en las señas soportadas.

No mostrar un porcentaje de precisión como si fuera una medida de certeza lingüística. Si se muestra una puntuación, explicar que es una estimación del sistema y calibrarla con datos de validación.

### 4.6 Retroalimentación al usuario

La retroalimentación debe ser breve, amable y concreta. Ejemplos:

- “No detecto tu mano. Intenta centrarla en la imagen”.
- “Acerca un poco la mano a la cámara”.
- “La imagen está oscura. Busca una zona mejor iluminada”.
- “Todavía no puedo identificar esta pose. Inténtalo de nuevo”.
- “La pose se parece a la referencia. Revisa también la demostración visual”.

No afirmar que la seña está lingüísticamente correcta cuando el sistema solo compara landmarks. No penalizar al usuario por variaciones que el modelo no haya sido entrenado para reconocer.

### 4.7 Cuestionarios

Implementar ejercicios sencillos, por ejemplo:

- Mostrar una imagen o video y seleccionar la etiqueta correcta.
- Mostrar una etiqueta y escoger la referencia visual correspondiente.
- Repetir una ficha vista anteriormente.

Los cuestionarios deben usar contenido del catálogo y registrar el resultado. La práctica por cámara debe ser opcional y solo aparecer para señas compatibles.

### 4.8 Progreso

Guardar localmente, como mínimo:

- Identificadores de las señas estudiadas.
- Lecciones completadas.
- Resultados de cuestionarios.
- Fecha de última práctica, si resulta útil.

El progreso debe sobrevivir al cierre y reapertura de la aplicación. Mantener separada la lógica de progreso de las pantallas para permitir cambiar la persistencia en el futuro.

## 5. Privacidad y permisos

- Solicitar permiso de cámara en el contexto de la función que lo necesita.
- Explicar por qué se utiliza la cámara.
- Procesar imágenes localmente siempre que la solución elegida lo permita.
- No guardar ni subir fotos o videos del usuario por defecto.
- No transmitir fotogramas a servidores sin una decisión explícita de producto, consentimiento y documentación.
- No registrar imágenes, fotogramas ni datos biométricos en logs.
- Liberar correctamente cámara y recursos de procesamiento.
- Proporcionar una alternativa para aprender mediante las fichas si el usuario no concede acceso a la cámara.

## 6. Diseño y experiencia de usuario

La interfaz debe ser moderna, limpia y educativa, con jerarquía visual clara y controles grandes para uso móvil.

Requisitos:

- Navegación coherente entre Inicio, Aprender, Practicar, Repasar y Perfil.
- Contraste suficiente y textos legibles.
- Estados de carga, error, vacío y éxito.
- Referencias visuales de señas fáciles de consultar.
- Retroalimentación que no dependa exclusivamente del color.
- Diseño adaptable a pantallas pequeñas.
- Mantener el estilo visual y los componentes existentes si el repositorio ya los tiene.

No rehacer toda la interfaz ni instalar paquetes visuales adicionales antes de revisar el proyecto actual.

## 7. Arquitectura técnica

Usar Flutter y respetar la arquitectura que ya exista en el repositorio. Si el proyecto está comenzando desde cero, adoptar una estructura Feature-First con separación clara entre presentación, dominio y datos.

Estructura de referencia, adaptable al estado real del código:

```text
lib/
  app/
    app.dart
    router/
    theme/
  core/
    errors/
    camera/
    permissions/
    utils/
  features/
    auth/
    home/
    sign_language/
      data/
      domain/
      presentation/
    practice/
      data/
      domain/
      presentation/
    quiz/
      data/
      domain/
      presentation/
    progress/
      data/
      domain/
      presentation/
    profile/
```

Pautas:

- Reutilizar la gestión de estado existente. Si no hay una, Riverpod es una opción.
- Reutilizar el sistema de navegación existente. Si no hay uno, evaluar go_router.
- Separar el procesamiento de cámara del código de interfaz.
- Encapsular el reconocimiento detrás de una interfaz, por ejemplo `SignRecognizer`, para poder sustituir reglas geométricas por un clasificador sin reescribir las pantallas.
- Modelar errores de forma explícita.
- Evitar clases, capas y abstracciones que no aporten valor real.
- No añadir dependencias sin justificar su necesidad.
- No exponer claves ni credenciales en el código fuente.

## 8. Modelo de dominio sugerido

Los modelos deben ajustarse al código existente, pero el sistema necesita representar conceptos equivalentes a:

- `Sign`: identificador, etiqueta, categoría, tipo de movimiento y referencia visual.
- `SignCategory`: identificador, nombre y descripción.
- `RecognitionResult`: estado, etiqueta candidata cuando exista y puntuación opcional calibrada.
- `PracticeAttempt`: seña objetivo, resultado, fecha y metadatos no sensibles.
- `QuizResult`: puntuación y preguntas completadas.
- `UserProgress`: señas estudiadas, lecciones y resultados acumulados.

No almacenar imágenes de la cámara en el historial de práctica.

## 9. Rendimiento y uso de recursos

- Evitar ejecutar el reconocedor sobre cada fotograma sin límite.
- Elegir una frecuencia de procesamiento apropiada para móviles.
- No bloquear la interfaz durante la inferencia.
- Evitar crear repetidamente modelos, controladores o procesadores costosos.
- Liberar recursos al salir de la pantalla.
- Medir tiempos de procesamiento y fluidez en un dispositivo real.
- No optimizar prematuramente ni introducir una arquitectura más compleja de lo que requiere el MVP.

## 10. Pruebas y criterios de aceptación

La primera versión se considerará funcional cuando:

1. La aplicación compile y se ejecute en Android.
2. La navegación principal funcione.
3. Las categorías y fichas se muestren correctamente.
4. El permiso de cámara se solicite y se manejen sus estados.
5. La cámara se abra y se libere correctamente.
6. La aplicación distinga los estados de mano detectada y no detectada.
7. El reconocimiento solo se anuncie para señas realmente implementadas.
8. El resultado incierto no se presente como reconocimiento seguro.
9. Los cuestionarios registren resultados.
10. El progreso persista después de reiniciar la aplicación.
11. La aplicación pueda utilizarse para estudiar sin conceder permiso de cámara.
12. Existan pruebas para la lógica de reconocimiento, progreso y estados principales.
13. No se guarden ni transmitan imágenes de cámara de forma predeterminada.
14. La documentación indique qué señas están soportadas y cuáles no.

Para validar la calidad del reconocedor, crear un conjunto de ejemplos etiquetados y medir sus aciertos y errores. No declarar una precisión global sin pruebas suficientes.

## 11. Estrategia de implementación

Implementar en incrementos pequeños:

**Fase 1. Inspección y base:** revisar el repositorio, identificar pantallas, dependencias, arquitectura, rutas y funcionalidades ya existentes. No reemplazar código funcional.

**Fase 2. Catálogo:** definir modelos, categorías, fichas y contenido inicial validado.

**Fase 3. Práctica visual:** implementar permisos, cámara, estados y liberación de recursos.

**Fase 4. Reconocimiento estático:** integrar la detección de landmarks, normalización y un primer reconocedor limitado a un conjunto pequeño de señas.

**Fase 5. Aprendizaje:** integrar retroalimentación, cuestionarios y progreso persistente.

**Fase 6. Verificación:** ejecutar pruebas, revisar el rendimiento en un dispositivo real y documentar limitaciones.

Cada fase debe dejar el proyecto en un estado compilable siempre que sea posible.

## 12. Instrucciones para el agente de programación

Antes de modificar archivos:

1. Inspecciona el repositorio y lee `CLAUDE.md`, si existe.
2. Identifica qué funcionalidades ya están implementadas.
3. Comprueba las versiones de Flutter, Dart y las dependencias relevantes.
4. Resume brevemente el estado actual y propone el siguiente incremento.
5. No reconstruyas funciones existentes sin una razón técnica.

Durante la implementación:

- Realiza cambios pequeños y relacionados.
- Prioriza la solución más simple que cumpla los requisitos.
- No inventes contenido de LSC ni datos de entrenamiento.
- No declares reconocimiento funcional antes de probarlo.
- Ejecuta pruebas y análisis estático pertinentes.
- No elimines código ni cambies dependencias de forma masiva sin justificación.

Al finalizar cada incremento, informa:

- Qué se implementó.
- Qué archivos se modificaron.
- Qué comandos de prueba se ejecutaron y sus resultados.
- Qué queda pendiente.
- Qué limitaciones tiene el reconocimiento actual.

## 13. Evolución futura

Una vez validado el MVP, evaluar por separado:

- Reconocimiento de señas dinámicas mediante secuencias temporales.
- Modelos entrenados con un conjunto de datos de LSC autorizado y representativo.
- Evaluación de componentes no manuales cuando sean necesarios.
- Modo de construcción de frases seña por seña.
- Modo avanzado de conversación y traducción, sujeto a investigación y validación.

Estas funciones no deben simularse con reglas simples ni anunciarse como disponibles hasta que se implementen y validen.

---

**Resultado esperado:** una aplicación Flutter educativa para aprender vocabulario básico de LSC, practicar un conjunto definido de señas estáticas mediante la cámara, recibir retroalimentación honesta y registrar el progreso, con una arquitectura mantenible y límites técnicos explícitos.
"""