import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Singleton que gestiona la reproducción de streams de radio.
///
/// Persiste entre pantallas — el audio continúa aunque el usuario
/// navegue a otras secciones de la app.
class RadioPlayerService {
  RadioPlayerService._();
  static final RadioPlayerService instance = RadioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  bool _sessionConfigured = false;

  // ── Estado reactivo ────────────────────────────────────

  /// Stream del estado de reproducción (true = reproduciendo).
  Stream<bool> get isPlayingStream => _player.playingStream;

  /// Valor sincrónico del estado de reproducción.
  bool get isPlaying => _player.playing;

  // ── Operaciones ────────────────────────────────────────

  /// Inicia o cambia el stream al [streamUrl] dado.
  ///
  /// Throws [PlayerException] si el stream no pudo cargarse.
  Future<void> play(String streamUrl) async {
    // Bug fix: configurar sesión ANTES de marcar el flag
    await _configureSession();

    await _player.stop();

    // Bug fix: NO usar preload:false para streams en vivo.
    // Con preload:false, play() retorna sin conectar y el error
    // ocurre asíncronamente sin llegar al catch del caller.
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(streamUrl)),
    );

    await _player.play();
  }

  /// Detiene la reproducción sin liberar el servicio.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Pausa la reproducción manteniendo la fuente cargada.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Reanuda la reproducción tras una pausa.
  Future<void> resume() async {
    await _player.play();
  }

  /// Libera todos los recursos — llamar solo al cerrar la app.
  Future<void> dispose() async {
    await _player.dispose();
  }

  // ── Configuración de sesión iOS/Android ────────────────

  Future<void> _configureSession() async {
    if (_sessionConfigured) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
      // Bug fix: marcar como configurado SOLO si no hubo excepción
      _sessionConfigured = true;
      debugPrint('[RadioPlayer] AudioSession configurada correctamente.');
    } catch (e) {
      // La sesión no se configuró — no marcar flag para reintentar.
      debugPrint('[RadioPlayer] Error configurando AudioSession: $e');
    }
  }
}
