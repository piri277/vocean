import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/services/senas_repository.dart';
import 'package:miapp/features/senas/services/supabase_senas_repository.dart';

/// Provider que expone la implementación de [SenasRepository].
final senasRepositoryProvider = Provider<SenasRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSenasRepository(client);
});

/// FutureProvider asíncrono que consulta el catálogo y progreso desde Supabase.
final senasFutureProvider = FutureProvider<List<Sena>>((ref) async {
  final repository = ref.watch(senasRepositoryProvider);
  return repository.obtenerTodas();
});

/// Provider síncrono que expone la lista de señas actualmente cargadas.
/// Retorna una lista vacía mientras se completa la carga inicial.
/// Ordenada por categoría (orden fijo) y, dentro de cada una, por nombre ascendente.
final senasProvider = Provider<List<Sena>>((ref) {
  final senas = ref.watch(senasFutureProvider).value ?? const <Sena>[];
  return [...senas]..sort((a, b) {
    final porCategoria = _rangoCategoria(
      a.categoria,
    ).compareTo(_rangoCategoria(b.categoria));
    return porCategoria != 0 ? porCategoria : a.nombre.compareTo(b.nombre);
  });
});

const _ordenCategorias = ['Alfabeto', 'Números', 'Saludos', 'Emergencias'];

int _rangoCategoria(String categoria) {
  final i = _ordenCategorias.indexOf(categoria);
  return i == -1 ? _ordenCategorias.length : i;
}

/// Provider familiar para consultar una seña específica por su ID.
final senaPorIdProvider = Provider.family<Sena?, String>((ref, id) {
  final senas = ref.watch(senasProvider);
  for (final sena in senas) {
    if (sena.id == id) return sena;
  }
  return null;
});
