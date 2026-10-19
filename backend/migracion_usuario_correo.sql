-- Agrega `correo` a public.usuario y lo llena desde el trigger de registro.
-- La contraseña NO se guarda aquí: vive hasheada en auth.users.
-- Ejecutar en Supabase > SQL Editor (proyecto VOCEAN).

alter table public.usuario add column if not exists correo text;

update public.usuario u
set correo = a.email
from auth.users a
where a.id = u.id and u.correo is null;

create unique index if not exists usuario_correo_key on public.usuario (lower(correo));

create or replace function public.crear_usuario_al_registrarse()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.usuario (id, nombre, correo)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nombre', split_part(new.email, '@', 1)),
    new.email
  );
  return new;
end;
$$;

comment on column public.usuario.correo is
  'Copia del correo de auth.users, solo consulta. La contraseña vive hasheada en auth.users.';
