import 'package:audioplayers/audioplayers.dart';

/// Reproduce el audio de un número desde `assets/audio/numeros/<n>.mp3`.
class AudioNumerosService {
  final AudioPlayer _player = AudioPlayer();

  /// Si el archivo no existe o falla la reproducción, no interrumpe el flujo.
  Future<bool> reproducir(int numero) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/numeros/$numero.mp3'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() => _player.dispose();
}
