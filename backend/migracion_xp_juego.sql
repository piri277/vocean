-- XP del juego: modos y dificultades ya ganados (clave "modo:dificultad").
-- Ejecutar en Supabase > SQL Editor (proyecto VOCEAN).

alter table public.usuario
  add column if not exists juegos_ganados text[] not null default '{}';

comment on column public.usuario.juegos_ganados is
  'Modos y dificultades del juego que ya dieron XP, p. ej. "mezcla:facil". Cada uno da XP una sola vez.';
