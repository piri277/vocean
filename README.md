# Miapp — Diccionario de Lengua de Señas

App móvil que ayuda a aprender lengua de señas (alfabeto, saludos, vocabulario básico) con práctica interactiva y seguimiento de progreso.

## El dominio

- `Sena`   — entidad principal. Identidad: `id`.
- `PosicionMano` — objeto de valor (landmarks de referencia + ángulos).
- `EstadoAprendizaje` — sellada: NoIniciada · EnPractica · Dominada · NecesitaRepaso.

Decisión: modelo escrito a mano, sin freezed, porque el volumen de campos por clase es pequeño y el mensaje de error propio (`CampoInvalido`) da más contexto que el genérico del generador.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run
