/// Configuración central de credenciales públicas de Supabase para el cliente móvil.
abstract final class SupabaseConfig {
  /// URL del proyecto de Supabase.
  static const String url = 'https://sdygxlpuzqtxidvldeti.supabase.co';

  /// Clave pública (Publishable / Anon Key) con acceso restringido por RLS.
  static const String anonKey =
      'sb_publishable_U3IjTRacemUrBYqSbCPOnQ_Suuo-qu6';

  /// Clave con la que supabase_flutter guarda la sesión: `sb-<ref>-auth-token`.
  static final String claveSesion =
      'sb-${Uri.parse(url).host.split('.').first}-auth-token';
}
