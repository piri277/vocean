import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/core/theme/app_theme.dart';

import 'package:miapp/features/home/providers/home_navigation_provider.dart';
import 'package:miapp/features/home/views/bienvenida_animada.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/views/diccionario_view.dart';
import 'package:miapp/features/cultura/views/cultura_view.dart';
import 'package:miapp/features/juego/views/juego_view.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/perfil/views/perfil_view.dart';
import 'package:miapp/features/perfil/views/racha_celebracion.dart';

/// Cascarón (shell) principal de la aplicación.
///
/// Orquesta la navegación entre los cuatro features principales
/// mediante una barra de navegación personalizada o deslizando el dedo
/// entre pestañas. La práctica se abre desde el detalle de cada seña.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final _paginas = PageController(
    initialPage: ref.read(homeNavigationProvider),
  );

  /// Animación de entrada: tapa la app mientras cargan señas y perfil.
  bool _bienvenida = true;
  // Empieza junto con la animación: así la pantalla de carga no pasa de
  // ~5 s contando la salida (0,45 s).
  late final Future<void> _carga = _esperarDatos().timeout(
    const Duration(milliseconds: 4500),
  );
  final _escuchas = <ProviderSubscription<Object?>>[];

  Future<void> _esperarDatos() => esperarCargas(ref, [
    senasFutureProvider,
    usuarioFutureProvider,
  ], _escuchas);

  @override
  void dispose() {
    for (final e in _escuchas) {
      e.close();
    }
    _paginas.dispose();
    super.dispose();
  }

  // ── Paleta consistente con auth ──────────────────────────────
  static const _darkTeal = Color(0xFF1B4532);
  static const _lightTealBg = Color(0xFFDDE2CC);
  static const _grey = Color(0xFF8A8272);

  /// Datos de cada tab: icono y label.
  static const _tabs = <_NavTab>[
    _NavTab(icon: Icons.menu_book_rounded, label: 'Diccionario'),
    _NavTab(icon: Icons.videogame_asset_rounded, label: 'Juego'),
    _NavTab(icon: Icons.auto_stories_rounded, label: 'Cultura'),
    _NavTab(icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeNavigationProvider);
    // Al cargar el perfil, avisa si la racha se perdió desde la última visita.
    ref.listen(usuarioProvider, (anterior, usuario) {
      if (anterior == null && usuario != null) {
        avisarSiPerdioRacha(context, usuario);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _paginas,
            onPageChanged: (i) =>
                ref.read(homeNavigationProvider.notifier).state = i,
            children: const [
              DiccionarioView(),
              JuegoView(),
              CulturaView(),
              PerfilView(),
            ],
          ),
          if (_bienvenida)
            Positioned.fill(
              child: BienvenidaAnimada(
                cargando: _carga,
                alTerminar: () => setState(() => _bienvenida = false),
              ),
            ),
        ],
      ),
      // Sin barra mientras está la pantalla de carga.
      bottomNavigationBar: _bienvenida
          ? null
          : Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final tab = _tabs[index];
                      final isSelected = index == currentIndex;
                      return Expanded(
                        child: _buildNavItem(
                          tab: tab,
                          isSelected: isSelected,
                          onTap: () => _paginas.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem({
    required _NavTab tab,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _lightTealBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 24, color: isSelected ? _darkTeal : _grey),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                maxLines: 1,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? _darkTeal : _grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo interno para los datos de cada tab.
class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
