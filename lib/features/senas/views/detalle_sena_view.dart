import 'package:flutter/material.dart';
import 'package:miapp/features/senas/views/sena_detalle_view.dart';

class DetalleSenaView extends StatelessWidget {
  const DetalleSenaView({super.key, required this.senaId});

  final String senaId;

  @override
  Widget build(BuildContext context) {
    return SenaDetalleView(senaId: senaId);
  }
}
