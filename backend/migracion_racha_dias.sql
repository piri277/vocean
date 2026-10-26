-- Racha de días seguidos practicando señas.
-- Ejecutar en Supabase > SQL Editor (proyecto VOCEAN).

alter table public.usuario
  add column if not exists racha_dias integer not null default 0 check (racha_dias >= 0),
  add column if not exists ultima_practica date;

comment on column public.usuario.racha_dias is
  'Días seguidos con práctica hasta ultima_practica. La app la muestra en 0 si ultima_practica es anterior a ayer.';
comment on column public.usuario.ultima_practica is
  'Fecha local (del dispositivo) de la última práctica registrada.';
