import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:miapp/features/home/providers/home_navigation_provider.dart';
import 'package:miapp/features/senas/views/lista_senas_view.dart';
import 'package:miapp/features/senas/views/practica_view.dart';
import 'package:miapp/features/juego/views/juego_view.dart';
import 'package:miapp/features/perfil/views/perfil_view.dart';

/// Cascarón (shell) principal de la aplicación.
///
/// Orquesta la navegación entre los cuatro features principales
/// mediante una barra de navegación personalizada y un [IndexedStack]
/// que mantiene el estado de cada pestaña.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // ── Paleta consistente con auth ──────────────────────────────
  static const _darkTeal = Color(0xFF136862);
  static const _lightTealBg = Color(0xFFE2F4EC);
  static const _grey = Color(0xFF9E9E9E);

  /// Datos de cada tab: icono y label.
  static const _tabs = <_NavTab>[
    _NavTab(icon: Icons.menu_book_rounded, label: 'Diccionario'),
    _NavTab(icon: Icons.live_tv_rounded, label: 'Práctica'),
    _NavTab(icon: Icons.videogame_asset_rounded, label: 'Juego'),
    _NavTab(icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeNavigationProvider);

    final body = switch (currentIndex) {
      0 => const ListaSenasView(),
      1 => const PracticaView(),
      2 => const JuegoView(),
      _ => const PerfilView(),
    };

    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = index == currentIndex;
                return _buildNavItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () =>
                      ref.read(homeNavigationProvider.notifier).state = index,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _lightTealBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 24, color: isSelected ? _darkTeal : _grey),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? _darkTeal : _grey,
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
