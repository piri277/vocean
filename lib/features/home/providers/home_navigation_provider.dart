import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que gestiona el índice seleccionado del BottomNavigationBar.
///
/// Valores:
/// - 0 → Diccionario (señas)
/// - 1 → Práctica
/// - 2 → Juego
/// - 3 → Perfil
final homeNavigationProvider = StateProvider<int>((ref) => 0);
