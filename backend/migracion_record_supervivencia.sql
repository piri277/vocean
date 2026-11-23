-- Récord del modo Supervivencia en el perfil (aplicada en Supabase el 2026-11-22).
alter table public.usuario
  add column if not exists record_supervivencia integer not null default 0
  check (record_supervivencia >= 0);
comment on column public.usuario.record_supervivencia is
  'Mejor cantidad de aciertos en el modo Supervivencia del juego.';
