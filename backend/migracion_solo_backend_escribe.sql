-- Solo el backend (llave de servidor) escribe (aplicada en Supabase el 2026-11-22).
-- Con su token, un usuario solo puede leer sus filas (RLS), y ya no puede cambiarse
-- XP, racha, récord ni progreso llamando a Supabase (PostgREST) directamente.
-- El backend escribe con get_db_escritura (app/api/dependencies.py).
revoke insert, update, delete, truncate, trigger, references
  on all tables in schema public from anon, authenticated;

-- Las tablas nuevas que cree postgres tampoco darán permisos de escritura.
alter default privileges for role postgres in schema public
  revoke insert, update, delete, truncate, trigger, references on tables from anon, authenticated;

-- Para deshacer:
-- grant insert, update, delete on all tables in schema public to authenticated;
